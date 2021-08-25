
require_relative 'pods_configuration'

Pod::Spec.new do |s|
    
    s.name             = 'ProtonCore-PaymentsUI'
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
    
    s.dependency 'ProtonCore-Log', $version
    s.dependency 'ProtonCore-CoreTranslation', $version
    s.dependency 'ProtonCore-Foundations', $version
    s.dependency 'ProtonCore-UIFoundations', $version

    s.default_subspecs = 'UsingCrypto'

    source_files  = "libraries/PaymentsUI/Sources/**/*.swift"
    resource_bundles = {
        'Resources-PaymentsUI' => ['libraries/PaymentsUI/Sources/Assets.xcassets', "libraries/PaymentsUI/Sources/**/*.xib", "libraries/PaymentsUI/Sources/**/*.storyboard"]
    }
    test_source_files = 'libraries/PaymentsUI/Tests/**/*.swift'

    s.subspec 'UsingCrypto' do |crypto|
        crypto.dependency 'ProtonCore-Payments/UsingCrypto', $version
        crypto.source_files = source_files
        crypto.resource_bundles = resource_bundles

        crypto.test_spec 'Tests' do |paymentsui_tests|
            paymentsui_tests.dependency 'ProtonCore-TestingToolkit/UnitTests/Payments/UsingCrypto', $version
            paymentsui_tests.source_files = test_source_files
        end
    end
  
    s.subspec 'UsingCryptoVPN' do |crypto_vpn|
        crypto_vpn.dependency 'ProtonCore-Payments/UsingCryptoVPN', $version
        crypto_vpn.source_files = source_files
        crypto_vpn.resource_bundles = resource_bundles

        crypto_vpn.test_spec 'Tests' do |paymentsui_tests|
            paymentsui_tests.dependency 'ProtonCore-TestingToolkit/UnitTests/Payments/UsingCryptoVPN', $version
            paymentsui_tests.source_files = test_source_files
        end
    end

    s.pod_target_xcconfig = { 'APPLICATION_EXTENSION_API_ONLY' => 'NO' }

end
