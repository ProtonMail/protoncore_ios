require_relative 'pods_configuration'

Pod::Spec.new do |s|
    
    s.name             = 'ProtonCore-Log'
    s.module_name      = 'ProtonCoreLog'
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
    
    s.source_files  = "libraries/Log/Sources/*.swift", "libraries/Log/Sources/**/*.swift"
    
    s.test_spec 'Tests' do |log_tests|
        log_tests.source_files = 'libraries/Log/Tests/**/*'
    end

end
