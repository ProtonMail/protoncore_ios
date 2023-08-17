require_relative 'pods_configuration'

Pod::Spec.new do |s|

    s.name             = 'ProtonCore-APIClient'
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
    
    s.dependency 'ProtonCore-Networking', $version
    s.dependency 'ProtonCore-DataModel', $version
    s.dependency 'ProtonCore-Services', $version
    
    s.source_files = 'libraries/Networking/Sources/APIClient/**/*.swift'
    
    s.test_spec 'Tests' do |apiclient_tests|
        apiclient_tests.preserve_paths = 'libraries/Networking/Tests/APIClient/Scripts/*'
        apiclient_tests.source_files = 'libraries/Networking/Tests/APIClient/*.swift', 'libraries/Networking/Tests/APIClient/Mocks/*.swift', 'libraries/Networking/Tests/APIClient/TestData/*.swift'
        apiclient_tests.resource = 'libraries/Networking/Tests/APIClient/TestData/*'
        apiclient_tests.dependency 'ProtonCore-Crypto-VPN', $version
        apiclient_tests.dependency 'ProtonCore-Authentication/UsingCryptoVPN', $version
        apiclient_tests.dependency 'ProtonCore-TestingToolkit/UnitTests/Authentication/UsingCryptoVPN', $version
        apiclient_tests.dependency 'OHHTTPStubs/Swift'
        apiclient_tests.dependency 'TrustKit'
        
    end

    s.pod_target_xcconfig = { 'APPLICATION_EXTENSION_API_ONLY' => 'NO' }
        
end
