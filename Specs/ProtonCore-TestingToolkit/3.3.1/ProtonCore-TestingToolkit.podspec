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

    s.framework = 'XCTest'

    # Required for Xcode 12.5
    s.pod_target_xcconfig = { "ENABLE_TESTING_SEARCH_PATHS" => "YES", "APPLICATION_EXTENSION_API_ONLY" => "NO" }

    s.static_framework = true

    s.subspec 'TestData' do |test_data|
        test_data.dependency 'SwiftOTP', '~> 2.0'
        test_data.dependency 'CryptoSwift', '1.3.1'
        test_data.dependency 'ProtonCore-ObfuscatedConstants', $version
        test_data.source_files = "libraries/TestingToolkit/TestData/**/*.swift"
    end

    s.subspec 'UnitTests' do |unit_tests|

        unit_tests.subspec 'Core' do |core|
            core.source_files = "libraries/TestingToolkit/UnitTests/Core/**/*.swift"
        end

        unit_tests.subspec 'Authentication' do |authentication|

            source_files = "libraries/TestingToolkit/UnitTests/Authentication/**/*.swift"

            authentication.dependency 'ProtonCore-TestingToolkit/UnitTests/Core', $version

            authentication.subspec 'UsingCrypto+Alamofire' do |crypto|
                crypto.dependency 'ProtonCore-Authentication/UsingCrypto+Alamofire', $version
                crypto.dependency 'ProtonCore-TestingToolkit/UnitTests/Services/Alamofire', $version
                crypto.source_files = source_files
            end

            authentication.subspec 'UsingCryptoVPN+Alamofire' do |crypto_vpn|
                crypto_vpn.dependency 'ProtonCore-Authentication/UsingCryptoVPN+Alamofire', $version
                crypto_vpn.dependency 'ProtonCore-TestingToolkit/UnitTests/Services/Alamofire', $version
                crypto_vpn.source_files = source_files
            end

            authentication.subspec 'UsingCrypto+AFNetworking' do |crypto|
                crypto.dependency 'ProtonCore-Authentication/UsingCrypto+AFNetworking', $version
                crypto.dependency 'ProtonCore-TestingToolkit/UnitTests/Services/AFNetworking', $version
                crypto.source_files = source_files
            end

            authentication.subspec 'UsingCryptoVPN+AFNetworking' do |crypto_vpn|
                crypto_vpn.dependency 'ProtonCore-Authentication/UsingCryptoVPN+AFNetworking', $version
                crypto_vpn.dependency 'ProtonCore-TestingToolkit/UnitTests/Services/AFNetworking', $version
                crypto_vpn.source_files = source_files
            end
        end # Authentication

        unit_tests.subspec 'Authentication-KeyGeneration' do |authentication_keygeneration|

            authentication_keygeneration.dependency 'ProtonCore-TestingToolkit/UnitTests/Core', $version

            source_files = "libraries/TestingToolkit/UnitTests/Authentication-KeyGeneration/**/*.swift"

            authentication_keygeneration.subspec 'UsingCrypto+Alamofire' do |crypto|
                crypto.dependency 'ProtonCore-Authentication-KeyGeneration/UsingCrypto+Alamofire', $version
                crypto.dependency 'ProtonCore-TestingToolkit/UnitTests/Services/Alamofire', $version
                crypto.source_files = source_files
            end

            authentication_keygeneration.subspec 'UsingCryptoVPN+Alamofire' do |crypto_vpn|
                crypto_vpn.dependency 'ProtonCore-Authentication-KeyGeneration/UsingCryptoVPN+Alamofire', $version
                crypto_vpn.dependency 'ProtonCore-TestingToolkit/UnitTests/Services/Alamofire', $version
                crypto_vpn.source_files = source_files
            end

            authentication_keygeneration.subspec 'UsingCrypto+AFNetworking' do |crypto|
                crypto.dependency 'ProtonCore-Authentication-KeyGeneration/UsingCrypto+AFNetworking', $version
                crypto.dependency 'ProtonCore-TestingToolkit/UnitTests/Services/AFNetworking', $version
                crypto.source_files = source_files
            end

            authentication_keygeneration.subspec 'UsingCryptoVPN+AFNetworking' do |crypto_vpn|
                crypto_vpn.dependency 'ProtonCore-Authentication-KeyGeneration/UsingCryptoVPN+AFNetworking', $version
                crypto_vpn.dependency 'ProtonCore-TestingToolkit/UnitTests/Services/AFNetworking', $version
                crypto_vpn.source_files = source_files
            end
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

            human_verification.subspec 'AFNetworking' do |afnetworking|
                afnetworking.dependency 'ProtonCore-HumanVerification/AFNetworking', $version
            end

            human_verification.subspec 'Alamofire' do |alamofire|
                alamofire.dependency 'ProtonCore-HumanVerification/Alamofire', $version 
            end
        end # HumanVerification

        unit_tests.subspec 'Login' do |login|

            login.dependency 'ProtonCore-TestingToolkit/UnitTests/Core', $version
            login.dependency 'ProtonCore-TestingToolkit/UnitTests/DataModel', $version

            source_files = "libraries/TestingToolkit/UnitTests/Login/**/*.swift"

            login.subspec 'UsingCrypto+Alamofire' do |crypto|
                crypto.dependency 'ProtonCore-TestingToolkit/UnitTests/Authentication/UsingCrypto+Alamofire', $version
                crypto.dependency 'ProtonCore-Login/UsingCrypto+Alamofire', $version
                crypto.dependency 'ProtonCore-TestingToolkit/UnitTests/HumanVerification/Alamofire', $version
                crypto.dependency 'ProtonCore-TestingToolkit/UnitTests/Services/Alamofire', $version
                crypto.source_files = source_files
            end

            login.subspec 'UsingCryptoVPN+Alamofire' do |crypto_vpn|
                crypto_vpn.dependency 'ProtonCore-TestingToolkit/UnitTests/Authentication/UsingCryptoVPN+Alamofire', $version
                crypto_vpn.dependency 'ProtonCore-Login/UsingCryptoVPN+Alamofire', $version
                crypto_vpn.dependency 'ProtonCore-TestingToolkit/UnitTests/HumanVerification/Alamofire', $version
                crypto_vpn.dependency 'ProtonCore-TestingToolkit/UnitTests/Services/Alamofire', $version
                crypto_vpn.source_files = source_files
            end

            login.subspec 'UsingCrypto+AFNetworking' do |crypto|
                crypto.dependency 'ProtonCore-TestingToolkit/UnitTests/Authentication/UsingCrypto+AFNetworking', $version
                crypto.dependency 'ProtonCore-Login/UsingCrypto+AFNetworking', $version
                crypto.dependency 'ProtonCore-TestingToolkit/UnitTests/HumanVerification/AFNetworking', $version
                crypto.dependency 'ProtonCore-TestingToolkit/UnitTests/Services/AFNetworking', $version
                crypto.source_files = source_files
            end

            login.subspec 'UsingCryptoVPN+AFNetworking' do |crypto_vpn|
                crypto_vpn.dependency 'ProtonCore-TestingToolkit/UnitTests/Authentication/UsingCryptoVPN+AFNetworking', $version
                crypto_vpn.dependency 'ProtonCore-Login/UsingCryptoVPN+AFNetworking', $version
                crypto_vpn.dependency 'ProtonCore-TestingToolkit/UnitTests/HumanVerification/AFNetworking', $version
                crypto_vpn.dependency 'ProtonCore-TestingToolkit/UnitTests/Services/AFNetworking', $version
                crypto_vpn.source_files = source_files
            end
        end # Login

        unit_tests.subspec 'Networking' do |networking|

            networking.dependency 'ProtonCore-TestingToolkit/UnitTests/Core', $version

            source_files = "libraries/TestingToolkit/UnitTests/Networking/**/*.swift"

            networking.subspec 'AFNetworking' do |afnetworking|
                afnetworking.source_files = source_files
                afnetworking.dependency 'ProtonCore-Networking/AFNetworking', $version
            end

            networking.subspec 'Alamofire' do |alamofire|
                alamofire.source_files = source_files
                alamofire.dependency 'ProtonCore-Networking/Alamofire', $version
            end
        end # Networking

        unit_tests.subspec 'Services' do |services|
            services.dependency 'ProtonCore-TestingToolkit/UnitTests/Core', $version
            services.dependency 'ProtonCore-TestingToolkit/UnitTests/DataModel', $version
            services.dependency 'ProtonCore-TestingToolkit/UnitTests/Doh', $version

            source_files = "libraries/TestingToolkit/UnitTests/Services/**/*.swift"

            services.subspec 'AFNetworking' do |afnetworking|
                afnetworking.dependency 'ProtonCore-Services/AFNetworking', $version
                afnetworking.dependency 'ProtonCore-TestingToolkit/UnitTests/Networking/AFNetworking', $version
                afnetworking.source_files = source_files
            end

            services.subspec 'Alamofire' do |alamofire|
                alamofire.dependency 'ProtonCore-Services/Alamofire', $version
                alamofire.dependency 'ProtonCore-TestingToolkit/UnitTests/Networking/Alamofire', $version
                alamofire.source_files = source_files
            end
        end # Services

        unit_tests.subspec 'Payments' do |payments|

            payments.dependency 'ProtonCore-TestingToolkit/UnitTests/Core', $version
            payments.dependency 'OHHTTPStubs/Swift'
            payments.dependency 'PromiseKit'

            source_files = "libraries/TestingToolkit/UnitTests/Payments/**/*.swift"

            payments.subspec 'UsingCrypto+Alamofire' do |crypto|
                crypto.dependency 'ProtonCore-Payments/UsingCrypto+Alamofire', $version
                crypto.source_files = source_files
            end

            payments.subspec 'UsingCryptoVPN+Alamofire' do |crypto_vpn|
                crypto_vpn.dependency 'ProtonCore-Payments/UsingCryptoVPN+Alamofire', $version
                crypto_vpn.source_files = source_files
            end

            payments.subspec 'UsingCrypto+AFNetworking' do |crypto|
                crypto.dependency 'ProtonCore-Payments/UsingCrypto+AFNetworking', $version
                crypto.source_files = source_files
            end

            payments.subspec 'UsingCryptoVPN+AFNetworking' do |crypto_vpn|
                crypto_vpn.dependency 'ProtonCore-Payments/UsingCryptoVPN+AFNetworking', $version
                crypto_vpn.source_files = source_files
            end
        end # Payments
    end # UnitTests

    s.subspec 'UITests' do |ui_tests|

        ui_tests.dependency 'ProtonCore-CoreTranslation', $version
        ui_tests.dependency 'pmtest'

        ui_tests.subspec 'Core' do |core|
            core.dependency 'ProtonCore-Doh', $version
            core.dependency 'ProtonCore-Log', $version

            source_files = "libraries/TestingToolkit/UITests/Core/**/*.swift"

            core.subspec 'AFNetworking' do |afnetworking|
                afnetworking.dependency 'ProtonCore-Networking/AFNetworking', $version
                afnetworking.dependency 'ProtonCore-Services/AFNetworking', $version
                afnetworking.source_files = source_files
            end

            core.subspec 'Alamofire' do |alamofire|
                alamofire.dependency 'ProtonCore-Networking/Alamofire', $version
                alamofire.dependency 'ProtonCore-Services/Alamofire', $version
                alamofire.source_files = source_files
            end
        end # Core

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
