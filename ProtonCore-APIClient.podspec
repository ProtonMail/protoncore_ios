require_relative 'pods_configuration'

Pod::Spec.new do |s|

    s.name             = 'ProtonCore-APIClient'
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

    s.dependency 'ProtonCore-DataModel', $version
    s.dependency "ProtonCore-Networking", $version
    s.dependency "ProtonCore-Services", $version

    s.source_files = 'libraries/APIClient/Sources/**/*.swift'

    make_test_spec = ->(spec, crypto) {
        spec.test_spec "#{crypto_test_subspec(crypto)}" do |test_spec|
            test_spec.source_files = 'libraries/APIClient/Tests/*.swift', 'libraries/APIClient/Tests/Mocks/*.swift', 'libraries/APIClient/Tests/TestData/*.swift'
            test_spec.resource = 'libraries/APIClient/Tests/TestData/*'
            test_spec.dependency "#{crypto_module(crypto)}", $version
            test_spec.dependency "ProtonCore-Authentication/#{crypto_subspec(crypto)}", $version
            test_spec.dependency "ProtonCore-TestingToolkit/UnitTests/Authentication/#{crypto_subspec(crypto)}", $version
            test_spec.dependency "OHHTTPStubs/Swift"
            test_spec.dependency "TrustKit"
        end
    }

    make_test_spec.call(s, :crypto)
    make_test_spec.call(s, :crypto_vpn)

end
