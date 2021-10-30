require_relative 'pods_configuration'

Pod::Spec.new do |s|
    
    s.name             = 'ProtonCore-Payments'
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

    s.dependency 'AwaitKit', '~> 5.2.0'
    s.dependency 'ReachabilitySwift', '~> 5.0.0'
    
    s.dependency 'ProtonCore-Log', $version
    s.dependency 'ProtonCore-SRP', $version
    s.dependency 'ProtonCore-CoreTranslation', $version
    s.dependency 'ProtonCore-Foundations', $version

    s.default_subspecs = :none

    source_files  = "libraries/Payments/Sources/**/*.swift", "libraries/Payments/Sources/*.swift"

    test_source_files = 'libraries/Payments/Tests/**/*.swift'

    s.subspec 'UsingCrypto+Alamofire' do |crypto|
        crypto.dependency 'ProtonCore-Authentication/UsingCrypto+Alamofire', $version
        crypto.dependency 'ProtonCore-Services/Alamofire', $version
        crypto.source_files  = source_files
        crypto.test_spec 'Tests' do |payments_tests|
            payments_tests.dependency 'ProtonCore-TestingToolkit/UnitTests/Payments/UsingCrypto+Alamofire', $version
            payments_tests.source_files = test_source_files
        end
    end
  
    s.subspec 'UsingCryptoVPN+Alamofire' do |crypto_vpn|
        crypto_vpn.dependency 'ProtonCore-Authentication/UsingCryptoVPN+Alamofire', $version
        crypto_vpn.dependency 'ProtonCore-Services/Alamofire', $version
        crypto_vpn.source_files  = source_files
        crypto_vpn.test_spec 'Tests' do |payments_tests|
            payments_tests.dependency 'ProtonCore-TestingToolkit/UnitTests/Payments/UsingCryptoVPN+Alamofire', $version
            payments_tests.source_files = test_source_files
        end
    end

    s.subspec 'UsingCrypto+AFNetworking' do |crypto|
        crypto.dependency 'ProtonCore-Authentication/UsingCrypto+AFNetworking', $version
        crypto.dependency 'ProtonCore-Services/AFNetworking', $version
        crypto.source_files  = source_files
        crypto.test_spec 'Tests' do |payments_tests|
            payments_tests.dependency 'ProtonCore-TestingToolkit/UnitTests/Payments/UsingCrypto+AFNetworking', $version
            payments_tests.source_files = test_source_files
        end
    end
  
    s.subspec 'UsingCryptoVPN+AFNetworking' do |crypto_vpn|
        crypto_vpn.dependency 'ProtonCore-Authentication/UsingCryptoVPN+AFNetworking', $version
        crypto_vpn.dependency 'ProtonCore-Services/AFNetworking', $version
        crypto_vpn.source_files  = source_files
        crypto_vpn.test_spec 'Tests' do |payments_tests|
            payments_tests.dependency 'ProtonCore-TestingToolkit/UnitTests/Payments/UsingCryptoVPN+AFNetworking', $version
            payments_tests.source_files = test_source_files
        end
    end

    s.pod_target_xcconfig = { 'APPLICATION_EXTENSION_API_ONLY' => 'NO' }

end
