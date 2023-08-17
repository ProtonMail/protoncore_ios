require_relative 'pods_configuration'

Pod::Spec.new do |s|

    s.name             = 'ProtonCore-APIClient'
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
    s.osx.deployment_target = $macos_deployment_target
    
    s.swift_versions = $swift_versions

    s.default_subspecs = :none
    
    s.dependency 'ProtonCore-DataModel', $version
    
    source_files = 'libraries/Networking/Sources/APIClient/**/*.swift'

    test_preserve_paths = 'libraries/Networking/Tests/APIClient/Scripts/*'
    test_source_files = 'libraries/Networking/Tests/APIClient/*.swift', 'libraries/Networking/Tests/APIClient/Mocks/*.swift', 'libraries/Networking/Tests/APIClient/TestData/*.swift'
    test_resource = 'libraries/Networking/Tests/APIClient/TestData/*'

    s.subspec 'AFNetworking' do |afnetworking|
        afnetworking.source_files = source_files
        afnetworking.dependency 'ProtonCore-Networking/AFNetworking', $version
        afnetworking.dependency 'ProtonCore-Services/AFNetworking', $version

        afnetworking.test_spec 'TestsUsingCrypto' do |apiclient_tests|
            apiclient_tests.preserve_paths = test_preserve_paths
            apiclient_tests.source_files = test_source_files
            apiclient_tests.resource = test_resource
            apiclient_tests.dependency 'ProtonCore-Crypto', $version
            apiclient_tests.dependency 'ProtonCore-Authentication/UsingCrypto+AFNetworking', $version
            apiclient_tests.dependency 'ProtonCore-TestingToolkit/UnitTests/Authentication/UsingCrypto+AFNetworking', $version
            apiclient_tests.dependency 'OHHTTPStubs/Swift'
            apiclient_tests.dependency 'TrustKit'    
        end

        afnetworking.test_spec 'TestsUsingCryptoVPN' do |apiclient_tests|
            apiclient_tests.preserve_paths = test_preserve_paths
            apiclient_tests.source_files = test_source_files
            apiclient_tests.resource = test_resource
            apiclient_tests.dependency 'ProtonCore-Crypto-VPN', $version
            apiclient_tests.dependency 'ProtonCore-Authentication/UsingCryptoVPN+AFNetworking', $version
            apiclient_tests.dependency 'ProtonCore-TestingToolkit/UnitTests/Authentication/UsingCryptoVPN+AFNetworking', $version
            apiclient_tests.dependency 'OHHTTPStubs/Swift'
            apiclient_tests.dependency 'TrustKit'    
        end
    end

    s.subspec 'Alamofire' do |alamofire|
        alamofire.source_files = source_files
        alamofire.dependency 'ProtonCore-Networking/Alamofire', $version
        alamofire.dependency 'ProtonCore-Services/Alamofire', $version

        alamofire.test_spec 'TestsUsingCrypto' do |apiclient_tests|
            apiclient_tests.preserve_paths = test_preserve_paths
            apiclient_tests.source_files = test_source_files
            apiclient_tests.resource = test_resource
            apiclient_tests.dependency 'ProtonCore-Crypto', $version
            apiclient_tests.dependency 'ProtonCore-Authentication/UsingCrypto+Alamofire', $version
            apiclient_tests.dependency 'ProtonCore-TestingToolkit/UnitTests/Authentication/UsingCrypto+Alamofire', $version
            apiclient_tests.dependency 'OHHTTPStubs/Swift'
            apiclient_tests.dependency 'TrustKit'    
        end

        alamofire.test_spec 'TestsUsingCryptoVPN' do |apiclient_tests|
            apiclient_tests.preserve_paths = test_preserve_paths
            apiclient_tests.source_files = test_source_files
            apiclient_tests.resource = test_resource
            apiclient_tests.dependency 'ProtonCore-Crypto-VPN', $version
            apiclient_tests.dependency 'ProtonCore-Authentication/UsingCryptoVPN+Alamofire', $version
            apiclient_tests.dependency 'ProtonCore-TestingToolkit/UnitTests/Authentication/UsingCryptoVPN+Alamofire', $version
            apiclient_tests.dependency 'OHHTTPStubs/Swift'
            apiclient_tests.dependency 'TrustKit'    
        end
    end

    s.pod_target_xcconfig = { 'APPLICATION_EXTENSION_API_ONLY' => 'NO' }
        
end
