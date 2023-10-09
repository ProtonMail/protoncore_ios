require_relative 'pods_configuration'

Pod::Spec.new do |s|
    
    s.name             = 'ProtonCore-Payments'
    s.module_name      = 'ProtonCorePayments'
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

    s.dependency 'ReachabilitySwift', '~> 5.0.0'
    
    s.dependency 'ProtonCore-Foundations', $version
    s.dependency 'ProtonCore-Hash', $version
    s.dependency 'ProtonCore-Log', $version
    s.dependency "ProtonCore-Authentication", $version
    s.dependency "ProtonCore-Networking", $version
    s.dependency "ProtonCore-Services", $version
    s.source_files = "libraries/Payments/Sources/**/*.swift", "libraries/Payments/Sources/*.swift"

    s.resource_bundles = {
        'Translations-Payments' => ['libraries/Payments/Sources/Resources/*']
    }

    s.test_spec 'Tests' do |test_spec|
        test_spec.dependency "ProtonCore-TestingToolkit/UnitTests/Payments", $version
        test_spec.dependency "ProtonCore-Authentication", $version
        test_spec.dependency "ProtonCore-Challenge", $version
        test_spec.dependency "ProtonCore-DataModel", $version
        test_spec.dependency "ProtonCore-Doh", $version
        test_spec.dependency "ProtonCore-Log", $version
        test_spec.dependency "ProtonCore-Login", $version
        test_spec.dependency "ProtonCore-Services", $version
        test_spec.source_files = 'libraries/Payments/Tests/UnitTests/**/*.swift'
        test_spec.resources = 'libraries/Payments/Tests/UnitTests/Mocks/Responses/**/*.json'
    end

    this_pod_does_not_have_subspecs(s)

end
