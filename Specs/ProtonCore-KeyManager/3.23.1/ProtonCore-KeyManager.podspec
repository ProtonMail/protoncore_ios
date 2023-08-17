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

    s.pod_target_xcconfig = { 'APPLICATION_EXTENSION_API_ONLY' => 'YES' }

    s.dependency 'ProtonCore-DataModel', $version

    make_subspec = ->(spec, crypto) {
        spec.subspec "#{crypto_subspec(crypto)}" do |subspec|
            subspec.dependency "#{crypto_module(crypto)}", $version
            subspec.source_files = "libraries/KeyManager/Sources/**/*.swift"
            subspec.test_spec 'Tests' do |test_spec|
                test_spec.dependency 'ProtonCore-DataModel'
                test_spec.source_files = 'libraries/KeyManager/Tests/**/*.swift'
                test_spec.resource = 'libraries/KeyManager/Tests/TestData/**/*'
            end
        end
    }

    no_default_subspecs(s)
    make_subspec.call(s, :crypto)
    make_subspec.call(s, :crypto_vpn)

end
