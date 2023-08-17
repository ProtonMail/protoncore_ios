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
    s.dependency 'ProtonCore-APIClient', $version
    s.dependency 'ProtonCore-Observability', $version
    

    this_pod_does_not_have_subspecs(s)

    s.ios.source_files = 'libraries/HumanVerification/Sources/iOS/**/*.{h,m,swift}', 
                         'libraries/HumanVerification/Sources/Shared/**/*.{h,m,swift}'
    s.osx.source_files = 'libraries/HumanVerification/Sources/macOS/**/*.{h,m,swift}', 
                         'libraries/HumanVerification/Sources/Shared/**/*.{h,m,swift}'
    s.ios.resource_bundles = {'Resources-HumanVerification' => [
        'libraries/HumanVerification/Resources/**/*.{xib,storyboard,geojson}', 
        'libraries/HumanVerification/Sources/iOS/*.{xib,storyboard,geojson}'
    ]}
    s.osx.resource_bundles = {'Resources-HumanVerification' => [
        'libraries/HumanVerification/Resources/**/*.{xib,storyboard,geojson}', 
        'libraries/HumanVerification/Sources/macOS/*.{xib,storyboard,geojson}'
    ]}

    s.test_spec 'Tests' do |test_spec|
        test_spec.dependency "ProtonCore-TestingToolkit/UnitTests/HumanVerification", $version
        test_spec.dependency "ProtonCore-TestingToolkit/UnitTests/Observability", $version
        test_spec.source_files = 'libraries/HumanVerification/Tests/**/*'
    end

end
