
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
    
    s.dependency 'ProtonCore-Log', $version
    s.dependency 'ProtonCore-CoreTranslation', $version
    s.dependency 'ProtonCore-Foundations', $version
    s.dependency 'ProtonCore-UIFoundations', $version
    s.dependency 'ProtonCore-Payments', $version
    
    s.source_files  = "libraries/PaymentsUI/Sources/**/*.swift"

    s.resource_bundles = {
        'Resources-PaymentsUI' => ['libraries/PaymentsUI/Sources/Assets.xcassets', "libraries/PaymentsUI/Sources/**/*.xib", "libraries/PaymentsUI/Sources/**/*.storyboard"]
    }

    # s.test_spec 'Tests' do |paymentsui_tests|
    #     paymentsui_tests.source_files = 'libraries/PaymentsUI/Tests/**/*.swift'
    #     paymentsui_tests.dependency 'OHHTTPStubs/Swift'
    # end

    s.pod_target_xcconfig = { 'APPLICATION_EXTENSION_API_ONLY' => 'NO' }

end
