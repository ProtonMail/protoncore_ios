require_relative 'pods_configuration'

Pod::Spec.new do |s|

    s.name             = 'ProtonCore-PushNotifications'
    s.module_name      = 'ProtonCorePushNotifications'
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

    s.dependency 'ProtonCore-Log', $version
    s.dependency 'ProtonCore-DataModel', $version
    s.dependency 'ProtonCore-Keymaker', $version
    s.dependency 'ProtonCore-Networking', $version
    s.dependency "ProtonCore-Crypto", $version
    s.dependency "ProtonCore-CryptoGoInterface", $version
    s.dependency 'ProtonCore-FeatureFlags', $version
    s.dependency 'ProtonCore-Services', $version


    this_pod_does_not_have_subspecs(s)

    s.source_files = "libraries/PushNotifications/Sources/**/*.swift"
  
    make_unit_tests_subspec = ->(spec, crypto) {
      spec.test_spec "#{crypto_test_subspec(crypto)}" do |test_spec|
        test_spec.dependency "ProtonCore-CryptoGoImplementation/#{crypto_subspec(crypto)}", $version
        test_spec.dependency "ProtonCore-TestingToolkit", $version
        test_spec.source_files = 'libraries/PushNotifications/Tests/**/*.swift'
      end
    }
  
    make_all_go_variants(make_unit_tests_subspec, s)
  
end
