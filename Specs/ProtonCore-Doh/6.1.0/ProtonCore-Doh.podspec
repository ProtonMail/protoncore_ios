require_relative 'pods_configuration'

Pod::Spec.new do |s|
    
    s.name             = 'ProtonCore-Doh'
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

    s.pod_target_xcconfig = { 'APPLICATION_EXTENSION_API_ONLY' => 'YES' }
    
    s.dependency "ProtonCore-Log", $version
    s.dependency "ProtonCore-Utilities", $version
    s.dependency "ProtonCore-FeatureSwitch", $version

    this_pod_does_not_have_subspecs(s)
        
    s.source_files = "libraries/Doh/Sources/*.swift"

    s.test_spec 'UnitTests' do |doh_tests|
      doh_tests.dependency 'ProtonCore-TestingToolkit/UnitTests/Doh', $version
      doh_tests.dependency "ProtonCore-ObfuscatedConstants", $version
      doh_tests.source_files = "libraries/Doh/Tests/Unit/*.swift"
      doh_tests.dependency 'OHHTTPStubs/Swift'

      doh_tests.pod_target_xcconfig = { 'APPLICATION_EXTENSION_API_ONLY' => 'NO' }
    end

    s.test_spec 'IntegrationTests' do |doh_tests|
      doh_tests.dependency "ProtonCore-TestingToolkit/UnitTests/Core", $version
      doh_tests.dependency 'ProtonCore-TestingToolkit/UnitTests/FeatureSwitch', $version
      doh_tests.dependency "ProtonCore-Environment", $version
      doh_tests.dependency "ProtonCore-Authentication", $version
      doh_tests.dependency "ProtonCore-Observability", $version
      doh_tests.dependency "ProtonCore-Services", $version
      doh_tests.source_files = "libraries/Doh/Tests/Integration/*.swift"

      add_dynamic_domain_to_info_plist(doh_tests)

      doh_tests.pod_target_xcconfig = { 'APPLICATION_EXTENSION_API_ONLY' => 'NO' }
    end
    
end
