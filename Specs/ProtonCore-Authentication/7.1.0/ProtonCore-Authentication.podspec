require_relative 'pods_configuration'

Pod::Spec.new do |s|

    s.name             = 'ProtonCore-Authentication'
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

    make_subspec = ->(spec, crypto) {
        spec.subspec "#{crypto_subspec(crypto)}" do |subspec|
            subspec.dependency "ProtonCore-Crypto/#{crypto_subspec(crypto)}", $version
            subspec.dependency "ProtonCore-CryptoGoImplementation/#{crypto_subspec(crypto)}", $version
            subspec.dependency "ProtonCore-APIClient", $version
            subspec.dependency "ProtonCore-FeatureSwitch", $version
            subspec.dependency "ProtonCore-Services", $version
            subspec.source_files = "libraries/Authentication/Sources/*.swift", "libraries/Authentication/Sources/**/*.swift"

            subspec.test_spec 'Tests' do |test_spec|
                test_spec.dependency "ProtonCore-CryptoGoInterface", $version
                test_spec.source_files = "libraries/Authentication/Tests/**/*.swift"
                test_spec.dependency "ProtonCore-TestingToolkit/UnitTests/Authentication/#{crypto_subspec(crypto)}", $version
                test_spec.dependency "OHHTTPStubs/Swift"
            end
        end
    }

    make_all_go_variants(make_subspec, s)

    no_default_subspecs(s)

end
