require_relative 'pods_configuration'

Pod::Spec.new do |s|

    s.name             = 'ProtonCore-Login'
    s.module_name      = 'ProtonCoreLogin'
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

    s.pod_target_xcconfig = { 'APPLICATION_EXTENSION_API_ONLY' => 'NO' }

    s.dependency 'TrustKit'
    s.dependency 'ProtonCore-Log', $version
    s.dependency 'ProtonCore-Foundations', $version
    s.dependency 'ProtonCore-DataModel', $version
    s.dependency 'ProtonCore-Observability', $version
    s.dependency "ProtonCore-Crypto", $version
    s.dependency "ProtonCore-CryptoGoInterface", $version
    s.dependency "ProtonCore-FeatureFlags", $version
    s.dependency "ProtonCore-Authentication", $version
    s.dependency "ProtonCore-Authentication-KeyGeneration", $version
    s.dependency "ProtonCore-Telemetry", $version
    s.source_files = "libraries/Login/Sources/*.swift", "libraries/Login/Sources/**/*.swift"
    s.resource_bundles = {
       'Resources-Login' => ["libraries/Login/Tests/UnitTests/Mocks/Responses/**/*.json"],
       'Translations-Login' => ["libraries/Login/Sources/Resources/Translations/*"]
    }

    this_pod_does_not_have_subspecs(s)

    make_unit_test_subspec = ->(spec, crypto) {
        spec.test_spec "Unit#{crypto_test_subspec(crypto)}" do |test_spec|
            test_spec.dependency "ProtonCore-Crypto", $version
            test_spec.dependency "ProtonCore-CryptoGoInterface", $version
            test_spec.dependency "ProtonCore-CryptoGoImplementation/#{crypto_subspec(crypto)}", $version
            test_spec.dependency "ProtonCore-Authentication", $version
            test_spec.dependency "ProtonCore-Authentication-KeyGeneration", $version
            test_spec.dependency "ProtonCore-ObfuscatedConstants", $version
            test_spec.dependency "ProtonCore-TestingToolkit/TestData", $version
            test_spec.dependency "ProtonCore-TestingToolkit/UnitTests/Authentication-KeyGeneration", $version
            test_spec.dependency "ProtonCore-TestingToolkit/UnitTests/Login", $version
            test_spec.dependency "OHHTTPStubs/Swift"
            test_spec.dependency "TrustKit"
            test_spec.resources = "libraries/Login/Tests/UnitTests/Mocks/Responses/**/*"
            test_spec.source_files = 'libraries/Login/Tests/UnitTests/*.swift', 'libraries/Login/Tests/UnitTests/**/*.swift'
        end
    }

    make_all_go_variants(make_unit_test_subspec, s)

    make_integration_test_subspec = ->(spec, crypto) {
        spec.test_spec "Integration#{crypto_test_subspec(crypto)}" do |test_spec|
            test_spec.dependency "ProtonCore-Crypto", $version
            test_spec.dependency "ProtonCore-CryptoGoInterface", $version
            test_spec.dependency "ProtonCore-CryptoGoImplementation/#{crypto_subspec(crypto)}", $version
            test_spec.dependency "ProtonCore-QuarkCommands", $version
            test_spec.dependency "ProtonCore-TestingToolkit/UnitTests/Core", $version
            test_spec.dependency "TrustKit"
            test_spec.source_files = 'libraries/Login/Tests/IntegrationTests/*.swift', 'libraries/Login/Tests/IntegrationTests/**/*.swift'
            
            add_dynamic_domain_to_info_plist(test_spec)
        end
    }

    make_all_go_variants(make_integration_test_subspec, s)

end
