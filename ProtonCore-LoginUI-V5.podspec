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

    s.dependency 'lottie-ios'
    s.dependency 'TrustKit'

    make_subspec = ->(spec, crypto, networking) {
        spec.subspec "#{crypto_and_networking_subspec(crypto, networking)}" do |subspec|
            subspec.dependency "#{crypto_module(crypto)}", $version
            subspec.dependency "ProtonCore-Authentication/#{crypto_and_networking_subspec(crypto, networking)}", $version
            subspec.dependency "ProtonCore-Authentication-KeyGeneration/#{crypto_and_networking_subspec(crypto, networking)}", $version
            subspec.dependency "ProtonCore-Login/#{crypto_and_networking_subspec(crypto, networking)}", $version
            subspec.dependency "ProtonCore-Payments/#{crypto_and_networking_subspec(crypto, networking)}", $version
            subspec.dependency "ProtonCore-PaymentsUI-V5/#{crypto_and_networking_subspec(crypto, networking)}", $version
            subspec.dependency "ProtonCore-HumanVerification-V5/#{networking_subspec(networking)}", $version
            subspec.source_files = "libraries/LoginUI/Sources/**/*.swift"
            subspec.exclude_files = "libraries/LoginUI/Sources/ViewControllers/Welcome/WelcomeView.swift",
                                    "libraries/LoginUI/Sources/ViewModels/Signup/LoginUIImages.swift"
            subspec.resource_bundles = {
                'Resources-LoginUI' => [
                    "libraries/LoginUI/Sources/**/*.xib", 
                    "libraries/LoginUI/Sources/**/*.storyboard", 
                    "libraries/LoginUI/Resources/sign-up-create-account-V5.json"
                ]
            }
        end
    }

    no_default_subspecs(s)
    make_subspec.call(s, :crypto, :alamofire)
    make_subspec.call(s, :crypto, :afnetworking)
    make_subspec.call(s, :crypto_vpn, :alamofire)
    make_subspec.call(s, :crypto_vpn, :afnetworking)

    make_test_subspec = ->(spec, crypto, networking) {
        spec.test_spec "Tests#{crypto_and_networking_subspec(crypto, networking)}" do |test_spec|
            test_spec.dependency "#{crypto_module(crypto)}", $version
            test_spec.dependency "ProtonCore-Authentication/#{crypto_and_networking_subspec(crypto, networking)}", $version
            test_spec.dependency "ProtonCore-Authentication-KeyGeneration/#{crypto_and_networking_subspec(crypto, networking)}", $version
            test_spec.dependency "ProtonCore-Login/#{crypto_and_networking_subspec(crypto, networking)}", $version
            test_spec.dependency "ProtonCore-Payments/#{crypto_and_networking_subspec(crypto, networking)}", $version
            test_spec.dependency "ProtonCore-PaymentsUI-V5/#{crypto_and_networking_subspec(crypto, networking)}", $version
            test_spec.dependency "ProtonCore-HumanVerification-V5/#{networking_subspec(networking)}", $version
            test_spec.dependency "ProtonCore-ObfuscatedConstants", $version
            test_spec.dependency "ProtonCore-TestingToolkit/TestData/#{networking_subspec(networking)}", $version
            test_spec.dependency "ProtonCore-TestingToolkit/UnitTests/LoginUI-V5/#{crypto_and_networking_subspec(crypto, networking)}", $version
            test_spec.dependency "OHHTTPStubs/Swift"
            test_spec.dependency "TrustKit"
            test_spec.source_files = 'libraries/LoginUI/Tests/**/*.swift'
            test_spec.resources = "libraries/LoginUI/Tests/Mocks/Responses/**/*"
        end
    }

    make_test_subspec.call(s, :crypto, :alamofire)
    make_test_subspec.call(s, :crypto, :afnetworking)
    make_test_subspec.call(s, :crypto_vpn, :alamofire)
    make_test_subspec.call(s, :crypto_vpn, :afnetworking)
            
end
