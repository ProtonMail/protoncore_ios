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

    s.prepare_command = 'bash libraries/Authentication-KeyGeneration/Scripts/prepare_obfuscated_constants.sh'
    
    s.test_spec 'Tests' do |authentication_tests|
        authentication_tests.preserve_paths = 'libraries/Authentication-KeyGeneration/Scripts/*'
        authentication_tests.script_phase = {
            :name => 'Obfuscation',
            :script => '${PODS_TARGET_SRCROOT}/libraries/Authentication-KeyGeneration/Scripts/prepare_obfuscated_constants.sh',
            :execution_position => :before_compile,
            :output_files => ['${PODS_TARGET_SRCROOT}/libraries/Authentication-KeyGeneration/Tests/TestData/ObfuscatedConstants.swift']
        }
        authentication_tests.source_files = "libraries/Authentication-KeyGeneration/Tests/**/*.swift"
        authentication_tests.dependency 'ProtonCore-TestingToolkit/UnitTests/Authentication-KeyGeneration', $version
        authentication_tests.dependency 'OHHTTPStubs/Swift'
    end

    s.pod_target_xcconfig = { 'APPLICATION_EXTENSION_API_ONLY' => 'NO' }
        
end
