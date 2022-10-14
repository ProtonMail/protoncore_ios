require_relative 'pods_configuration'

Pod::Spec.new do |s|

    s.name             = 'ProtonCore-APIClient'
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
    
    s.dependency 'ProtonCore-DataModel', $version

    make_subspec = ->(spec, networking) {
        spec.subspec "#{networking_subspec(networking)}" do |subspec|
            subspec.source_files = 'libraries/APIClient/Sources/**/*.swift'
            subspec.exclude_files = 'libraries/APIClient/Sources/APIServiceRequest+Promise.swift'
            subspec.dependency "ProtonCore-Networking/#{networking_subspec(networking)}", $version
            subspec.dependency "ProtonCore-Services/#{networking_subspec(networking)}", $version
        end
    }

    s.subspec "AwaitKit+PromiseKit" do |subspec|
        subspec.dependency 'PromiseKit', '~> 6.0'
        subspec.dependency 'AwaitKit', '~> 5.2.0'
        subspec.source_files = 'libraries/APIClient/Sources/APIServiceRequest+Promise.swift'
    end

    no_default_subspecs(s)
    make_subspec.call(s, :alamofire)
    make_subspec.call(s, :afnetworking)

    make_test_spec = ->(spec, crypto, networking) {
        spec.test_spec "#{crypto_test_subspec(crypto)}" do |test_spec|
            test_spec.source_files = 'libraries/APIClient/Tests/*.swift', 'libraries/APIClient/Tests/Mocks/*.swift', 'libraries/APIClient/Tests/TestData/*.swift'
            test_spec.resource = 'libraries/APIClient/Tests/TestData/*'
            test_spec.dependency "#{crypto_module(crypto)}", $version
            test_spec.dependency "ProtonCore-Authentication/#{crypto_and_networking_subspec(crypto, networking)}", $version
            test_spec.dependency "ProtonCore-TestingToolkit/UnitTests/Authentication/#{crypto_and_networking_subspec(crypto, networking)}", $version
            test_spec.dependency "OHHTTPStubs/Swift"
            test_spec.dependency "TrustKit" 
        end
    }

    make_test_spec.call(s, :crypto, :alamofire)
    make_test_spec.call(s, :crypto_vpn, :alamofire)
    make_test_spec.call(s, :crypto, :afnetworking)
    make_test_spec.call(s, :crypto_vpn, :afnetworking)
        
end
