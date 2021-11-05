require_relative 'pods_configuration'

Pod::Spec.new do |s|
    
    s.name             = 'ProtonCore-Authentication'
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

    no_default_subspecs(s)

    source_files  = "libraries/Authentication/Sources/*.swift", "libraries/Authentication/Sources/**/*.swift"

    test_preserve_paths = 'libraries/Authentication/Scripts/*'

    test_source_files = "libraries/Authentication/Tests/**/*.swift"

    s.subspec 'UsingCrypto+Alamofire' do |crypto|
        crypto.dependency 'ProtonCore-Crypto', $version
        crypto.dependency 'ProtonCore-APIClient/Alamofire', $version
        crypto.dependency 'ProtonCore-Services/Alamofire', $version
        crypto.source_files  = source_files
        crypto.test_spec 'Tests' do |authentication_tests|
            authentication_tests.preserve_paths = test_preserve_paths
            authentication_tests.source_files = test_source_files
            authentication_tests.dependency 'ProtonCore-TestingToolkit/UnitTests/Authentication/UsingCrypto+Alamofire', $version
            authentication_tests.dependency 'OHHTTPStubs/Swift'
        end
    end
  
    s.subspec 'UsingCryptoVPN+Alamofire' do |crypto_vpn|
        crypto_vpn.dependency 'ProtonCore-Crypto-VPN', $version
        crypto_vpn.dependency 'ProtonCore-APIClient/Alamofire', $version
        crypto_vpn.dependency 'ProtonCore-Services/Alamofire', $version
        crypto_vpn.source_files  = source_files
        crypto_vpn.test_spec 'Tests' do |authentication_tests|
            authentication_tests.preserve_paths = test_preserve_paths
            authentication_tests.source_files = test_source_files
            authentication_tests.dependency 'ProtonCore-TestingToolkit/UnitTests/Authentication/UsingCryptoVPN+Alamofire', $version
            authentication_tests.dependency 'OHHTTPStubs/Swift'
        end
    end

    s.subspec 'UsingCrypto+AFNetworking' do |crypto|
        crypto.dependency 'ProtonCore-Crypto', $version
        crypto.dependency 'ProtonCore-APIClient/AFNetworking', $version
        crypto.dependency 'ProtonCore-Services/AFNetworking', $version
        crypto.source_files  = source_files
        crypto.test_spec 'Tests' do |authentication_tests|
            authentication_tests.preserve_paths = test_preserve_paths
            authentication_tests.source_files = test_source_files
            authentication_tests.dependency 'ProtonCore-TestingToolkit/UnitTests/Authentication/UsingCrypto+AFNetworking', $version
            authentication_tests.dependency 'OHHTTPStubs/Swift'
        end
    end
  
    s.subspec 'UsingCryptoVPN+AFNetworking' do |crypto_vpn|
        crypto_vpn.dependency 'ProtonCore-Crypto-VPN', $version
        crypto_vpn.dependency 'ProtonCore-APIClient/AFNetworking', $version
        crypto_vpn.dependency 'ProtonCore-Services/AFNetworking', $version
        crypto_vpn.source_files  = source_files
        crypto_vpn.test_spec 'Tests' do |authentication_tests|
            authentication_tests.preserve_paths = test_preserve_paths
            authentication_tests.source_files = test_source_files
            authentication_tests.dependency 'ProtonCore-TestingToolkit/UnitTests/Authentication/UsingCryptoVPN+AFNetworking', $version
            authentication_tests.dependency 'OHHTTPStubs/Swift'
        end
    end

    s.pod_target_xcconfig = { 'APPLICATION_EXTENSION_API_ONLY' => 'NO' }
        
end
