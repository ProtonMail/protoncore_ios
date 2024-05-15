require_relative 'pods_configuration'

Pod::Spec.new do |s|

    s.name             = 'ProtonCore-TroubleShooting'
    s.module_name      = 'ProtonCoreTroubleShooting'
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
    
    s.dependency 'ProtonCore-Foundations', $version
    s.dependency 'ProtonCore-UIFoundations', $version
    s.dependency 'ProtonCore-Utilities', $version
    s.dependency 'ProtonCore-Doh', $version

    s.source_files = 'libraries/TroubleShooting/Sources/**/*.{h,m,swift}'
    
    s.ios.resource_bundles = {
      'Resources-TroubleShooting' => [
        'libraries/TroubleShooting/Resources/**/*.{xib,storyboard,geojson}'
      ],
      'Translations-TroubleShooting' => ['libraries/TroubleShooting/Sources/Resources/*']
    }

    s.osx.resource_bundles = {
      'Translations-TroubleShooting' => ['libraries/TroubleShooting/Sources/Resources/*']
    }

    s.test_spec 'Tests' do |trubleshoot_tests|
      trubleshoot_tests.dependency 'ProtonCore-TestingToolkit/UnitTests/Doh', $version
      trubleshoot_tests.source_files = 'libraries/TroubleShooting/Tests/UnitTests/**/*'
    end
    
    this_pod_does_not_have_subspecs(s)

end
