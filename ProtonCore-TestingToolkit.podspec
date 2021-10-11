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

    s.default_subspecs = "UnitTests/Core"

    s.framework = 'XCTest'

    s.pod_target_xcconfig = {
     "ENABLE_TESTING_SEARCH_PATHS" => "YES" # Required for Xcode 12.5
    }

    s.static_framework = true

    s.subspec 'UnitTests' do |unit_tests|

        unit_tests.subspec 'Core' do |core|
            core.source_files = "libraries/TestingToolkit/UnitTests/Core/**/*.swift"
        end

        unit_tests.subspec 'Authentication' do |authentication|

            source_files = "libraries/TestingToolkit/UnitTests/Authentication/**/*.swift"

            authentication.dependency 'ProtonCore-TestingToolkit/UnitTests/Core', $version
            authentication.dependency 'ProtonCore-TestingToolkit/UnitTests/Services', $version

            authentication.subspec 'UsingCrypto' do |crypto|
                crypto.dependency 'ProtonCore-Authentication', $version
                crypto.source_files = source_files
            end

            authentication.subspec 'UsingCryptoVPN' do |crypto_vpn|
                crypto_vpn.dependency 'ProtonCore-Authentication/UsingCryptoVPN', $version
                crypto_vpn.source_files = source_files
            end
        end

        unit_tests.subspec 'Authentication-KeyGeneration' do |authentication_keygeneration|

            source_files = "libraries/TestingToolkit/UnitTests/Authentication-KeyGeneration/**/*.swift"

            authentication_keygeneration.dependency 'ProtonCore-TestingToolkit/UnitTests/Core', $version
            authentication_keygeneration.dependency 'ProtonCore-TestingToolkit/UnitTests/Services', $version

            authentication_keygeneration.subspec 'UsingCrypto' do |crypto|
                crypto.dependency 'ProtonCore-Authentication-KeyGeneration', $version
                crypto.source_files = source_files
            end

            authentication_keygeneration.subspec 'UsingCryptoVPN' do |crypto_vpn|
                crypto_vpn.dependency 'ProtonCore-Authentication-KeyGeneration/UsingCryptoVPN', $version
                crypto_vpn.source_files = source_files
            end
        end

        unit_tests.subspec 'DataModel' do |data_model|
            data_model.dependency 'ProtonCore-TestingToolkit/UnitTests/Core', $version
            data_model.dependency 'ProtonCore-DataModel', $version
            data_model.source_files = "libraries/TestingToolkit/UnitTests/DataModel/**/*.swift"
        end

        unit_tests.subspec 'Doh' do |doh|
            doh.dependency 'ProtonCore-TestingToolkit/UnitTests/Core', $version
            doh.dependency 'ProtonCore-Doh', $version
            doh.source_files = "libraries/TestingToolkit/UnitTests/Doh/**/*.swift"
        end

        unit_tests.subspec 'HumanVerification' do |human_verification|
            human_verification.dependency 'ProtonCore-TestingToolkit/UnitTests/Core', $version
            human_verification.dependency 'ProtonCore-HumanVerification', $version 
        end

        unit_tests.subspec 'Login' do |login|

            source_files = "libraries/TestingToolkit/UnitTests/Login/**/*.swift"

            login.dependency 'ProtonCore-TestingToolkit/UnitTests/Core', $version
            login.dependency 'ProtonCore-TestingToolkit/UnitTests/DataModel', $version
            login.dependency 'ProtonCore-TestingToolkit/UnitTests/HumanVerification', $version
            login.dependency 'ProtonCore-TestingToolkit/UnitTests/Services', $version

            login.subspec 'UsingCrypto' do |crypto|
                crypto.dependency 'ProtonCore-TestingToolkit/UnitTests/Authentication', $version
                crypto.dependency 'ProtonCore-Login', $version
                crypto.source_files = source_files
            end

            login.subspec 'UsingCryptoVPN' do |crypto_vpn|
                crypto_vpn.dependency 'ProtonCore-TestingToolkit/UnitTests/Authentication/UsingCryptoVPN', $version
                crypto_vpn.dependency 'ProtonCore-Login/UsingCryptoVPN', $version
                crypto_vpn.source_files = source_files
            end
        end

        unit_tests.subspec 'Networking' do |networking|
            networking.dependency 'ProtonCore-TestingToolkit/UnitTests/Core', $version
            networking.dependency 'ProtonCore-Networking', $version
            networking.source_files = "libraries/TestingToolkit/UnitTests/Networking/**/*.swift"
        end

        unit_tests.subspec 'Services' do |services|
            services.dependency 'ProtonCore-TestingToolkit/UnitTests/Core', $version
            services.dependency 'ProtonCore-TestingToolkit/UnitTests/DataModel', $version
            services.dependency 'ProtonCore-TestingToolkit/UnitTests/Doh', $version
            services.dependency 'ProtonCore-TestingToolkit/UnitTests/Networking', $version
            services.dependency 'ProtonCore-Services', $version
            services.source_files = "libraries/TestingToolkit/UnitTests/Services/**/*.swift"
        end
        
        unit_tests.subspec 'Payments' do |payments|
            payments.dependency 'ProtonCore-TestingToolkit/UnitTests/Core', $version
            payments.dependency 'OHHTTPStubs/Swift'
            payments.dependency 'PromiseKit'

            source_files = "libraries/TestingToolkit/UnitTests/Payments/**/*.swift"

            payments.subspec 'UsingCrypto' do |crypto|
                crypto.dependency 'ProtonCore-Payments', $version
                crypto.source_files = source_files
            end

            payments.subspec 'UsingCryptoVPN' do |crypto_vpn|
                crypto_vpn.dependency 'ProtonCore-Payments/UsingCryptoVPN', $version
                crypto_vpn.source_files = source_files
            end
        end
    end



    s.subspec 'UITests' do |ui_tests|

        ui_tests.dependency 'ProtonCore-CoreTranslation', $version
        ui_tests.dependency 'pmtest'

        ui_tests.subspec 'Core' do |core|
            core.dependency 'ProtonCore-Doh', $version
            core.dependency 'ProtonCore-Networking/Alamofire', $version
            core.dependency 'ProtonCore-Services', $version

            source_files = "libraries/TestingToolkit/UITests/Core/**/*.swift"

            core.subspec 'UsingCrypto' do |crypto|
                crypto.dependency 'ProtonCore-Crypto', $version
                crypto.dependency 'ProtonCore-Payments', $version
                crypto.source_files = source_files
            end

            core.subspec 'UsingCryptoVPN' do |crypto_vpn|
                crypto_vpn.dependency 'ProtonCore-Crypto-VPN', $version
                crypto_vpn.dependency 'ProtonCore-Payments/UsingCryptoVPN', $version
                crypto_vpn.source_files = source_files
            end
        end

        ui_tests.subspec 'AccountSwitcher' do |account_switcher|
            account_switcher.source_files = "libraries/TestingToolkit/UITests/AccountSwitcher/**/*.swift"
        end

        ui_tests.subspec 'HumanVerification' do |human_verification|
            human_verification.source_files = "libraries/TestingToolkit/UITests/HumanVerification/**/*.swift"
        end

        ui_tests.subspec 'Login' do |login|
            login.source_files = "libraries/TestingToolkit/UITests/Login/**/*.swift"
        end
        
        ui_tests.subspec 'PaymentsUI' do |payments_ui|
            payments_ui.source_files = "libraries/TestingToolkit/UITests/PaymentsUI/**/*.swift"
        end
    end

end
