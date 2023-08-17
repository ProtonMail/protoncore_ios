require_relative 'pods_configuration'

Pod::Spec.new do |s|

    s.name             = 'ProtonCore-Common'
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

    s.dependency 'ProtonCore-Services', $version
    s.dependency 'ProtonCore-UIFoundations', $version
    
    s.source_files = 'libraries/Common/Sources/*'
    
    s.test_spec 'Tests' do |common_tests|
        common_tests.source_files = 'libraries/Common/Tests/**/*.swift'
    end

    s.pod_target_xcconfig = { 'APPLICATION_EXTENSION_API_ONLY' => 'NO' }
    
end
