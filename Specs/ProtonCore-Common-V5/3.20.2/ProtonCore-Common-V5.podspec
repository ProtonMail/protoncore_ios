require_relative 'pods_configuration'

Pod::Spec.new do |s|

    s.name             = 'ProtonCore-Common-V5'
    s.module_name      = 'ProtonCoreCommon'
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

    s.dependency 'ProtonCore-UIFoundations-V5', $version

    make_subspec = ->(spec, networking) {
        spec.subspec "#{networking_subspec(networking)}" do |subspec|
            subspec.dependency "ProtonCore-Services/#{networking_subspec(networking)}", $version
            subspec.dependency "ProtonCore-Networking/#{networking_subspec(networking)}", $version
            subspec.ios.source_files = 'libraries/Common/Sources/iOS/*', 'libraries/Common/Sources/Shared/*'
            subspec.osx.source_files = 'libraries/Common/Sources/Shared/*'
            subspec.test_spec 'Tests' do |test_spec|
                test_spec.source_files = 'libraries/Common/Tests/**/*.swift'
            end
        end
    }

    no_default_subspecs(s)
    make_subspec.call(s, :alamofire)
    make_subspec.call(s, :afnetworking)
    
end
