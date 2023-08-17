require_relative 'pods_configuration'

Pod::Spec.new do |s|

    s.name             = 'ProtonCore-TestingToolkit'
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

    s.pod_target_xcconfig = { 
        "ENABLE_TESTING_SEARCH_PATHS" => "YES", # Required for Xcode 12.5
        "APPLICATION_EXTENSION_API_ONLY" => "NO" 
    }

    s.framework = 'XCTest'

    s.static_framework = true

    s.subspec 'TestData' do |test_data|
        test_data.dependency 'SwiftOTP', '~> 2.0'
        test_data.dependency 'CryptoSwift', '1.3.1'
        test_data.dependency 'ProtonCore-DataModel', $version
        test_data.dependency 'ProtonCore-ObfuscatedConstants', $version

        make_subspec = ->(spec, networking) {
            spec.subspec "#{networking_subspec(networking)}" do |subspec|
                subspec.dependency "ProtonCore-Networking/#{networking_subspec(networking)}", $version
                subspec.source_files = "libraries/TestingToolkit/TestData/**/*.swift"
            end
        }

        make_subspec.call(test_data, :alamofire)
        make_subspec.call(test_data, :afnetworking)
    end

    s.subspec 'UnitTests' do |unit_tests|

        unit_tests.subspec 'Core' do |core|
            core.source_files = "libraries/TestingToolkit/UnitTests/Core/**/*.swift"
        end

        unit_tests.subspec 'AccountDeletion' do |account_deletion|
            account_deletion.dependency 'ProtonCore-TestingToolkit/UnitTests/Core', $version

            make_subspec = ->(spec, crypto, networking) {
                spec.subspec "#{crypto_and_networking_subspec(crypto, networking)}" do |subspec|
                    subspec.dependency "ProtonCore-AccountDeletion/#{crypto_and_networking_subspec(crypto, networking)}", $version
                    subspec.dependency "ProtonCore-TestingToolkit/UnitTests/Networking/#{networking_subspec(networking)}", $version
                    subspec.source_files = "libraries/TestingToolkit/UnitTests/AccountDeletion/**/*.swift"
                end
            }

            make_subspec.call(account_deletion, :crypto, :alamofire)
            make_subspec.call(account_deletion, :crypto, :afnetworking)
            make_subspec.call(account_deletion, :crypto_vpn, :alamofire)
            make_subspec.call(account_deletion, :crypto_vpn, :afnetworking)
        end # AccountDeletion

        unit_tests.subspec 'AccountDeletion-V5' do |account_deletion|
            account_deletion.dependency 'ProtonCore-TestingToolkit/UnitTests/Core', $version

            make_subspec = ->(spec, crypto, networking) {
                spec.subspec "#{crypto_and_networking_subspec(crypto, networking)}" do |subspec|
                    subspec.dependency "ProtonCore-AccountDeletion-V5/#{crypto_and_networking_subspec(crypto, networking)}", $version
                    subspec.dependency "ProtonCore-TestingToolkit/UnitTests/Networking/#{networking_subspec(networking)}", $version
                    subspec.source_files = "libraries/TestingToolkit/UnitTests/AccountDeletion/**/*.swift"
                end
            }

            make_subspec.call(account_deletion, :crypto, :alamofire)
            make_subspec.call(account_deletion, :crypto, :afnetworking)
            make_subspec.call(account_deletion, :crypto_vpn, :alamofire)
            make_subspec.call(account_deletion, :crypto_vpn, :afnetworking)
        end # AccountDeletion-V5

        unit_tests.subspec 'Authentication' do |authentication|
            authentication.dependency 'ProtonCore-TestingToolkit/UnitTests/Core', $version

            make_subspec = ->(spec, crypto, networking) {
                spec.subspec "#{crypto_and_networking_subspec(crypto, networking)}" do |subspec|
                    subspec.dependency "ProtonCore-Authentication/#{crypto_and_networking_subspec(crypto, networking)}", $version
                    subspec.dependency "ProtonCore-TestingToolkit/UnitTests/Services/#{networking_subspec(networking)}", $version
                    subspec.source_files = "libraries/TestingToolkit/UnitTests/Authentication/**/*.swift"
                end
            }

            make_subspec.call(authentication, :crypto, :alamofire)
            make_subspec.call(authentication, :crypto, :afnetworking)
            make_subspec.call(authentication, :crypto_vpn, :alamofire)
            make_subspec.call(authentication, :crypto_vpn, :afnetworking)
        end # Authentication

        unit_tests.subspec 'Authentication-KeyGeneration' do |authentication_keygeneration|
            authentication_keygeneration.dependency 'ProtonCore-TestingToolkit/UnitTests/Core', $version

            make_subspec = ->(spec, crypto, networking) {
                spec.subspec "#{crypto_and_networking_subspec(crypto, networking)}" do |subspec|
                    subspec.dependency "ProtonCore-Authentication-KeyGeneration/#{crypto_and_networking_subspec(crypto, networking)}", $version
                    subspec.dependency "ProtonCore-TestingToolkit/UnitTests/Services/#{networking_subspec(networking)}", $version
                    subspec.source_files = "libraries/TestingToolkit/UnitTests/Authentication-KeyGeneration/**/*.swift"
                end
            }

            make_subspec.call(authentication_keygeneration, :crypto, :alamofire)
            make_subspec.call(authentication_keygeneration, :crypto, :afnetworking)
            make_subspec.call(authentication_keygeneration, :crypto_vpn, :alamofire)
            make_subspec.call(authentication_keygeneration, :crypto_vpn, :afnetworking)
        end # Authentication-KeyGeneration

        unit_tests.subspec 'DataModel' do |data_model|
            data_model.dependency 'ProtonCore-TestingToolkit/UnitTests/Core', $version
            data_model.dependency 'ProtonCore-DataModel', $version
            data_model.source_files = "libraries/TestingToolkit/UnitTests/DataModel/**/*.swift"
        end # DataModel

        unit_tests.subspec 'Doh' do |doh|
            doh.dependency 'ProtonCore-TestingToolkit/UnitTests/Core', $version
            doh.dependency 'ProtonCore-Doh', $version
            doh.source_files = "libraries/TestingToolkit/UnitTests/Doh/**/*.swift"
        end # Doh

        unit_tests.subspec 'HumanVerification' do |human_verification|
            human_verification.dependency 'ProtonCore-TestingToolkit/UnitTests/Core', $version

            make_subspec = ->(spec, networking) {
                spec.subspec "#{networking_subspec(networking)}" do |subspec|
                    subspec.dependency "ProtonCore-HumanVerification/#{networking_subspec(networking)}", $version 
                end
            }

            make_subspec.call(human_verification, :alamofire)
            make_subspec.call(human_verification, :afnetworking)
        end # HumanVerification

        unit_tests.subspec 'HumanVerification-V5' do |human_verification|
            human_verification.dependency 'ProtonCore-TestingToolkit/UnitTests/Core', $version

            make_subspec = ->(spec, networking) {
                spec.subspec "#{networking_subspec(networking)}" do |subspec|
                    subspec.dependency "ProtonCore-HumanVerification-V5/#{networking_subspec(networking)}", $version 
                end
            }

            make_subspec.call(human_verification, :alamofire)
            make_subspec.call(human_verification, :afnetworking)
        end # HumanVerification-V5

        unit_tests.subspec 'Login' do |login|
            login.dependency 'ProtonCore-TestingToolkit/UnitTests/Core', $version
            login.dependency 'ProtonCore-TestingToolkit/UnitTests/DataModel', $version

            make_subspec = ->(spec, crypto, networking) {
                spec.subspec "#{crypto_and_networking_subspec(crypto, networking)}" do |subspec|
                    subspec.dependency "ProtonCore-TestingToolkit/UnitTests/Authentication/#{crypto_and_networking_subspec(crypto, networking)}", $version
                    subspec.dependency "ProtonCore-Login/#{crypto_and_networking_subspec(crypto, networking)}", $version
                    subspec.dependency "ProtonCore-TestingToolkit/UnitTests/Services/#{networking_subspec(networking)}", $version
                    subspec.source_files = "libraries/TestingToolkit/UnitTests/Login/**/*.swift"
                end
            }

            make_subspec.call(login, :crypto, :alamofire)
            make_subspec.call(login, :crypto, :afnetworking)
            make_subspec.call(login, :crypto_vpn, :alamofire)
            make_subspec.call(login, :crypto_vpn, :afnetworking)
        end # Login

        unit_tests.subspec 'LoginUI' do |loginui|
            loginui.dependency 'ProtonCore-TestingToolkit/UnitTests/Core', $version
            loginui.dependency 'ProtonCore-TestingToolkit/UnitTests/DataModel', $version

            make_subspec = ->(spec, crypto, networking) {
                spec.subspec "#{crypto_and_networking_subspec(crypto, networking)}" do |subspec|
                    subspec.dependency "ProtonCore-TestingToolkit/UnitTests/Authentication/#{crypto_and_networking_subspec(crypto, networking)}", $version
                    subspec.dependency "ProtonCore-LoginUI/#{crypto_and_networking_subspec(crypto, networking)}", $version
                    subspec.dependency "ProtonCore-TestingToolkit/UnitTests/HumanVerification/#{networking_subspec(networking)}", $version
                    subspec.dependency "ProtonCore-TestingToolkit/UnitTests/Login/#{crypto_and_networking_subspec(crypto, networking)}", $version
                    subspec.dependency "ProtonCore-TestingToolkit/UnitTests/Services/#{networking_subspec(networking)}", $version
                    subspec.source_files = "libraries/TestingToolkit/UnitTests/LoginUI/**/*.swift"
                end
            }

            make_subspec.call(loginui, :crypto, :alamofire)
            make_subspec.call(loginui, :crypto, :afnetworking)
            make_subspec.call(loginui, :crypto_vpn, :alamofire)
            make_subspec.call(loginui, :crypto_vpn, :afnetworking)
        end # LoginUI

        unit_tests.subspec 'LoginUI-V5' do |loginui|
            loginui.dependency 'ProtonCore-TestingToolkit/UnitTests/Core', $version
            loginui.dependency 'ProtonCore-TestingToolkit/UnitTests/DataModel', $version

            make_subspec = ->(spec, crypto, networking) {
                spec.subspec "#{crypto_and_networking_subspec(crypto, networking)}" do |subspec|
                    subspec.dependency "ProtonCore-TestingToolkit/UnitTests/Authentication/#{crypto_and_networking_subspec(crypto, networking)}", $version
                    subspec.dependency "ProtonCore-LoginUI-V5/#{crypto_and_networking_subspec(crypto, networking)}", $version
                    subspec.dependency "ProtonCore-TestingToolkit/UnitTests/HumanVerification-V5/#{networking_subspec(networking)}", $version
                    subspec.dependency "ProtonCore-TestingToolkit/UnitTests/Login/#{crypto_and_networking_subspec(crypto, networking)}", $version
                    subspec.dependency "ProtonCore-TestingToolkit/UnitTests/Services/#{networking_subspec(networking)}", $version
                    subspec.source_files = "libraries/TestingToolkit/UnitTests/LoginUI/**/*.swift"
                end
            }

            make_subspec.call(loginui, :crypto, :alamofire)
            make_subspec.call(loginui, :crypto, :afnetworking)
            make_subspec.call(loginui, :crypto_vpn, :alamofire)
            make_subspec.call(loginui, :crypto_vpn, :afnetworking)
        end # LoginUI

        unit_tests.subspec 'Networking' do |networking|
            networking.dependency 'ProtonCore-TestingToolkit/UnitTests/Core', $version

            make_subspec = ->(spec, networking) {
                spec.subspec "#{networking_subspec(networking)}" do |subspec|
                    subspec.source_files = "libraries/TestingToolkit/UnitTests/Networking/**/*.swift"
                    subspec.dependency "ProtonCore-Networking/#{networking_subspec(networking)}", $version
                end
            }

            make_subspec.call(networking, :alamofire)
            make_subspec.call(networking, :afnetworking)
        end # Networking

        unit_tests.subspec 'Services' do |services|
            services.dependency 'ProtonCore-TestingToolkit/UnitTests/Core', $version
            services.dependency 'ProtonCore-TestingToolkit/UnitTests/DataModel', $version
            services.dependency 'ProtonCore-TestingToolkit/UnitTests/Doh', $version

            make_subspec = ->(spec, networking) {
                spec.subspec "#{networking_subspec(networking)}" do |subspec|
                    subspec.dependency "ProtonCore-Services/#{networking_subspec(networking)}", $version
                    subspec.dependency "ProtonCore-TestingToolkit/UnitTests/Networking/#{networking_subspec(networking)}", $version
                    subspec.source_files = "libraries/TestingToolkit/UnitTests/Services/**/*.swift"
                end
            }

            make_subspec.call(services, :alamofire)
            make_subspec.call(services, :afnetworking)
        end # Services

        unit_tests.subspec 'Payments' do |payments|
            payments.dependency 'ProtonCore-TestingToolkit/UnitTests/Core', $version
            payments.dependency 'OHHTTPStubs/Swift'

            make_subspec = ->(spec, crypto, networking) {
                spec.subspec "#{crypto_and_networking_subspec(crypto, networking)}" do |subspec|
                    subspec.dependency "ProtonCore-Payments/#{crypto_and_networking_subspec(crypto, networking)}", $version
                    subspec.source_files = "libraries/TestingToolkit/UnitTests/Payments/**/*.swift"
                end
            }

            make_subspec.call(payments, :crypto, :alamofire)
            make_subspec.call(payments, :crypto, :afnetworking)
            make_subspec.call(payments, :crypto_vpn, :alamofire)
            make_subspec.call(payments, :crypto_vpn, :afnetworking)
        end # Payments
    end # UnitTests

    s.subspec 'UITests' do |ui_tests|

        ui_tests.dependency 'ProtonCore-CoreTranslation', $version
        ui_tests.dependency 'pmtest'

        ui_tests.subspec 'Core' do |core|
            core.dependency 'ProtonCore-Log', $version
            core.source_files = "libraries/TestingToolkit/UITests/Core/**/*.swift"
        end # Core

        ui_tests.subspec 'AccountDeletion' do |account_deletion|
            account_deletion.source_files = "libraries/TestingToolkit/UITests/AccountDeletion/**/*.swift"
        end # AccountDeletion

        ui_tests.subspec 'AccountSwitcher' do |account_switcher|
            account_switcher.source_files = "libraries/TestingToolkit/UITests/AccountSwitcher/**/*.swift"
        end # AccountSwitcher

        ui_tests.subspec 'HumanVerification' do |human_verification|
            human_verification.source_files = "libraries/TestingToolkit/UITests/HumanVerification/**/*.swift"
        end # HumanVerification

        ui_tests.subspec 'Login' do |login|
            login.source_files = "libraries/TestingToolkit/UITests/Login/**/*.swift"
        end # Login

        ui_tests.subspec 'PaymentsUI' do |payments_ui|
            payments_ui.source_files = "libraries/TestingToolkit/UITests/PaymentsUI/**/*.swift"
        end # PaymentsUI
    end # UITests

end
