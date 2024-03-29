require_relative 'pods_configuration'

Pod::Spec.new do |s|

    s.name             = 'ProtonCore-TestingToolkit'
    s.module_name      = 'ProtonCoreTestingToolkit'
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
        test_data.dependency 'CryptoSwift', '1.3.1'
        test_data.dependency 'ProtonCore-DataModel', $version
        test_data.dependency "ProtonCore-Networking", $version

        test_data.source_files = "libraries/TestingToolkit/TestData/**/*.swift"
    end

    s.subspec 'UnitTests' do |unit_tests|

        unit_tests.subspec 'Core' do |core|
            core.dependency 'ProtonCore-Utilities', $version
            core.dependency "swift-snapshot-testing"			
            core.source_files = "libraries/TestingToolkit/UnitTests/Core/**/*.swift"
        end

        unit_tests.subspec 'AccountDeletion' do |account_deletion|
            account_deletion.dependency 'ProtonCore-TestingToolkit/UnitTests/Core', $version
            account_deletion.dependency "ProtonCore-AccountDeletion", $version
            account_deletion.dependency 'ProtonCore-TestingToolkit/UnitTests/FeatureFlag', $version
            account_deletion.dependency "ProtonCore-TestingToolkit/UnitTests/Networking", $version
            account_deletion.source_files = "libraries/TestingToolkit/UnitTests/AccountDeletion/**/*.swift"
        end # AccountDeletion

        unit_tests.subspec 'Authentication' do |authentication|
            authentication.dependency 'ProtonCore-TestingToolkit/UnitTests/Core', $version
            authentication.dependency "ProtonCore-Authentication", $version
            authentication.dependency 'ProtonCore-TestingToolkit/UnitTests/FeatureFlag', $version
            authentication.dependency "ProtonCore-TestingToolkit/UnitTests/Services", $version
            authentication.source_files = "libraries/TestingToolkit/UnitTests/Authentication/**/*.swift"
        end # Authentication

        unit_tests.subspec 'Authentication-KeyGeneration' do |authentication_keygeneration|
            authentication_keygeneration.dependency 'ProtonCore-TestingToolkit/UnitTests/Core', $version
            authentication_keygeneration.dependency "ProtonCore-Authentication-KeyGeneration", $version
            authentication_keygeneration.dependency "ProtonCore-TestingToolkit/UnitTests/Services", $version
            authentication_keygeneration.source_files = "libraries/TestingToolkit/UnitTests/Authentication-KeyGeneration/**/*.swift"
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

        unit_tests.subspec 'FeatureFlag' do |flag|
            flag.dependency 'ProtonCore-TestingToolkit/UnitTests/Core', $version
            flag.dependency 'ProtonCore-FeatureFlags', $version
            flag.source_files = "libraries/TestingToolkit/UnitTests/FeatureFlag/**/*.swift"
        end # Feature Flag
        
        unit_tests.subspec 'CryptoGoInterface' do |flag|
            flag.dependency 'ProtonCore-TestingToolkit/UnitTests/Core', $version
            flag.dependency 'ProtonCore-CryptoGoInterface', $version
            flag.source_files = "libraries/TestingToolkit/UnitTests/CryptoGoInterface/**/*.swift"
        end # CryptoGoInterface

        unit_tests.subspec 'Login' do |login|
            login.dependency 'ProtonCore-TestingToolkit/UnitTests/Core', $version
            login.dependency 'ProtonCore-TestingToolkit/UnitTests/DataModel', $version
            login.dependency "ProtonCore-TestingToolkit/UnitTests/Authentication", $version
            login.dependency "ProtonCore-Login", $version
            login.dependency 'ProtonCore-TestingToolkit/UnitTests/FeatureFlag', $version
            login.dependency "ProtonCore-TestingToolkit/UnitTests/Services", $version
            login.source_files = "libraries/TestingToolkit/UnitTests/Login/**/*.swift"
        end # Login

        unit_tests.subspec 'LoginUI' do |loginui|
            loginui.dependency 'ProtonCore-TestingToolkit/UnitTests/Core', $version
            loginui.dependency 'ProtonCore-TestingToolkit/UnitTests/DataModel', $version
            loginui.dependency "ProtonCore-TestingToolkit/UnitTests/Authentication", $version
            loginui.dependency "ProtonCore-LoginUI", $version
            loginui.dependency 'ProtonCore-TestingToolkit/UnitTests/FeatureFlag', $version
            loginui.dependency "ProtonCore-TestingToolkit/UnitTests/Login", $version
            loginui.dependency "ProtonCore-TestingToolkit/UnitTests/Services", $version
            loginui.source_files = "libraries/TestingToolkit/UnitTests/LoginUI/**/*.swift"
        end # LoginUI

        unit_tests.subspec 'Networking' do |networking|
            networking.dependency "ProtonCore-Networking", $version
            networking.dependency 'ProtonCore-TestingToolkit/UnitTests/Core', $version
            networking.source_files = "libraries/TestingToolkit/UnitTests/Networking/**/*.swift"
        end # Networking

        unit_tests.subspec 'Observability' do |observability|
            observability.dependency "ProtonCore-Observability", $version
            observability.dependency 'ProtonCore-TestingToolkit/UnitTests/Core', $version
            observability.source_files = "libraries/TestingToolkit/UnitTests/Observability/**/*.swift"
        end # Observability

        unit_tests.subspec 'Services' do |services|
            services.dependency "ProtonCore-Services", $version
            services.dependency 'ProtonCore-TestingToolkit/UnitTests/Core', $version
            services.dependency 'ProtonCore-TestingToolkit/UnitTests/DataModel', $version
            services.dependency 'ProtonCore-TestingToolkit/UnitTests/Doh', $version
            services.dependency 'ProtonCore-TestingToolkit/UnitTests/FeatureFlag', $version
            services.dependency "ProtonCore-TestingToolkit/UnitTests/Networking", $version
            services.source_files = "libraries/TestingToolkit/UnitTests/Services/**/*.swift"
        end # Services

        unit_tests.subspec 'Payments' do |payments|
            payments.dependency 'ProtonCore-TestingToolkit/UnitTests/Core', $version
            payments.dependency 'ProtonCore-TestingToolkit/UnitTests/FeatureFlag', $version
            payments.dependency "ProtonCore-Payments", $version
            payments.dependency 'OHHTTPStubs/Swift'
            payments.source_files = "libraries/TestingToolkit/UnitTests/Payments/**/*.swift"
        end # Payments
    end # UnitTests

    s.subspec 'UITests' do |ui_tests|

        ui_tests.dependency 'ProtonCore-QuarkCommands', $version
        ui_tests.dependency 'ProtonCore-Doh', $version
        ui_tests.dependency 'fusion'

        ui_tests.subspec 'Core' do |core|
            core.dependency 'ProtonCore-Log', $version
            core.source_files = "libraries/TestingToolkit/UITests/Core/**/*.swift"
        end # Core

        ui_tests.subspec 'AccountDeletion' do |account_deletion|
            account_deletion.dependency 'ProtonCore-AccountDeletion', $version
            account_deletion.source_files = "libraries/TestingToolkit/UITests/AccountDeletion/**/*.swift"
        end # AccountDeletion

        ui_tests.subspec 'AccountSwitcher' do |account_switcher|
            account_switcher.dependency 'ProtonCore-AccountSwitcher', $version
            account_switcher.source_files = "libraries/TestingToolkit/UITests/AccountSwitcher/**/*.swift"
        end # AccountSwitcher

        ui_tests.subspec 'HumanVerification' do |human_verification|
            human_verification.dependency 'ProtonCore-HumanVerification', $version
            human_verification.source_files = "libraries/TestingToolkit/UITests/HumanVerification/**/*.swift"
        end # HumanVerification

        ui_tests.subspec 'Login' do |login|
            login.dependency 'ProtonCore-HumanVerification', $version
            login.dependency 'ProtonCore-LoginUI', $version
            login.dependency 'ProtonCore-PaymentsUI', $version
            login.source_files = "libraries/TestingToolkit/UITests/Login/**/*.swift"
        end # Login

        ui_tests.subspec 'PaymentsUI' do |payments_ui|
            payments_ui.dependency 'ProtonCore-PaymentsUI', $version
            payments_ui.dependency 'ProtonCore-TestingToolkit/UnitTests/FeatureFlag', $version
            payments_ui.source_files = "libraries/TestingToolkit/UITests/PaymentsUI/**/*.swift"
        end # PaymentsUI
    end # UITests

end
