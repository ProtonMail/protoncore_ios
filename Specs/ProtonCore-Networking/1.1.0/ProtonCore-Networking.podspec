require_relative 'pods_configuration'

Pod::Spec.new do |s|

    s.name             = 'ProtonCore-Networking'
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
    
    s.source_files = "libraries/Networking/Sources/Networking/**/*"
    
    s.test_spec 'Tests' do |networking_tests|
        networking_tests.source_files = 'libraries/Networking/Tests/Networking/*'
        networking_tests.dependency 'ProtonCore-TestingToolkit/UnitTests/Networking', $version
        networking_tests.dependency 'ProtonCore-Doh', $version
        networking_tests.dependency 'ProtonCore-Services', $version
        networking_tests.dependency 'ProtonCore-APIClient', $version
        networking_tests.dependency 'OHHTTPStubs/Swift'
        networking_tests.dependency 'TrustKit'
    end

    s.pod_target_xcconfig = { 'APPLICATION_EXTENSION_API_ONLY' => 'NO' }

end
