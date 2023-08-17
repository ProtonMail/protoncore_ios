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

    s.dependency "ProtonCore-Observability", $version

    this_pod_does_not_have_subspecs(s)

    s.source_files = 'libraries/Services/Sources/*.swift', "libraries/Services/Sources/**/*.swift"

    s.test_spec "UnitTests" do |test_spec|
        test_spec.source_files = "libraries/Services/Tests/Unit/*.swift"
        test_spec.dependency "ProtonCore-TestingToolkit/UnitTests/Networking", $version
        test_spec.dependency "ProtonCore-TestingToolkit/UnitTests/Services", $version
        test_spec.dependency "ProtonCore-TestingToolkit/UnitTests/Observability", $version
    end

    s.test_spec "IntegrationTests" do |test_spec|
        test_spec.dependency 'ProtonCore-TestingToolkit/UnitTests/FeatureSwitch', $version
        test_spec.source_files = "libraries/Services/Tests/Integration/*.swift"
        test_spec.dependency 'ProtonCore-Challenge', $version
        test_spec.dependency 'ProtonCore-Authentication', $version
        test_spec.dependency 'ProtonCore-Login', $version
    end

end
