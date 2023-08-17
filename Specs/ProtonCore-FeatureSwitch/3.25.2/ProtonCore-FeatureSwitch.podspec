require_relative 'pods_configuration'

Pod::Spec.new do |s|

    s.name             = 'ProtonCore-FeatureSwitch'
    s.module_name      = 'ProtonCoreFeatureSwitch'
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
    
    s.dependency 'ProtonCore-Foundations', $version
    s.dependency 'ProtonCore-Utilities', $version
    s.dependency 'ProtonCore-Doh', $version
    s.dependency 'ProtonCore-CoreTranslation', $version

    s.source_files = 'libraries/FeatureSwitch/Sources/**/*.{h,m,swift}'
    
    s.resource_bundles = {'Resources-FeatureSwitch' => [
      'libraries/FeatureSwitch/Resources/**/*.{xib,storyboard,geojson,json}',
      'libraries/FeatureSwitch/Sources/**/*.{xib,storyboard,geojson,json}'
      ]
    }

    s.test_spec 'Tests' do |featureswitch_tests|
      featureswitch_tests.dependency 'ProtonCore-TestingToolkit/UnitTests/Doh', $version
      featureswitch_tests.source_files = 'libraries/FeatureSwitch/Tests/**/*.swift'
      featureswitch_tests.resource = 'libraries/FeatureSwitch/Tests/Resources/**/*'
    end
    
    this_pod_does_not_have_subspecs(s)

end
