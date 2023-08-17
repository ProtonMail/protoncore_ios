
require_relative 'pods_configuration'

Pod::Spec.new do |s|
    
    s.name             = 'ProtonCore-PaymentsUI'
    s.module_name      = 'ProtonCorePaymentsUI'
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
    
    s.framework = 'UIKit'

    s.dependency 'ProtonCore-Log', $version
    s.dependency 'ProtonCore-Foundations', $version
    s.dependency 'ProtonCore-UIFoundations', $version
    s.dependency 'ProtonCore-Observability', $version
    s.dependency "ProtonCore-Payments", $version
    s.source_files = "libraries/PaymentsUI/Sources/**/*.swift"
    s.resource_bundles = {
       'Resources-PaymentsUI' => "libraries/PaymentsUI/Resources/**/*.{xib,storyboard}",
       'Translations-PaymentsUI' => ['libraries/PaymentsUI/Sources/Resources/Translations/*']
    }

    s.test_spec 'Tests' do |test_spec|
        test_spec.dependency "swift-snapshot-testing"
        test_spec.dependency "ProtonCore-Payments"
        test_spec.dependency "ProtonCore-ObfuscatedConstants", $version
        test_spec.dependency "ProtonCore-TestingToolkit/UnitTests/Observability", $version
        test_spec.dependency "ProtonCore-TestingToolkit/UnitTests/Payments", $version
        test_spec.dependency "ProtonCore-TestingToolkit/UnitTests/Observability", $version
        test_spec.source_files = 'libraries/PaymentsUI/Tests/UnitTests/**/*.swift'
    end

    this_pod_does_not_have_subspecs(s)

end
