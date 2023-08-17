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

    s.dependency 'ProtonCore-Crypto', $version
    s.dependency 'ProtonCore-DataModel', $version

    s.source_files  = "libraries/KeyManager/Sources/**/*.swift"
    
    s.test_spec 'Tests' do |keymanager_tests|
        keymanager_tests.source_files = 'libraries/KeyManager/Tests/**/*.swift'
        keymanager_tests.resource = 'libraries/KeyManager/Tests/TestData/**/*'
        keymanager_tests.dependency 'ProtonCore-DataModel'
    end

    s.pod_target_xcconfig = { 'APPLICATION_EXTENSION_API_ONLY' => 'YES' }

end
