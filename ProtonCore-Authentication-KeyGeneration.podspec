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
    
    s.dependency 'ProtonCore-OpenPGP', $version
    
    s.default_subspecs = 'UsingCrypto'

    source_files = "libraries/Authentication-KeyGeneration/Sources/*.swift", "libraries/Authentication-KeyGeneration/Sources/**/*.swift"

    test_preserve_paths = 'libraries/Authentication-KeyGeneration/Scripts/*'
    test_script_phase = {
        :name => 'Obfuscation',
        :script => '${PODS_TARGET_SRCROOT}/libraries/Authentication-KeyGeneration/Scripts/prepare_obfuscated_constants.sh',
        :execution_position => :before_compile,
        :output_files => ['${PODS_TARGET_SRCROOT}/libraries/Authentication-KeyGeneration/Tests/TestData/ObfuscatedConstants.swift']
    }
    test_source_files = "libraries/Authentication-KeyGeneration/Tests/**/*.swift"

    s.subspec 'UsingCrypto' do |crypto|
        crypto.dependency 'ProtonCore-Authentication/UsingCrypto', $version
        crypto.dependency 'ProtonCore-Crypto', $version
        crypto.source_files = source_files

        crypto.test_spec 'Tests' do |authentication_tests|
            authentication_tests.preserve_paths = test_preserve_paths
            authentication_tests.script_phase = test_script_phase
            authentication_tests.dependency 'ProtonCore-TestingToolkit/UnitTests/Authentication-KeyGeneration/UsingCrypto', $version
            authentication_tests.dependency 'OHHTTPStubs/Swift'
            authentication_tests.source_files = test_source_files
        end
    end
  
    s.subspec 'UsingCryptoVPN' do |crypto_vpn|
        crypto_vpn.dependency 'ProtonCore-Authentication/UsingCryptoVPN', $version
        crypto_vpn.dependency 'ProtonCore-Crypto-VPN', $version
        crypto_vpn.source_files  = source_files

        crypto_vpn.test_spec 'Tests' do |authentication_tests|
            authentication_tests.preserve_paths = test_preserve_paths
            authentication_tests.script_phase = test_script_phase
            authentication_tests.dependency 'ProtonCore-TestingToolkit/UnitTests/Authentication-KeyGeneration/UsingCryptoVPN', $version
            authentication_tests.dependency 'OHHTTPStubs/Swift'
            authentication_tests.source_files = test_source_files
        end
    end

    s.prepare_command = 'bash libraries/Authentication-KeyGeneration/Scripts/prepare_obfuscated_constants.sh'

    s.pod_target_xcconfig = { 'APPLICATION_EXTENSION_API_ONLY' => 'NO' }
        
end
