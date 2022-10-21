require_relative 'pods_configuration'

Pod::Spec.new do |s|

    s.name             = 'ProtonCore-TroubleShooting'
    s.module_name      = 'ProtonCore_TroubleShooting'
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

    s.ios.framework = 'UIKit'
    
    s.dependency 'ProtonCore-Foundations', $version
    s.dependency 'ProtonCore-UIFoundations-V5', $version
    s.dependency 'ProtonCore-Utilities', $version
    s.dependency 'ProtonCore-Doh', $version
    s.dependency 'ProtonCore-CoreTranslation', $version

    s.source_files = 'libraries/TroubleShooting/Sources/**/*.{h,m,swift}'
    
    s.resource_bundles = {'Resources-TroubleShooting' => [
      'libraries/TroubleShooting/Resources/**/*.{xib,storyboard,geojson}',
      'libraries/TroubleShooting/Sources/**/*.{xib,storyboard,geojson}'
      ]
    }

    s.test_spec 'Tests' do |trubleshoot_tests|
      trubleshoot_tests.dependency 'ProtonCore-TestingToolkit/UnitTests/Doh', $version
      trubleshoot_tests.source_files = 'libraries/TroubleShooting/Tests/**/*'
    end
    
    this_pod_does_not_have_subspecs(s)

end
