require_relative 'pods_configuration'

Pod::Spec.new do |s|

    s.name             = 'ProtonCore-LoginUI'
    s.module_name      = 'ProtonCoreLoginUI'
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

    s.pod_target_xcconfig = { 'APPLICATION_EXTENSION_API_ONLY' => 'NO' }

    s.framework = 'UIKit'
    
    s.dependency 'ProtonCore-Log', $version
    s.dependency 'ProtonCore-Foundations', $version
    s.dependency 'ProtonCore-UIFoundations', $version
    s.dependency 'ProtonCore-Challenge', $version
    s.dependency 'ProtonCore-DataModel', $version
    s.dependency 'ProtonCore-TroubleShooting', $version
    s.dependency 'ProtonCore-Environment', $version
    s.dependency 'ProtonCore-Observability', $version
    s.dependency "ProtonCore-Crypto", $version
    s.dependency "ProtonCore-CryptoGoInterface", $version
    s.dependency "ProtonCore-Authentication", $version
    s.dependency "ProtonCore-Authentication-KeyGeneration", $version
    s.dependency "ProtonCore-Login", $version
    s.dependency "ProtonCore-Payments", $version
    s.dependency "ProtonCore-PaymentsUI", $version
    s.dependency "ProtonCore-HumanVerification", $version

    s.dependency 'lottie-ios', '3.4.3'
    s.dependency 'TrustKit'

    s.source_files = "libraries/LoginUI/Sources/**/*.swift"
    
    s.resource_bundles = {
        'Resources-LoginUI' => [
            "libraries/LoginUI/Resources/**/*.{xib,storyboard,json}"
        ],
        'Translations-LoginUI' => [
            "libraries/LoginUI/Sources/Resources/Translations/*"
        ]
    }

    this_pod_does_not_have_subspecs(s)

    make_unit_test_subspec = ->(spec, crypto) {
        spec.test_spec "Unit#{crypto_test_subspec(crypto)}" do |test_spec|
            test_spec.dependency "ProtonCore-Crypto", $version
            test_spec.dependency "ProtonCore-CryptoGoInterface", $version
            test_spec.dependency "ProtonCore-CryptoGoImplementation/#{crypto_subspec(crypto)}", $version
            test_spec.dependency "ProtonCore-Authentication", $version
            test_spec.dependency "ProtonCore-Authentication-KeyGeneration", $version
            test_spec.dependency "ProtonCore-Login", $version
            test_spec.dependency "ProtonCore-Payments", $version
            test_spec.dependency "ProtonCore-PaymentsUI", $version
            test_spec.dependency "ProtonCore-HumanVerification", $version
            test_spec.dependency "ProtonCore-ObfuscatedConstants", $version
            test_spec.dependency "ProtonCore-TestingToolkit/UnitTests/Core", $version
            test_spec.dependency "ProtonCore-TestingToolkit/TestData", $version
            test_spec.dependency "ProtonCore-TestingToolkit/UnitTests/LoginUI", $version
            test_spec.dependency "ProtonCore-TestingToolkit/UnitTests/Observability", $version
            test_spec.dependency "OHHTTPStubs/Swift"
            test_spec.dependency "TrustKit"
            test_spec.source_files = 'libraries/LoginUI/Tests/UnitTests/**/*.swift'
            test_spec.resources = "libraries/LoginUI/Tests/UnitTests/**/*.json"
        end
    }

    make_all_go_variants(make_unit_test_subspec, s)

    make_integration_test_subspec = ->(spec, crypto) {
        spec.test_spec "Integration#{crypto_test_subspec(crypto)}" do |test_spec|
            test_spec.dependency "ProtonCore-Crypto", $version
            test_spec.dependency "ProtonCore-CryptoGoInterface", $version
            test_spec.dependency "ProtonCore-CryptoGoImplementation/#{crypto_subspec(crypto)}", $version
            test_spec.dependency "ProtonCore-Authentication", $version
            test_spec.dependency "ProtonCore-Authentication-KeyGeneration", $version
            test_spec.dependency "ProtonCore-Login", $version
            test_spec.dependency "ProtonCore-Payments", $version
            test_spec.dependency "ProtonCore-PaymentsUI", $version
            test_spec.dependency "ProtonCore-HumanVerification", $version
            test_spec.dependency "ProtonCore-ObfuscatedConstants", $version
            test_spec.dependency "ProtonCore-TestingToolkit/UnitTests/Core", $version
            test_spec.dependency "ProtonCore-TestingToolkit/TestData", $version
            test_spec.dependency "ProtonCore-TestingToolkit/UnitTests/LoginUI", $version
            test_spec.dependency "TrustKit"
            test_spec.source_files = 'libraries/LoginUI/Tests/IntegrationTests/**/*.swift'

            add_dynamic_domain_to_info_plist(test_spec)
        end
    }

    make_all_go_variants(make_integration_test_subspec, s)
            
end
