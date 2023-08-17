require_relative 'pods_configuration'

Pod::Spec.new do |s|
    
    s.name             = 'ProtonCore-Authentication'
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
    s.dependency 'ProtonCore-APIClient', $version
    s.dependency 'ProtonCore-Crypto', $version

    s.source_files  = "libraries/Authentication/Sources/*.swift", "libraries/Authentication/Sources/**/*.swift"
    
    s.test_spec 'Tests' do |authentication_tests|
        authentication_tests.script_phase = {
            :name => 'Obfuscation',
            :script => '../../../libraries/Authentication/Scripts/prepare_obfuscated_constants.sh',
            :execution_position => :before_compile,
            :output_files => ['../../../libraries/Authentication/Tests/TestData/ObfuscatedConstants.swift']
        }
        authentication_tests.source_files = "libraries/Authentication/Tests/TestData/ObfuscatedConstants.swift", "libraries/Authentication/Tests/**/*.swift"
        authentication_tests.dependency 'ProtonCore-TestingToolkit/UnitTests/Authentication', $version
        authentication_tests.dependency 'OHHTTPStubs/Swift'
    end

    s.pod_target_xcconfig = { 'APPLICATION_EXTENSION_API_ONLY' => 'NO' }
        
end
