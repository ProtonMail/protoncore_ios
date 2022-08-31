
require_relative 'pods_configuration'

Pod::Spec.new do |s|
    
    s.name             = 'ProtonCore-PaymentsUI'
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
    s.dependency 'ProtonCore-CoreTranslation', $version
    s.dependency 'ProtonCore-Foundations', $version
    s.dependency 'ProtonCore-UIFoundations', $version

    make_subspec = ->(spec, crypto) {
        spec.subspec "#{crypto_subspec(crypto)}" do |subspec|
            subspec.dependency "ProtonCore-Payments/#{crypto_subspec(crypto)}", $version
            subspec.source_files = "libraries/PaymentsUI/Sources/**/*.swift"
            subspec.exclude_files = "libraries/PaymentsUI/Sources/V5/**/*.swift"
            subspec.resource_bundles = {
               'Resources-PaymentsUI' => ["libraries/PaymentsUI/Sources/Cells/*.xib", "libraries/PaymentsUI/Sources/Views/*.xib", "libraries/PaymentsUI/Sources/PaymentsUI.storyboard"]
            }

            subspec.test_spec 'Tests' do |test_spec|
                test_spec.dependency "ProtonCore-TestingToolkit/UnitTests/Payments/#{crypto_subspec(crypto)}", $version
                test_spec.source_files = 'libraries/PaymentsUI/Tests/**/*.swift'
                test_spec.exclude_files = 'libraries/PaymentsUI/Tests/V5/**/*.swift'
            end
        end
    }

    no_default_subspecs(s)
    make_subspec.call(s, :crypto)
    make_subspec.call(s, :crypto_vpn)

end
