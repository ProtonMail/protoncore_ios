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
    
    s.dependency 'ProtonCore-APIClient', $version
    s.dependency 'ProtonCore-Log', $version
    s.dependency 'ProtonCore-Services', $version
    s.dependency 'ProtonCore-SRP', $version
    s.dependency 'ProtonCore-CoreTranslation', $version
    s.dependency 'ProtonCore-Foundations', $version

    s.default_subspecs = 'UsingCrypto'

    source_files  = "libraries/Payments/Sources/**/*.swift", "libraries/Payments/Sources/*.swift"

    test_source_files = 'libraries/Payments/Tests/**/*.swift'

    s.subspec 'UsingCrypto' do |crypto|
        crypto.dependency 'ProtonCore-Authentication/UsingCrypto', $version
        crypto.source_files  = source_files
        s.test_spec 'Tests' do |payments_tests|
            payments_tests.dependency 'ProtonCore-TestingToolkit/UnitTests/Payments/UsingCrypto', $version
            payments_tests.source_files = test_source_files
        end
    end
  
    s.subspec 'UsingCryptoVPN' do |crypto_vpn|
        crypto_vpn.dependency 'ProtonCore-Authentication/UsingCryptoVPN', $version
        crypto_vpn.source_files  = source_files
        crypto_vpn.test_spec 'Tests' do |payments_tests|
            payments_tests.dependency 'ProtonCore-TestingToolkit/UnitTests/Payments/UsingCryptoVPN', $version
            payments_tests.source_files = test_source_files
        end
    end
    
    s.dependency 'AwaitKit', '~> 5.2.0'
    s.dependency 'ReachabilitySwift', '~> 5.0.0'

    s.pod_target_xcconfig = { 'APPLICATION_EXTENSION_API_ONLY' => 'NO' }

end
