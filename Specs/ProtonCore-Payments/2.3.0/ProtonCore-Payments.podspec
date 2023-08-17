require_relative 'pods_configuration'

Pod::Spec.new do |s|
    
    s.name             = 'ProtonCore-Payments'
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
    
    s.dependency 'ProtonCore-APIClient', $version
    s.dependency 'ProtonCore-Authentication', $version
    s.dependency 'ProtonCore-Log', $version
    s.dependency 'ProtonCore-Services', $version
    s.dependency 'ProtonCore-SRP', $version
    s.dependency 'ProtonCore-CoreTranslation', $version
    s.dependency 'ProtonCore-Foundations', $version
    
    s.dependency 'AwaitKit', '~> 5.2.0'
    s.dependency 'ReachabilitySwift', '~> 5.0.0'
    
    s.source_files  = "libraries/Payments/Sources/**/*.swift", "libraries/v/Sources/**/*.swift"
    
    s.test_spec 'Tests' do |payments_tests|
        payments_tests.source_files = 'libraries/Payments/Tests/**/*.swift'
        payments_tests.dependency 'OHHTTPStubs/Swift'
        payments_tests.dependency 'ProtonCore-TestingToolkit/UnitTests/Payments', $version
    end

    s.pod_target_xcconfig = { 'APPLICATION_EXTENSION_API_ONLY' => 'NO' }

end
