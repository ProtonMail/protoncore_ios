# PaymentsV2

## ProtonCore 34.2.0 update
Starting from ProtonCore v.34.2.0 the new Payments lib introduces a list of quality of life improvements.
- RemoteManagerProviding scope simplified
- Adoption of ProtonCoreNetworking
- TransactionObserver resolves every transactions

### RemoteManager scope simplified
With the adoption of ProtonCoreNetworking the RemoteMangerProviding has been updated. The updated protocol is:
```swift
public protocol RemoteManagerProviding: Sendable {

    func getAvailablePlans() async throws -> AvailablePlans
    func getCurrentPlan() async throws -> CurrentSubscription

    func post(_ token: Token) async throws -> NewToken
    func post(_ token: OCToken) async throws -> NewToken
    func fetch(token: String) async throws -> ResponseStatus

    func getUserUUID() async throws -> UserTransactionUUIDResponse

    func create(newOCSubscription: OCNewSubscription) async throws -> StatusResponse
    func create(newSubscription: NewSubscription) async throws -> StatusResponse

    func checkIAPStatus() async throws -> IAPStatus
}
```
The `RemoteManager` instance implementing it now uses ProtoCoreNetworking.

```swift
    public init(apiService: APIService) {
        self.apiService = apiService
    }
```
The only property expected now is `APIService`

### Adoption of ProtonCoreNetworking
ProtonCoreNetworking has been adopted to better manage specific requirements such as alternative routing and session management.
This adoption simplifies how the library is instantiated.
From ProtonCore 34.2.0 onwards, the main object required is `APIService`.
This replaces the previous parameters:
- sessionId
- token
- appVersion
- doh

```swift
// Initate PaymentsUIViewController on ProtonCore < 34.2.0
    public init(sessionId: String,
                token: String,
                appVersion: String,
                doh: DoHInterface & ServerConfig,
                presentationMode: PresentationMode,
                hideCurrentPlan: Bool)
```

```swift
// Initate PaymentsUIViewController on ProtonCore >= 34.2.0
    public init(apiService: APIService,
                presentationMode: PresentationMode = .none,
                hideCurrentPlan: Bool = false)
```

### TransactionObserver resolves every transactions
The TransactionObserver is now the only object able to resolve any transaction initiated from PaymentsV2.
This change has been made to simplify, and reduce, the number of publishers emitting status changes. 
Any transaction state is not emitted by `transactionProgress` publisher.
This makes it imperative, in order to process a transaction, to start `TransactionObserver` as soon as an authenticated session is valid.
If a transaction is initiated but the observer hasn't been started will result in crash.
 

## Network layer structure
The new payments network layer is structure as follow:
- [Remote Manager](#Remote-Manager)
- [Payments APIs](#Payments-APIs)
- [Models](#models)
    - Requests
    - Response
- [Subscriptions composer](#subscriptions-composer)
- [Transaction handler](#transaction-handler)
- [Proton plans manager](#proton-subscription-manager)
- [Store observer](#storeobserver)

## [Roadmap](#road-map)

## Remote Manager

Remote Manager is tasked with performing basic network requests (GET, PUT, POST, DELETE).
The interface of this class is defined by `RemoteManagerProvider`

```swift
public protocol RemoteManagerProviding: Sendable {

    func updateSession(sessionID: String, authToken: String)

    func getFromURL<T: Decodable>(_ url: URL) async throws -> T

    func postToURL(request: APIRequest) async throws
    func postToURL<T: Decodable>(request: APIRequest) async throws -> T

    func putToURL(request: APIRequest) async throws
    func putToURL<T: Decodable>(request: APIRequest) async throws -> T

    func deleteToURL(request: APIRequest) async throws
    func deleteToURL<T: Decodable>(request: APIRequest) async throws -> T
}
```

To initialize the `RemoteManager` the following parameters are required:
- `SessionID: String`
- `Authentication Token: String`
- `AppVersion: String`
- `AtlasSecret: String?`

These parameters are used to construct the `HTTP Request Header` required for the API requests.

```swift
requestHTTPHeader = [.sessionId: sessionID,
                                 .accept: "application/json",
                                 .contentType: "application/json",
                                 .authorization: "Bearer \(authToken)",
                                 .appVersion: appVersion]
#if DEBUG
            guard let atlasSecret = atlasSecret else {
                return
            }

            requestHTTPHeader[.atlasSecret] = atlasSecret
#endif
```

#### Response handler
Every time a response is received the response body and Proton response code checks are perfomed returning any eventual error.
If the requester is expecting a response type in return, only if both the checks above are successuful, the response is decoded. 


## Multi-session
If there is the necessity to update the remote manager to use a new session, i.e. multi account, this can be done via the `updateSession` function 


## Payments APIs
`PaymentsAPIs` is a data struct enforcing API request structure convention.

At **.init** it requires:
- `doh: DoHInterface & ServerConfig`, this object is used to build any request supported

PaymentsAPI only supports `v5` `payments` endpoints.
The only exception to this are:
- `userTransactionUUID -> "/sessions/uuid"` using `v4`
- `appleStatus -> "/status/apple"` using `v6`

### Generate Request
To generate an APIRequest call:

```swift
func url(for api: RequestType) throws -> APIRequest
```

`APIRequest`
```swift
public struct APIRequest: @unchecked Sendable {
    public let url: URL
    public let body: [String: Any]?
}
```
#### NOTES:
- Enforcing a data type to construct a request would elimitate the possibility of passing a wrong `[String: Any]` to the remote manager. Considering the low number of requests and the possibility to compose different data type via the `Compose` helper this shouldn't add much complexity to the layer or maintanability issues. This approach will also stardardize the process of adding new APIs to the library as well deprecating an old ones.

#### RequestType
Enum describing the type of request

```swift
enum RequestType {
    
    // MARK: Tokens
    case createToken(token: Token)
    case checkToken(token: String)
    
    //...
}
```
This enum provides the request endpoint url and, if required, body for the request the following variables:
- `requestEndpoint: String`
- `body: [String: Any]?`

```swift 
extension RequestType {
    
    var requestEndpoint: String {
        switch self {
        case .createToken(_):
            return "/tokens"
        //...
        }
    }
    
    var body: [String: Any]? {
        switch self {
        case .createToken(let body):
            return body.toDictionary()
        // ..
        }
    }

    var queryComponents: [URLQueryItem]? {
        switch self {
            case .availablePlans(let currency, let vendor, let state, let timestamp):
            let queryParams: [String: Any?] = ["currency": currency,
                                               "vendor": vendor,
                                               "timestamp": timestamp,
                                               "state": state]

            return generateQueryParameters(parameters: queryParams)
        // ..
        }
    }
}
```

#### Currently supported APIs
```swift
    // MARK: Tokens
    case createToken(token: Token)
    case checkToken(token: String)

    // MARK: Subscription
    case getCurrentSubscription
    case createSubscription(newSubscription: NewSubscription)
    case checkSubscription(subscription: Subscription)
    case cancelSubscription(cancelSubscription: CancelSubscription)
    case subscriptionLatest // returns latest cancelled sub check and then delete if not needed
    case changeRenewSubscription(renewSubscription: RenewSubscription)

    // MARK: Payments
    case paymentStatus(vendor: VendorType)
    case appleStatus

    // MARK: Plans
    case availablePlans(currency: String?, vendor: String?, state: Int?, timeStamp: Int?)

    // MARK: Miscellaneous
    case icon(name: String)
    case userTransactionUUID
```

#### NOTES:
The only non-payments API are `icon` (`"/resources/icons/"`) used to fetch remote assets for the `SubscriptionView` and `userTransactionUUID` which returns the UUID for the current active user.
Moving these APIs to a more appropriated module will be discussed in the future.

### APIHeader
String enum type used to define the HTTP header properties required

```swift 
public enum APIHeader: String {
    case setCookie = "set-cookie"
    case authorization = "Authorization"
    case sessionId = "x-pm-uid"
    case appVersion = "x-pm-appversion"
    case apiVersion = "x-pm-apiversion"
    case contentType = "Content-Type"
    case accept = "Accept"
    case userAgent = "User-Agent"
    case retryAfter = "retry-after"
    case atlasSecret = "x-atlas-secret"
}
```

In the same file `APIHeaderError` and `APICodeError` are defined. These are used to return Header and Proton response code errors.

## Models
All the supported data models for request and responses are inside the `Models` folder.

Models used for API requests conform to `DictionaryConvertible`. The combination of `struct` and `DictionaryConvertible` gives the possibility to ensure type-safety and easy the conversion to dictionary needed for API requests.


## PlansComposer
The available plan we display to the user is a combination of StoreKit Product and Proton Plan properties. `PlansComposer` is a class created to facilitate combining the two.

### Interface
```swift
public protocol PlansComposerProviding: Sendable {

    var hasData: Bool { get }
    var mostExpensivePlan: ComposedPlan? { get }
    func getStoreProducts(_ plans: [String]) async throws -> [Product]
    func fetchProtonPlans() async throws -> AvailablePlans
    func matchPlanToStoreProduct(_ productId: String) -> ComposedPlan?
    func fetchAvailablePlans() async throws -> [ComposedPlan]
    func updateRemoteManager(remoteManager: RemoteManagerProviding)
    func fetchCurrentSubscription() async throws -> CurrentSubscriptionResponse
    func availableDiscount(comparedTo plan: ComposedPlan) -> Int?
}
```

#### Functionalities provided:
- Fetch StoreKit Products
- Fetch Proton Plans
- Match Proton Plans with a StoreKit product
- Fetch and generate list of available Subscriptions (`[ComposedSub]`)
- Update the RemoteManager instance
- Return the current active subscription
- Available discount

It's self-sustained, which means it will fetch, if necessary, the data from StoreKit and Proton BE and compose them.
At init time it only requires `RemoteManager` and `PaymentsAPI`.


## Transaction Handler
TransactionHandler has been implemented to handle the full purchase flow.
This flow involves:
- Purchase product via StoreKit
- Create a new subscription on the Proton BE
- Transaction state
- Verify transaction UUID

```swift
public protocol TransactionHandlerProviding: Sendable {
    func processTransaction(_ transaction: ProtonTransaction, plan: ComposedPlan, fail: Bool) async throws -> ComposedPlan
    func updateRemoteManager(remoteManager: RemoteManagerProviding) async
    func verifyTransactionUUIDs(appAccountToken: UUID) async throws -> Bool
}
```

To init the class just provide:
- RemoteManager
- PaymentsAPIs
- ReceiptManager

```swift
public init(remoteManager: RemoteManagerProviding,
            paymentsAPIs: PaymentsAPIs,
            receiptManger: StoreKitReceiptManagerProviding = StoreKitReceiptManager()) {
    }
```

To handle a transaction you need to call this function:
```swift
public func processTransaction(_ transaction: ProtonTransaction, plan: ComposedPlan, fail: Bool = false) async throws -> ComposedPlan
```
Parameters:
- `Transaction` -> ProtonTransaction
- `ComposedPlan` -> Composed plan object
- `fail` -> Fail flag used only during testing

The purchase flow can be seen here -> 
[Confluence - Purchase flow](https://confluence.protontech.ch/pages/viewpage.action?spaceKey=CP&title=Purchase+sequence+diagrams)

### Transaction State
Transaction states are provided via a published property (`Swift Combine`).

```swift
public enum TransactionHandlerState: String, Sendable {
    case idle
    case generatingReceipt
    case creatingTransactionToken
    case createNewSubscription
    case transactionCompleted
    // Error states:
    case transactionCancelledByUser
    case mismatchTransactionIDs
    case transactionProcessError
    case unableToGetUserTransactionUUID
    case unknownError

    public var localizedDescription: String? {
        switch self {
        default:
            return self.rawValue
        }
    }
}
```

To receive and respond to status changes you can subscribe to the exposed publisher:
```swift
private(set) var transactionState = CurrentValueSubject<TransactionHandlerState, Never>(.idle)
```

## Proton Plan Manager
Proton Plan manager is a higher level class provided to manage subscriptions.

### ProtonPlansManagerProviding protocol
```swift
public protocol ProtonPlansManagerProviding: Sendable {

    var transactionProgress: CurrentValueSubject<TransactionHandlerState, Never> { get }
    var countryCode: String? { get async }
    func getProtonPlans() async throws -> AvailablePlans
    func getStoreProducts(_ plans: [String]) async throws -> [Product]
    func getAvailablePlans() async throws -> [ComposedPlan]
    func getCurrentPlan() async throws -> CurrentSubscriptionResponse
    func purchase(_ product: Product, options: Set<Product.PurchaseOption>?) async throws -> ComposedPlan
    func purchaseWinBackOffer(_ product: Product, offerId: String) async throws -> ComposedPlan?
    func recoverTransactionReceipt() async throws
    func updateUserSession(sessionID: String, authToken: String)
    func checkIAPStatus() async throws -> IAPStatus
}
```
It wraps functionalities provided by `PlansComposer` and `TransactionHandler`. 
To create custom payments screens, i.e. the upsell screen, the ProtonPlansManger provides all the necessary APIs.

### Pending transactions
A pending transaction in StoreKit 2 occurs when a purchase requires additional user action, such as parental approval through the "Ask to Buy" feature, or account verification. 
When this happens ProtonPlansManager will throw and error. The error provides a failure reason that explains how the pending transaction will be resolved when the required actions are fulfilled.
Please make sure to handle this case accordingly when implementing a custom screen.

## TransactionsObserver
StoreObserver is a singleton class used to listen to StoreKit updates.
When a transaction is returned by StoreKit, if it's not marked as `finished` or it's a renewal transaction, the observer will try to resolvet it.
To avoid missing any transaction the observer MUST be initialised as soon as a new user's session is created.

### Interface
```swift
public protocol TransactionsObserverProviding: Sendable {
    func start() async throws
    func stop()
    func setConfiguration(_ configuration: TransactionsObserverConfiguration)
    func addTransactionInProgress(_ transactionId: UInt64)
    func removeTransactionInProgress(_ transactionId: UInt64)
    func generateTransactionLog() async -> URL?
    func deleteLogs() async
}
```

To start the observer a configuration (`StoreObserverConfiguration`) needs to be provided
```swift
public struct TransactionsObserverConfiguration: Sendable {
    let sessionID: String
    let authToken: String
    let appVersion: String
    let doh: DoHInterface & ServerConfig
}
```

The configuration can updated at any time if necessary using `setConfiguration`.

To start/stop the observer call:
```swift
func start()
func stop()
```
#### NOTES:
- **Make sure you stop the observer when a user is logged out**
- **If the client supports multi account the observer needs to be stopped and restarted with the new configuration**

## Contributing
Any feedback, contribution or ideas on how to make this project better are always welcome! 

## Authors and acknowledgment
Tiziano Bruni
- [GitLab](https://gitlab.protontech.ch/tbruni)
- [GitHub](https://github.com/Tbruni85)

## License
The code and data files in this distribution are licensed under the terms of the GPLv3 as published by the Free Software Foundation. See https://www.gnu.org/licenses/ for a copy of this license.
Copyright (c) 2023 Proton Technologies AG
