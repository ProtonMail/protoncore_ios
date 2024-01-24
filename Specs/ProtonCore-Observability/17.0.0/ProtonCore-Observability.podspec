require_relative 'pods_configuration'

Pod::Spec.new do |s|

    s.name             = 'ProtonCore-Observability'
    s.module_name      = 'ProtonCoreObservability'
    s.version          = $version
    s.summary          = 'ProtonCore-Observability provides the API for tracking relevant anonymous events'
    
    s.description      = <<-DESC
    ProtonCore-Observability provides the API to all Proton Clients for tracking relevant anonymous events
    DESC
    
    s.homepage         = $homepage
    s.license          = $license
    s.author           = $author
    s.source           = $source
    
    s.ios.deployment_target = $ios_deployment_target
    s.osx.deployment_target = $macos_deployment_target
    
    s.swift_versions = $swift_versions

    s.pod_target_xcconfig = { 'APPLICATION_EXTENSION_API_ONLY' => 'YES' }

    this_pod_does_not_have_subspecs(s)

    s.source_files = 'libraries/Observability/Sources/**/*.swift'

    s.dependency "ProtonCore-Utilities", $version
    s.dependency "ProtonCore-Networking", $version

    s.test_spec "UnitTests" do |test_spec|
        test_spec.dependency 'JSONSchema'
        test_spec.dependency "ProtonCore-TestingToolkit/UnitTests/Networking", $version
        test_spec.source_files = "libraries/Observability/UnitTests/**/*.swift"
    end

    s.test_spec "IntegrationTests" do |test_spec|
        test_spec.dependency "ProtonCore-Networking", $version
        test_spec.dependency "ProtonCore-Services", $version
        test_spec.dependency "ProtonCore-Authentication", $version
        test_spec.dependency "ProtonCore-TestingToolkit/UnitTests/Core", $version
        test_spec.dependency "ProtonCore-TestingToolkit/UnitTests/FeatureSwitch", $version
        test_spec.source_files = "libraries/Observability/IntegrationTests/**/*.swift"

        add_dynamic_domain_to_info_plist(test_spec)
    end

end
