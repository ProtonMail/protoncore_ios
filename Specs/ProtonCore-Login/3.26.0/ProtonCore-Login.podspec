require_relative 'pods_configuration'

Pod::Spec.new do |s|

    s.name             = 'ProtonCore-Login'
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
    s.dependency 'ProtonCore-OpenPGP', $version
    s.dependency 'ProtonCore-Foundations', $version
    s.dependency 'ProtonCore-CoreTranslation', $version
    s.dependency 'ProtonCore-DataModel', $version

    make_subspec = ->(spec, crypto) {
        spec.subspec "#{crypto_subspec(crypto)}" do |subspec|
            subspec.dependency "#{crypto_module(crypto)}", $version
            subspec.dependency "ProtonCore-Authentication/#{crypto_subspec(crypto)}", $version
            subspec.dependency "ProtonCore-Authentication-KeyGeneration/#{crypto_subspec(crypto)}", $version
            subspec.source_files = "libraries/Login/Sources/*.swift", "libraries/Login/Sources/**/*.swift"
            subspec.resource_bundles = {
               'Resources-Login' => ["libraries/Login/Tests/Mocks/Responses/**/*.json"]
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
            test_spec.dependency "ProtonCore-ObfuscatedConstants", $version
            test_spec.dependency "ProtonCore-TestingToolkit/TestData", $version
            test_spec.dependency "ProtonCore-TestingToolkit/UnitTests/Login/#{crypto_subspec(crypto)}", $version
            test_spec.dependency "OHHTTPStubs/Swift"
            test_spec.dependency "TrustKit"
            test_spec.resources = "libraries/Login/Tests/Mocks/Responses/**/*"
            test_spec.source_files = 'libraries/Login/Tests/*.swift', 'libraries/Login/Tests/**/*.swift'
        end
    }

    make_all_go_variants(make_test_subspec, s)
            
end
