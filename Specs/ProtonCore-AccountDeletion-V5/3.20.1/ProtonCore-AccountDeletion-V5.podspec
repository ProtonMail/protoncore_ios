require_relative 'pods_configuration'

Pod::Spec.new do |s|

    s.name             = 'ProtonCore-AccountDeletion-V5'
    s.module_name      = 'ProtonCoreAccountDeletion'
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

    s.dependency 'ProtonCore-CoreTranslation', $version
    s.dependency 'ProtonCore-Doh', $version
    s.dependency 'ProtonCore-Foundations', $version
    s.dependency 'ProtonCore-Log', $version
    s.dependency 'ProtonCore-Utilities', $version
    s.dependency 'ProtonCore-UIFoundations-V5', $version

    make_subspec = ->(spec, crypto, networking) {
        spec.subspec "#{crypto_and_networking_subspec(crypto, networking)}" do |subspec|
            subspec.dependency "ProtonCore-Authentication/#{crypto_and_networking_subspec(crypto, networking)}", $version
            subspec.dependency "ProtonCore-Networking/#{networking_subspec(networking)}", $version
            subspec.dependency "ProtonCore-Services/#{networking_subspec(networking)}", $version
            subspec.ios.source_files = "libraries/AccountDeletion/Sources/iOS/*.swift", "libraries/AccountDeletion/Sources/Shared/*.swift"
            subspec.osx.source_files = "libraries/AccountDeletion/Sources/macOS/*.swift", "libraries/AccountDeletion/Sources/Shared/*.swift"
            
            subspec.test_spec 'Tests' do |test_spec|
                test_spec.dependency "ProtonCore-TestingToolkit/UnitTests/Doh", $version
                test_spec.dependency "ProtonCore-TestingToolkit/UnitTests/Networking/#{networking_subspec(networking)}", $version
                test_spec.dependency "ProtonCore-TestingToolkit/UnitTests/Services/#{networking_subspec(networking)}", $version
                test_spec.source_files = 'libraries/AccountDeletion/Tests/**/*.swift'
            end
        end
    }

    no_default_subspecs(s)

    make_subspec.call(s, :crypto, :alamofire)
    make_subspec.call(s, :crypto, :afnetworking)
    make_subspec.call(s, :crypto_vpn, :alamofire)
    make_subspec.call(s, :crypto_vpn, :afnetworking)
    
end
