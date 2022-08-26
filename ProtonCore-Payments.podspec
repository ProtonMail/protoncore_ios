require_relative 'pods_configuration'

Pod::Spec.new do |s|
    
    s.name             = 'ProtonCore-Payments'
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

    s.pod_target_xcconfig = { 'APPLICATION_EXTENSION_API_ONLY' => 'NO' }

    s.dependency 'ReachabilitySwift', '~> 5.0.0'
    
    s.dependency 'ProtonCore-CoreTranslation', $version
    s.dependency 'ProtonCore-Foundations', $version
    s.dependency 'ProtonCore-Hash', $version
    s.dependency 'ProtonCore-Log', $version

    make_subspec = ->(spec, crypto) {
        spec.subspec "#{crypto_subspec(crypto)}" do |subspec|
            subspec.dependency "ProtonCore-Authentication/#{crypto_subspec(crypto)}", $version
            subspec.dependency "ProtonCore-Networking", $version
            subspec.dependency "ProtonCore-Services", $version
            subspec.source_files = "libraries/Payments/Sources/**/*.swift", "libraries/Payments/Sources/*.swift"
            subspec.test_spec 'Tests' do |test_spec|
                test_spec.dependency "ProtonCore-TestingToolkit/UnitTests/Payments/#{crypto_subspec(crypto)}", $version
                test_spec.source_files = 'libraries/Payments/Tests/**/*.swift'
            end
        end
    }

    no_default_subspecs(s)
    make_subspec.call(s, :crypto)
    make_subspec.call(s, :crypto_vpn)

end
