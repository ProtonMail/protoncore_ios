require_relative 'pods_configuration'

Pod::Spec.new do |s|
    
    s.name             = 'ProtonCore-Authentication-KeyGeneration'
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
    
    s.dependency 'ProtonCore-OpenPGP', $version

    source_files = "libraries/Authentication-KeyGeneration/Sources/*.swift", "libraries/Authentication-KeyGeneration/Sources/**/*.swift"

    test_source_files = "libraries/Authentication-KeyGeneration/Tests/**/*.swift"

    s.subspec 'UsingCrypto+Alamofire' do |crypto|
        crypto.dependency 'ProtonCore-Authentication/UsingCrypto+Alamofire', $version
        crypto.dependency 'ProtonCore-Crypto', $version
        crypto.source_files = source_files

        crypto.test_spec 'Tests' do |authentication_tests|
            authentication_tests.dependency 'ProtonCore-ObfuscatedConstants', $version
            authentication_tests.dependency 'ProtonCore-TestingToolkit/UnitTests/Authentication-KeyGeneration/UsingCrypto+Alamofire', $version
            authentication_tests.dependency 'OHHTTPStubs/Swift'
            authentication_tests.source_files = test_source_files
        end
    end
  
    s.subspec 'UsingCryptoVPN+Alamofire' do |crypto_vpn|
        crypto_vpn.dependency 'ProtonCore-Authentication/UsingCryptoVPN+Alamofire', $version
        crypto_vpn.dependency 'ProtonCore-Crypto-VPN', $version
        crypto_vpn.source_files  = source_files

        crypto_vpn.test_spec 'Tests' do |authentication_tests|
            authentication_tests.dependency 'ProtonCore-ObfuscatedConstants', $version
            authentication_tests.dependency 'ProtonCore-TestingToolkit/UnitTests/Authentication-KeyGeneration/UsingCryptoVPN+Alamofire', $version
            authentication_tests.dependency 'OHHTTPStubs/Swift'
            authentication_tests.source_files = test_source_files
        end
    end

    s.subspec 'UsingCrypto+AFNetworking' do |crypto|
        crypto.dependency 'ProtonCore-Authentication/UsingCrypto+AFNetworking', $version
        crypto.dependency 'ProtonCore-Crypto', $version
        crypto.source_files = source_files

        crypto.test_spec 'Tests' do |authentication_tests|
            authentication_tests.dependency 'ProtonCore-ObfuscatedConstants', $version
            authentication_tests.dependency 'ProtonCore-TestingToolkit/UnitTests/Authentication-KeyGeneration/UsingCrypto+AFNetworking', $version
            authentication_tests.dependency 'OHHTTPStubs/Swift'
            authentication_tests.source_files = test_source_files
        end
    end
  
    s.subspec 'UsingCryptoVPN+AFNetworking' do |crypto_vpn|
        crypto_vpn.dependency 'ProtonCore-Authentication/UsingCryptoVPN+AFNetworking', $version
        crypto_vpn.dependency 'ProtonCore-Crypto-VPN', $version
        crypto_vpn.source_files  = source_files

        crypto_vpn.test_spec 'Tests' do |authentication_tests|
            authentication_tests.dependency 'ProtonCore-ObfuscatedConstants', $version
            authentication_tests.dependency 'ProtonCore-TestingToolkit/UnitTests/Authentication-KeyGeneration/UsingCryptoVPN+AFNetworking', $version
            authentication_tests.dependency 'OHHTTPStubs/Swift'
            authentication_tests.source_files = test_source_files
        end
    end

    s.pod_target_xcconfig = { 'APPLICATION_EXTENSION_API_ONLY' => 'NO' }
        
end
