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

    s.prepare_command = 'bash libraries/Authentication/Scripts/prepare_obfuscated_constants.sh'

    s.default_subspecs = 'UsingCrypto'

    source_files  = "libraries/Authentication/Sources/*.swift", "libraries/Authentication/Sources/**/*.swift"

    test_preserve_paths = 'libraries/Authentication/Scripts/*'

    test_script_phase = {
        :name => 'Obfuscation',
        :script => '${PODS_TARGET_SRCROOT}/libraries/Authentication/Scripts/prepare_obfuscated_constants.sh',
        :execution_position => :before_compile,
        :output_files => ['${PODS_TARGET_SRCROOT}/libraries/Authentication/Tests/TestData/ObfuscatedConstants.swift']
    }

    test_source_files = "libraries/Authentication/Tests/TestData/ObfuscatedConstants.swift", "libraries/Authentication/Tests/**/*.swift"

    s.subspec 'UsingCrypto' do |crypto|
        crypto.dependency 'ProtonCore-Crypto', $version
        crypto.source_files  = source_files
        crypto.test_spec 'Tests' do |authentication_tests|
            authentication_tests.preserve_paths = test_preserve_paths
            authentication_tests.script_phase = test_script_phase
            authentication_tests.source_files = test_source_files
            authentication_tests.dependency 'ProtonCore-TestingToolkit/UnitTests/Authentication/UsingCrypto', $version
            authentication_tests.dependency 'OHHTTPStubs/Swift'
        end
    end
  
    s.subspec 'UsingCryptoVPN' do |crypto_vpn|
        crypto_vpn.dependency 'ProtonCore-Crypto-VPN', $version
        crypto_vpn.source_files  = source_files
        crypto_vpn.test_spec 'Tests' do |authentication_tests|
            authentication_tests.preserve_paths = test_preserve_paths
            authentication_tests.script_phase = test_script_phase
            authentication_tests.source_files = test_source_files
            authentication_tests.dependency 'ProtonCore-TestingToolkit/UnitTests/Authentication/UsingCryptoVPN', $version
            authentication_tests.dependency 'OHHTTPStubs/Swift'
        end
    end

    s.pod_target_xcconfig = { 'APPLICATION_EXTENSION_API_ONLY' => 'NO' }
        
end
