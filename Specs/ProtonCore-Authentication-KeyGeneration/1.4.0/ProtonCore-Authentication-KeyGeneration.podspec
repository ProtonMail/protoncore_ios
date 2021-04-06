require_relative 'pods_configuration'

Pod::Spec.new do |s|
    
    s.name             = 'ProtonCore-Authentication-KeyGeneration'
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
    
    s.dependency 'ProtonCore-Authentication', $version
    s.dependency 'ProtonCore-OpenPGP', $version
    s.dependency 'ProtonCore-Crypto', $version
    
    s.source_files  = "libraries/Authentication-KeyGeneration/Sources/*.swift", "libraries/Authentication-KeyGeneration/Sources/**/*.swift"
    
    s.test_spec 'Tests' do |authentication_tests|
        authentication_tests.source_files = "libraries/Authentication-KeyGeneration/Tests/**/*.swift"
        authentication_tests.dependency 'ProtonCore-TestingToolkit/UnitTests/Authentication-KeyGeneration', $version
        authentication_tests.dependency 'OHHTTPStubs/Swift'
    end

    s.pod_target_xcconfig = { 'APPLICATION_EXTENSION_API_ONLY' => 'NO' }
        
end
