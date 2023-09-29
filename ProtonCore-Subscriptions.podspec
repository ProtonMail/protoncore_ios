require_relative 'pods_configuration'

Pod::Spec.new do |s|
    
    s.name             = 'ProtonCore-Subscriptions'
    s.module_name      = 'ProtonCoreSubscriptions'
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

    s.dependency 'ReachabilitySwift', '~> 5.0.0'
    
    s.dependency 'ProtonCore-FeatureSwitch', $version

    s.source_files = "libraries/Subscriptions/Sources/**/*.swift", "libraries/Subscriptions/Sources/*.swift"

    s.test_spec 'Tests' do |test_spec|
        test_spec.dependency "ProtonCore-FeatureSwitch", $version
        test_spec.dependency "ProtonCore-TestingToolkit/UnitTests/FeatureSwitch", $version
        test_spec.source_files = 'libraries/Subscriptions/Tests/UnitTests/**/*.swift'
    end

    this_pod_does_not_have_subspecs(s)

end
