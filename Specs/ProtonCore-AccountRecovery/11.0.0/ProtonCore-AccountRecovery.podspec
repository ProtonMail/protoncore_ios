require_relative 'pods_configuration'

Pod::Spec.new do |s|

    s.name             = 'ProtonCore-AccountRecovery'
    s.module_name      = 'ProtonCoreAccountRecovery'
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
    s.macos.deployment_target = $macos_deployment_target
    
    s.swift_versions = $swift_versions

    s.pod_target_xcconfig = { 'APPLICATION_EXTENSION_API_ONLY' => 'NO' }

    # s.framework = 'UIKit'

    s.dependency 'ProtonCore-FeatureSwitch', $version
    s.dependency 'ProtonCore-PushNotifications', $version
    s.dependency 'ProtonCore-Services', $version
    s.dependency 'ProtonCore-Authentication', $version
    s.dependency 'ProtonCore-DataModel', $version
    s.dependency 'ProtonCore-UIFoundations', $version
    s.dependency 'ProtonCore-Networking', $version
    s.dependency 'ProtonCore-PasswordRequest', $version
        
    this_pod_does_not_have_subspecs(s)

    s.source_files = "libraries/AccountRecovery/Sources/**/*.swift"
    
    s.resource_bundles = {
      "Resources-AccountRecovery" => ['libraries/AccountRecovery/Resources/**/*']
    }


    s.test_spec 'Tests' do |test_spec|
      test_spec.dependency 'ProtonCore-TestingToolkit', $version
      test_spec.dependency 'ViewInspector'
      test_spec.source_files =  'libraries/AccountRecovery/Tests/**/*.swift'
    end

end

