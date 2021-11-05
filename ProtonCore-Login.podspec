require_relative 'pods_configuration'

Pod::Spec.new do |s|

    s.name             = 'ProtonCore-Login'
    s.version          = $version
    s.summary          = 'shared frameworks'
    
    s.description      = <<-DESC
    ios shared frameworks for all client apps
    DESC
    
    s.homepage         = $homepage
    s.license          = $license
    s.author           = $author
    s.source           = $source
    
    s.ios.deployment_target = $ios_deployment_target
    
    s.swift_versions = $swift_versions

    no_default_subspecs(s)
    
    s.dependency 'ProtonCore-Log', $version
    s.dependency 'ProtonCore-OpenPGP', $version
    s.dependency 'ProtonCore-Foundations', $version
    s.dependency 'ProtonCore-UIFoundations', $version
    s.dependency 'ProtonCore-CoreTranslation', $version
    s.dependency 'ProtonCore-Challenge', $version
    s.dependency 'ProtonCore-DataModel', $version

    source_files  = "libraries/Login/Sources/*.swift", "libraries/Login/Sources/**/*.swift"

    resource_bundles = {
        'PMLogin' => [
            'libraries/Login/Sources/Assets.xcassets', 
            "libraries/Login/Sources/**/*.xib", 
            "libraries/Login/Sources/**/*.storyboard", 
            "libraries/Login/Resources/*"
        ]
    }

    test_source_files = 'libraries/Login/Tests/ObfuscatedConstants.swift', 'libraries/Login/Tests/*.swift', 'libraries/Login/Tests/**/*.swift'
    test_resources = "libraries/Login/Tests/Mocks/Responses/**/*"

    s.subspec 'UsingCrypto+Alamofire' do |crypto|
        crypto.dependency 'ProtonCore-Crypto', $version
        crypto.dependency 'ProtonCore-Authentication/UsingCrypto+Alamofire', $version
        crypto.dependency 'ProtonCore-Authentication-KeyGeneration/UsingCrypto+Alamofire', $version
        crypto.dependency 'ProtonCore-Payments/UsingCrypto+Alamofire', $version
        crypto.dependency 'ProtonCore-PaymentsUI/UsingCrypto+Alamofire', $version
        crypto.dependency 'ProtonCore-HumanVerification/Alamofire', $version
        crypto.source_files = source_files
        crypto.resource_bundles = resource_bundles
        crypto.test_spec 'Tests' do |login_tests|
            login_tests.source_files = test_source_files
            login_tests.resources = test_resources
            login_tests.dependency 'ProtonCore-ObfuscatedConstants', $version
            login_tests.dependency 'ProtonCore-TestingToolkit/UnitTests/Login/UsingCrypto+Alamofire', $version
            login_tests.dependency 'OHHTTPStubs/Swift'
            login_tests.dependency 'TrustKit'
        end
    end

    s.subspec 'UsingCryptoVPN+Alamofire' do |crypto_vpn|
        crypto_vpn.dependency 'ProtonCore-Crypto-VPN', $version
        crypto_vpn.dependency 'ProtonCore-Authentication/UsingCryptoVPN+Alamofire', $version
        crypto_vpn.dependency 'ProtonCore-Authentication-KeyGeneration/UsingCryptoVPN+Alamofire', $version
        crypto_vpn.dependency 'ProtonCore-Payments/UsingCryptoVPN+Alamofire', $version
        crypto_vpn.dependency 'ProtonCore-PaymentsUI/UsingCryptoVPN+Alamofire', $version
        crypto_vpn.dependency 'ProtonCore-HumanVerification/Alamofire', $version
        crypto_vpn.source_files = source_files
        crypto_vpn.resource_bundles = resource_bundles
        crypto_vpn.test_spec 'Tests' do |login_tests|
            login_tests.source_files = test_source_files
            login_tests.resources = test_resources
            login_tests.dependency 'ProtonCore-ObfuscatedConstants', $version
            login_tests.dependency 'ProtonCore-TestingToolkit/UnitTests/Login/UsingCryptoVPN+Alamofire', $version
            login_tests.dependency 'OHHTTPStubs/Swift'
            login_tests.dependency 'TrustKit'
        end
    end

    s.subspec 'UsingCrypto+AFNetworking' do |crypto|
        crypto.dependency 'ProtonCore-Crypto', $version
        crypto.dependency 'ProtonCore-Authentication/UsingCrypto+AFNetworking', $version
        crypto.dependency 'ProtonCore-Authentication-KeyGeneration/UsingCrypto+AFNetworking', $version
        crypto.dependency 'ProtonCore-Payments/UsingCrypto+AFNetworking', $version
        crypto.dependency 'ProtonCore-PaymentsUI/UsingCrypto+AFNetworking', $version
        crypto.dependency 'ProtonCore-HumanVerification/AFNetworking', $version
        crypto.source_files = source_files
        crypto.resource_bundles = resource_bundles
        crypto.test_spec 'Tests' do |login_tests|
            login_tests.source_files = test_source_files
            login_tests.resources = test_resources
            login_tests.dependency 'ProtonCore-ObfuscatedConstants', $version
            login_tests.dependency 'ProtonCore-TestingToolkit/UnitTests/Login/UsingCrypto+AFNetworking', $version
            login_tests.dependency 'OHHTTPStubs/Swift'
            login_tests.dependency 'TrustKit'
        end
    end
  
    s.subspec 'UsingCryptoVPN+AFNetworking' do |crypto_vpn|
        crypto_vpn.dependency 'ProtonCore-Crypto-VPN', $version
        crypto_vpn.dependency 'ProtonCore-Authentication/UsingCryptoVPN+AFNetworking', $version
        crypto_vpn.dependency 'ProtonCore-Authentication-KeyGeneration/UsingCryptoVPN+AFNetworking', $version
        crypto_vpn.dependency 'ProtonCore-Payments/UsingCryptoVPN+AFNetworking', $version
        crypto_vpn.dependency 'ProtonCore-PaymentsUI/UsingCryptoVPN+AFNetworking', $version
        crypto_vpn.dependency 'ProtonCore-HumanVerification/AFNetworking', $version
        crypto_vpn.source_files = source_files
        crypto_vpn.resource_bundles = resource_bundles
        crypto_vpn.test_spec 'Tests' do |login_tests|
            login_tests.source_files = test_source_files
            login_tests.resources = test_resources
            login_tests.dependency 'ProtonCore-ObfuscatedConstants', $version
            login_tests.dependency 'ProtonCore-TestingToolkit/UnitTests/Login/UsingCryptoVPN+AFNetworking', $version
            login_tests.dependency 'OHHTTPStubs/Swift'
            login_tests.dependency 'TrustKit'
        end
    end
    
    s.dependency 'lottie-ios'
    s.dependency 'TrustKit'

    s.framework = 'UIKit'
    s.pod_target_xcconfig = { 'APPLICATION_EXTENSION_API_ONLY' => 'NO' }
            
end
