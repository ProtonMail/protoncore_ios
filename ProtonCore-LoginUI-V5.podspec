require_relative 'pods_configuration'

Pod::Spec.new do |s|

    s.name             = 'ProtonCore-LoginUI-V5'
    s.module_name      = 'ProtonCore_LoginUI'
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
    s.dependency 'ProtonCore-OpenPGP', $version
    s.dependency 'ProtonCore-Foundations', $version
    s.dependency 'ProtonCore-UIFoundations-V5', $version
    s.dependency 'ProtonCore-CoreTranslation', $version
    s.dependency 'ProtonCore-Challenge', $version
    s.dependency 'ProtonCore-DataModel', $version
    s.dependency 'ProtonCore-TroubleShooting', $version
    s.dependency 'ProtonCore-Environment', $version

    s.dependency 'lottie-ios', '3.4.3'
    s.dependency 'TrustKit'

    make_subspec = ->(spec, crypto) {
        spec.subspec "#{crypto_subspec(crypto)}" do |subspec|
            subspec.dependency "#{crypto_module(crypto)}", $version
            subspec.dependency "ProtonCore-Authentication/#{crypto_subspec(crypto)}", $version
            subspec.dependency "ProtonCore-Authentication-KeyGeneration/#{crypto_subspec(crypto)}", $version
            subspec.dependency "ProtonCore-Login/#{crypto_subspec(crypto)}", $version
            subspec.dependency "ProtonCore-Payments/#{crypto_subspec(crypto)}", $version
            subspec.dependency "ProtonCore-PaymentsUI-V5/#{crypto_subspec(crypto)}", $version
            subspec.dependency "ProtonCore-HumanVerification-V5", $version
            subspec.source_files = "libraries/LoginUI/Sources/**/*.swift"
            subspec.resource_bundles = {
                'Resources-LoginUI' => [
                    "libraries/LoginUI/Sources/**/*.xib", 
                    "libraries/LoginUI/Sources/**/*.storyboard", 
                    "libraries/LoginUI/Resources/**/*.json"
                ]
            }
        end
    }

    make_all_go_variants(make_subspec, s)

    no_default_subspecs(s)

    make_test_subspec = ->(spec, crypto) {
        spec.test_spec "#{crypto_test_subspec(crypto)}" do |test_spec|
            test_spec.dependency "#{crypto_module(crypto)}", $version
            test_spec.dependency "ProtonCore-Authentication/#{crypto_subspec(crypto)}", $version
            test_spec.dependency "ProtonCore-Authentication-KeyGeneration/#{crypto_subspec(crypto)}", $version
            test_spec.dependency "ProtonCore-Login/#{crypto_subspec(crypto)}", $version
            test_spec.dependency "ProtonCore-Payments/#{crypto_subspec(crypto)}", $version
            test_spec.dependency "ProtonCore-PaymentsUI-V5/#{crypto_subspec(crypto)}", $version
            test_spec.dependency "ProtonCore-HumanVerification-V5", $version
            test_spec.dependency "ProtonCore-ObfuscatedConstants", $version
            test_spec.dependency "ProtonCore-TestingToolkit/UnitTests/Core", $version
            test_spec.dependency "ProtonCore-TestingToolkit/TestData", $version
            test_spec.dependency "ProtonCore-TestingToolkit/UnitTests/LoginUI-V5/#{crypto_subspec(crypto)}", $version
            test_spec.dependency "OHHTTPStubs/Swift"
            test_spec.dependency "TrustKit"
            test_spec.source_files = 'libraries/LoginUI/Tests/**/*.swift'
            test_spec.resources = "libraries/LoginUI/Tests/Mocks/Responses/**/*"
        end
    }

    make_all_go_variants(make_test_subspec, s)
            
end
