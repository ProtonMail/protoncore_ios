require_relative 'pods_configuration'

Pod::Spec.new do |s|

    s.name             = 'ProtonCore-Telemetry'
    s.module_name      = 'ProtonCoreTelemetry'
    s.version          = $version
    s.summary          = 'ProtonCore-Telemetry provides the API for tracking relevant telemetry events'
    
    s.description      = <<-DESC
    ProtonCore-Telemetry provides the API to all Proton Clients for tracking relevant telemetry events
    DESC

    s.homepage         = $homepage
    s.license          = $license
    s.author           = $author
    s.source           = $source

    s.ios.deployment_target = $ios_deployment_target

    s.swift_versions = $swift_versions

    s.pod_target_xcconfig = { 'APPLICATION_EXTENSION_API_ONLY' => 'YES' }

    this_pod_does_not_have_subspecs(s)

    s.dependency "ProtonCore-Networking", $version
    s.dependency "ProtonCore-Services", $version

    s.source_files = 'libraries/Telemetry/Sources/**/*.swift'

    s.test_spec 'Tests' do |test_spec|
        test_spec.dependency "ProtonCore-TestingToolkit/UnitTests/Core", $version
        test_spec.dependency "ProtonCore-TestingToolkit/UnitTests/Networking", $version
        test_spec.dependency "ProtonCore-TestingToolkit/UnitTests/Services", $version
        test_spec.source_files = 'libraries/Telemetry/Tests/**/*.swift'
    end
end
