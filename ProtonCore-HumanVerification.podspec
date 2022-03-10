require_relative 'pods_configuration'

Pod::Spec.new do |s|

    s.name             = 'ProtonCore-HumanVerification'
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

    s.ios.framework = 'UIKit'
    s.osx.framework = 'AppKit'
    
    s.dependency 'ProtonCore-UIFoundations', $version
    s.dependency 'ProtonCore-CoreTranslation', $version
    s.dependency 'ProtonCore-Foundations', $version
    s.dependency 'ProtonCore-Utilities', $version

    make_subspec = ->(spec, networking) {
        spec.subspec "#{networking_subspec(networking)}" do |subspec|
            subspec.dependency "ProtonCore-APIClient/#{networking_subspec(networking)}", $version
            subspec.ios.source_files = 'libraries/HumanVerification/Sources/iOS/**/*.{h,m,swift}', 
                                       'libraries/HumanVerification/Sources/Shared/**/*.{h,m,swift}'
            subspec.osx.source_files = 'libraries/HumanVerification/Sources/macOS/**/*.{h,m,swift}', 
                                       'libraries/HumanVerification/Sources/Shared/**/*.{h,m,swift}'
            subspec.ios.resource_bundles = {'Resources-HumanVerification' => [
                'libraries/HumanVerification/Resources/**/*.{xib,storyboard,geojson}', 
                'libraries/HumanVerification/Sources/iOS/*.{xib,storyboard,geojson}'
            ]}
            subspec.osx.resource_bundles = {'Resources-HumanVerification' => [
                'libraries/HumanVerification/Resources/**/*.{xib,storyboard,geojson}', 
                'libraries/HumanVerification/Sources/macOS/*.{xib,storyboard,geojson}'
            ]}

            subspec.test_spec 'Tests' do |test_spec|
                test_spec.dependency "ProtonCore-TestingToolkit/UnitTests/HumanVerification/#{networking_subspec(networking)}", $version
                test_spec.source_files = 'libraries/HumanVerification/Tests/**/*'
            end
        end
    }

    no_default_subspecs(s)
    make_subspec.call(s, :alamofire)
    make_subspec.call(s, :afnetworking)

end
