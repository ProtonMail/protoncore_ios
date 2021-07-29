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
    
    s.swift_versions = $swift_versions
    
    s.dependency 'ProtonCore-UIFoundations', $version
    s.dependency 'ProtonCore-CoreTranslation', $version
    s.dependency 'ProtonCore-Foundations', $version
    s.dependency 'ProtonCore-Utilities', $version
    s.dependency 'ProtonCore-APIClient', $version
    
    s.source_files = ['libraries/HumanVerification/Sources/*.{h,m,swift}', 'libraries/HumanVerification/Sources/**/*.{h,m,swift}']
    s.resource_bundles = {'Resources-HV' => ['libraries/HumanVerification/Sources/**/*.{xib,storyboard,xcassets,geojson}']}
    s.exclude_files = "Classes/Exclude"
    
    s.test_spec 'Tests' do |humanverification_tests|
        humanverification_tests.dependency 'ProtonCore-TestingToolkit/UnitTests/HumanVerification', $version

        humanverification_tests.source_files = 'libraries/HumanVerification/Tests/**/*'
    end

    s.framework = 'UIKit'
    s.pod_target_xcconfig = { 'APPLICATION_EXTENSION_API_ONLY' => 'NO' }

end
