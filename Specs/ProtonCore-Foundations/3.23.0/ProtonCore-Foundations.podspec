require_relative 'pods_configuration'

Pod::Spec.new do |s|
    
    s.name             = 'ProtonCore-Foundations'
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

    this_pod_does_not_have_subspecs(s)
    
    s.dependency 'ProtonCore-Log', $version
    
    s.ios.source_files  = "libraries/Foundations/Sources/iOS/*.swift", "libraries/Foundations/Sources/Shared/*.swift"
    s.osx.source_files  = "libraries/Foundations/Sources/Shared/*.swift"
        
    s.test_spec 'Tests' do |foundations_tests|
        foundations_tests.source_files = 'libraries/Foundations/Tests/**/*'
    end    

end
