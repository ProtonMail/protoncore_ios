require_relative 'pods_configuration'

Pod::Spec.new do |s|

    s.name             = 'ProtonCore-Services'
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

    s.dependency 'TrustKit'

    s.dependency 'ProtonCore-Log', $version
    s.dependency 'ProtonCore-DataModel', $version
    s.dependency 'ProtonCore-Doh', $version
    s.dependency 'ProtonCore-Utilities', $version

    make_subspec = ->(spec, networking) {
        s.subspec "#{networking_subspec(networking)}" do |subspec|
            subspec.dependency "ProtonCore-Networking/#{networking_subspec(networking)}", $version
            subspec.source_files = 'libraries/Services/Sources/*.swift'
            subspec.exclude_files = 'libraries/Services/Sources/APIService+Promise.swift'
        end
    }

    s.subspec "AwaitKit+PromiseKit" do |subspec|
        subspec.dependency 'PromiseKit', '~> 6.0'
        subspec.dependency 'AwaitKit', '~> 5.2.0'
        subspec.source_files = 'libraries/Services/Sources/APIService+Promise.swift'
    end

    no_default_subspecs(s)
    make_subspec.call(s, :alamofire)
    make_subspec.call(s, :afnetworking)
    
end
