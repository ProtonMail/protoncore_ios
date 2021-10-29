require_relative 'pods_configuration'

Pod::Spec.new do |s|

    s.name             = 'ProtonCore-KeyManager'
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

    s.dependency 'ProtonCore-DataModel', $version

    s.default_subspecs = :none

    source_files  = "libraries/KeyManager/Sources/**/*.swift"

    test_source_files = 'libraries/KeyManager/Tests/**/*.swift'

    test_resource = 'libraries/KeyManager/Tests/TestData/**/*'

    s.subspec 'UsingCrypto' do |crypto|
        crypto.dependency 'ProtonCore-Crypto', $version
        crypto.source_files = source_files
        crypto.test_spec 'Tests' do |keymanager_tests|
            keymanager_tests.dependency 'ProtonCore-DataModel'
            keymanager_tests.source_files = test_source_files
            keymanager_tests.resource = test_resource
        end
    end
  
    s.subspec 'UsingCryptoVPN' do |crypto_vpn|
        crypto_vpn.dependency 'ProtonCore-Crypto-VPN', $version
        crypto_vpn.source_files = source_files
        crypto_vpn.test_spec 'Tests' do |keymanager_tests|
            keymanager_tests.dependency 'ProtonCore-DataModel'
            keymanager_tests.source_files = test_source_files
            keymanager_tests.resource = test_resource
        end
    end

    s.pod_target_xcconfig = { 'APPLICATION_EXTENSION_API_ONLY' => 'YES' }

end
