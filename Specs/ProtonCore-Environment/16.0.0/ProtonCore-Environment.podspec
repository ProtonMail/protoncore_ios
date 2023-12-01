require_relative 'pods_configuration'

Pod::Spec.new do |s|
    
    s.name             = 'ProtonCore-Environment'
    s.module_name      = 'ProtonCoreEnvironment'
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
    
    s.dependency "ProtonCore-Doh", $version
    s.dependency "TrustKit"

    this_pod_does_not_have_subspecs(s)
        
    s.source_files = "libraries/Environment/Sources/*.swift"
    s.ios.exclude_files = "libraries/Environment/Sources/TrustKitConfiguration+macOS.swift"
    s.osx.exclude_files = "libraries/Environment/Sources/TrustKitConfiguration+iOS.swift"

    s.test_spec 'Tests' do |environment_tests|
        environment_tests.dependency 'ProtonCore-TestingToolkit/UnitTests/Doh', $version

        environment_tests.source_files = "libraries/Environment/Tests/*.swift"
        environment_tests.ios.exclude_files = "libraries/Environment/Tests/TrustKitConfigurationTests+macOS.swift"
        environment_tests.osx.exclude_files = "libraries/Environment/Tests/TrustKitConfigurationTests+iOS.swift"
        environment_tests.dependency 'OHHTTPStubs/Swift'

        environment_tests.pod_target_xcconfig = { 'APPLICATION_EXTENSION_API_ONLY' => 'NO' }
    end
    
end
