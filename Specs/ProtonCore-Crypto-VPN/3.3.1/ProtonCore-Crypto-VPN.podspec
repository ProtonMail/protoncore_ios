require_relative 'pods_configuration'

Pod::Spec.new do |s|
    
    s.name             = 'ProtonCore-Crypto-VPN'
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

    this_pod_does_not_have_subspecs(s)
    
    s.source_files  = "libraries/Crypto/Sources/*.swift", "libraries/Crypto/Sources/**/*.swift"
    s.test_spec 'Tests' do |crypto_vpn_tests|
      crypto_vpn_tests.source_files = 'libraries/Crypto/Tests/**/*.swift'
      crypto_vpn_tests.resource = 'libraries/Crypto/Tests/TestData/**/*'
    end

    s.vendored_frameworks = "vendor/Crypto_VPN/Crypto_VPN.xcframework"
    
    s.pod_target_xcconfig = { 'APPLICATION_EXTENSION_API_ONLY' => 'YES' }
    
end
