require_relative 'pods_configuration'

Pod::Spec.new do |s|

    s.name             = 'ProtonCore-ForceUpgrade'
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
    
    s.swift_versions = $swift_versions

    s.pod_target_xcconfig = { 'APPLICATION_EXTENSION_API_ONLY' => 'NO' }

    s.dependency 'ProtonCore-CoreTranslation', $version
    s.dependency 'ProtonCore-UIFoundations', $version

    make_subspec = ->(spec, networking) {
        spec.subspec "#{networking_subspec(networking)}" do |subspec|
            subspec.dependency "ProtonCore-Networking/#{networking_subspec(networking)}", $version
            subspec.source_files = 'libraries/ForceUpgrade/Sources/*.{h,m,swift}'
            subspec.resource_bundles = { 'Resources-ForceUpgrade' => 'libraries/ForceUpgrade/Sources/Resources/*' }
            subspec.test_spec 'Tests' do |test_spec|
                test_spec.source_files = 'libraries/ForceUpgrade/Tests/**/*'
            end
        end
    }

    no_default_subspecs(s)
    make_subspec.call(s, :alamofire)
    make_subspec.call(s, :afnetworking)
    
end
