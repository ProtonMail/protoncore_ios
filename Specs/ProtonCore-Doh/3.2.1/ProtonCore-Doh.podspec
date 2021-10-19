require_relative 'pods_configuration'

Pod::Spec.new do |s|
    
    s.name             = 'ProtonCore-Doh'
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
    
    s.dependency "ProtonCore-Log", $version
        
    s.source_files = "libraries/Doh/Sources/*.swift"

    s.test_spec 'Tests' do |doh_tests|
#        doh_tests.dependency 'ProtonCore-TestingToolkit/UnitTests/Doh', $version

        doh_tests.source_files = "libraries/Doh/Tests/*.swift"
        doh_tests.dependency 'OHHTTPStubs/Swift'
    end

    s.pod_target_xcconfig = { 'APPLICATION_EXTENSION_API_ONLY' => 'YES' }
    
end
