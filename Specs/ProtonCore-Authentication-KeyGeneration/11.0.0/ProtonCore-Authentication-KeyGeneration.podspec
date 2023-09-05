require_relative 'pods_configuration'

Pod::Spec.new do |s|

    s.name             = 'ProtonCore-Authentication-KeyGeneration'
    s.module_name      = 'ProtonCoreAuthenticationKeyGeneration'
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

    this_pod_does_not_have_subspecs(s)

    s.dependency 'ProtonCore-Hash', $version
    s.dependency 'ProtonCore-FeatureSwitch', $version
    s.dependency "ProtonCore-Crypto", $version
    s.dependency "ProtonCore-CryptoGoInterface", $version
    s.dependency "ProtonCore-Authentication", $version
    s.source_files = "libraries/Authentication-KeyGeneration/Sources/*.swift", "libraries/Authentication-KeyGeneration/Sources/**/*.swift"

    make_test_spec = ->(spec, crypto) {
        spec.test_spec "#{crypto_test_subspec(crypto)}" do |test_spec|
            test_spec.dependency "ProtonCore-ObfuscatedConstants", $version
            test_spec.dependency "ProtonCore-TestingToolkit/UnitTests/Authentication-KeyGeneration", $version
            test_spec.dependency "ProtonCore-CryptoGoImplementation/#{crypto_subspec(crypto)}", $version
            test_spec.dependency "OHHTTPStubs/Swift"
            test_spec.source_files = "libraries/Authentication-KeyGeneration/Tests/**/*.swift"
            test_spec.resource = "libraries/Authentication-KeyGeneration/Tests/TestData/**/*"

        end
    }

    make_all_go_variants(make_test_spec, s)


end
