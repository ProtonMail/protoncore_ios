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

    s.pod_target_xcconfig = { 'APPLICATION_EXTENSION_API_ONLY' => 'NO' }
    
    s.dependency 'ProtonCore-OpenPGP', $version

    make_subspec = ->(spec, crypto, networking) {
        spec.subspec "#{crypto_and_networking_subspec(crypto, networking)}" do |subspec|
            subspec.dependency "#{crypto_module(crypto)}", $version
            subspec.dependency "ProtonCore-Authentication/#{crypto_and_networking_subspec(crypto, networking)}", $version
            subspec.source_files = "libraries/Authentication-KeyGeneration/Sources/*.swift", "libraries/Authentication-KeyGeneration/Sources/**/*.swift"

            subspec.test_spec "Tests" do |test_spec|
                test_spec.dependency "ProtonCore-ObfuscatedConstants", $version
                test_spec.dependency "ProtonCore-TestingToolkit/UnitTests/Authentication-KeyGeneration/#{crypto_and_networking_subspec(crypto, networking)}", $version
                test_spec.dependency "OHHTTPStubs/Swift"
                test_spec.source_files = "libraries/Authentication-KeyGeneration/Tests/**/*.swift"
            end
        end
    }

    no_default_subspecs(s)
    make_subspec.call(s, :crypto, :alamofire)
    make_subspec.call(s, :crypto, :afnetworking)
    make_subspec.call(s, :crypto_vpn, :alamofire)
    make_subspec.call(s, :crypto_vpn, :afnetworking)
        
end
