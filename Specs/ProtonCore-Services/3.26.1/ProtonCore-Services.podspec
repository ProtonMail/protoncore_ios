require_relative 'pods_configuration'

Pod::Spec.new do |s|

    s.name             = 'ProtonCore-Services'
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

    s.dependency 'TrustKit'

    s.dependency 'ProtonCore-DataModel', $version
    s.dependency 'ProtonCore-Doh', $version
    s.dependency 'ProtonCore-Log', $version
    s.dependency "ProtonCore-Networking", $version
    s.dependency 'ProtonCore-Utilities', $version
    s.dependency 'ProtonCore-Environment', $version
    s.dependency 'ProtonCore-FeatureSwitch', $version

    this_pod_does_not_have_subspecs(s)

    s.source_files = 'libraries/Services/Sources/*.swift'

    s.test_spec "Tests" do |test_spec|
        test_spec.source_files = "libraries/Services/Tests/*.swift"
        test_spec.dependency "ProtonCore-TestingToolkit/UnitTests/Networking", $version
        test_spec.dependency "ProtonCore-TestingToolkit/UnitTests/Services", $version
    end

end
