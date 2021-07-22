require_relative 'pods_configuration'

Pod::Spec.new do |s|
    
    s.name             = 'ProtonCore-Keymaker'
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
    
    s.dependency 'EllipticCurveKeyPair', '~> 2.0'
    s.dependency 'ProtonCore-Crypto', $version

    s.source_files  = "libraries/Keymaker/Sources/*.swift", "libraries/Keymaker/Sources/**/*.swift"
    
    s.test_spec 'Tests' do |keymaker_tests|
        keymaker_tests.source_files = 'libraries/Keymaker/Tests/**/*'
    end

    s.pod_target_xcconfig = { 'APPLICATION_EXTENSION_API_ONLY' => 'NO' }

end
