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

    s.dependency 'ProtonCore-CoreTranslation', $version
    s.dependency 'ProtonCore-UIFoundations', $version
    s.dependency 'ProtonCore-Networking', $version
    
    s.source_files = 'libraries/ForceUpgrade/Sources/**/*.{h,m,swift}'
    s.resource_bundles = {'Resources-FU' => ['libraries/ForceUpgrade/Sources/**/*.{xib,storyboard,xcassets}']}
    s.exclude_files = "Classes/Exclude"
    
    s.test_spec 'Tests' do |forceupgrade_tests|
        forceupgrade_tests.source_files = 'libraries/ForceUpgrade/Tests/**/*'
    end

    s.framework = 'UIKit'
    s.pod_target_xcconfig = { 'APPLICATION_EXTENSION_API_ONLY' => 'NO' }

end
