require_relative 'pods_configuration'

Pod::Spec.new do |s|

    s.name             = 'ProtonCore-Authentication'
    s.module_name      = 'ProtonCoreAuthentication'
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

    s.pod_target_xcconfig = { 'APPLICATION_EXTENSION_API_ONLY' => 'YES' }

    s.dependency "ProtonCore-Crypto", $version
    s.dependency "ProtonCore-CryptoGoInterface", $version
    s.dependency "ProtonCore-APIClient", $version
    s.dependency "ProtonCore-FeatureSwitch", $version
    s.dependency "ProtonCore-Services", $version
    
    s.source_files = "libraries/Authentication/Sources/*.swift", "libraries/Authentication/Sources/**/*.swift"

    this_pod_does_not_have_subspecs(s)

    make_unit_test_subspec = ->(spec, crypto) {
        spec.test_spec "#{crypto_test_subspec(crypto)}" do |test_spec|
            test_spec.dependency "ProtonCore-CryptoGoInterface", $version
            test_spec.dependency "ProtonCore-CryptoGoImplementation/#{crypto_subspec(crypto)}", $version
            test_spec.dependency "ProtonCore-TestingToolkit/UnitTests/Authentication", $version
            test_spec.dependency "ProtonCore-TestingToolkit/UnitTests/Observability"
            test_spec.dependency "OHHTTPStubs/Swift"
            test_spec.source_files = "libraries/Authentication/Tests/**/*.swift"
        end
    }

    make_all_go_variants(make_unit_test_subspec, s)
end
