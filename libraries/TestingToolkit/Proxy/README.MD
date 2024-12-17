# ProxyClient

`ProxyClient` is a Swift-based library designed to interact with mock server configurations, manage static and dynamic routes, and adjust global settings such as latency and bandwidth for testing environments. It provides a clean API for sending requests, handling responses, and managing mock server states.

Related proxy server - https://gitlab.protontech.ch/tpe/mock-proxy

---

## Features

- **Static Mock Routes**:
  - Fetch, add, update, and reset static mock routes.
- **Dynamic Mock Scenarios**:
  - Fetch and add dynamic mock scenarios.
- **Global Settings**:
  - Fetch and configure global latency and bandwidth.
- **Reset Functionality**:
  - Reset all mocks, latency, and bandwidth configurations.
- **SSL Validation Bypass**:
  - Custom delegate for bypassing SSL validation during debugging.

---

## Example Usage

### Fetch Dynamic Mock Scenarios

You can use the `fetchDynamicMockRoutes` method to retrieve the list of dynamic mock scenarios from the server:

```swift
client.fetchDynamicMockRoutes { result in
    switch result {
    case .success(let scenarios):
        print("Fetched scenarios: \(scenarios)")
    case .failure(let error):
        print("Error fetching scenarios: \(error)")
    }
}
```

###  Register a Static Mock Route

```swift
let requestDetails = RequestDetails(exactUrl: ["test/example"], method: "GET")
let responseDetails = ResponseDetails(statusCode: 200, body: AnyCodable(value: "{\"key\": \"value\"}"), headers: AnyCodable(value: ContentType.json.asHeader))
let routeRequest = MockObject(name: "ExampleRoute", enabled: true, updateFile: false, request: requestDetails, response: responseDetails)

client.addStaticMockRoute(route: routeRequest) { result in
    switch result {
    case .success(let route):
        print("Registered route: \(route)")
    case .failure(let error):
        print("Failed to register route: \(error)")
    }
}
```

###  Set and Get Global Bandwidth
To configure and fetch global bandwidth settings:

```swift
let bandwidthInfo = BandwidthInfo(enabled: true, limit: BandwidthLimit.EDGE.speedBytesPerSec)

// Set bandwidth
client.addGlobalBandwidth(bandwidthInfo: bandwidthInfo) { result in
    switch result {
    case .success(let updatedBandwidth):
        print("Updated bandwidth: \(updatedBandwidth)")
    case .failure(let error):
        print("Error setting bandwidth: \(error)")
    }
}

// Fetch bandwidth
client.fetchGlobalBandwidth { result in
    switch result {
    case .success(let bandwidth):
        print("Current bandwidth: \(bandwidth)")
    case .failure(let error):
        print("Error fetching bandwidth: \(error)")
    }
}
```

### Register a Picture as a Static Mock
To register an image as a static mock route:

```swift
let bundle = Bundle(for: Self.self)
let data = bundle.getDataFor(fileName: "IMG_8527.PNG", subdirectory: "Mocks")!

let requestDetails = RequestDetails(exactUrl: ["/images/sample.png"], method: "GET")
let responseDetails = ResponseDetails(statusCode: 200, body: AnyCodable(value: data), headers: AnyCodable(value: ContentType.imagePng.asHeader))
let routeRequest = MockObject(name: "ImageMock", enabled: true, updateFile: false, isRawFileContent: true, request: requestDetails, response: responseDetails)

client.addStaticMockRoute(route: routeRequest) { result in
    switch result {
    case .success(let route):
        print("Image mock registered: \(route)")
    case .failure(let error):
        print("Failed to register image mock: \(error)")
    }
}
```
