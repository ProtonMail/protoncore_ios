require_relative 'pods_configuration'

Pod::Spec.new do |s|

    s.name             = 'ProtonCore-FeatureFlags'
    s.module_name      = 'ProtonCoreFeatureFlags'
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

    s.pod_target_xcconfig = {
        "APPLICATION_EXTENSION_API_ONLY" => "YES",
        "ENABLE_TESTABILITY" => "YES"
    }

    s.dependency 'ProtonCore-Services', $version
    s.dependency 'ProtonCore-Networking', $version

    s.source_files = 'libraries/FeatureFlags/Sources/**/*.swift'

    s.test_spec "Tests" do |test_spec|
        test_spec.source_files = "libraries/FeatureFlags/Tests/**/*.swift"
        test_spec.dependency "ProtonCore-TestingToolkit/UnitTests/Services", $version
    end

    this_pod_does_not_have_subspecs(s)

end