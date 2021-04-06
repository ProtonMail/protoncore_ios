require_relative 'pods_configuration'

Pod::Spec.new do |s|

    s.name             = 'ProtonCore-Login'
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
    s.dependency 'ProtonCore-Crypto', $version
    s.dependency 'ProtonCore-OpenPGP', $version
    s.dependency 'ProtonCore-Authentication', $version
    s.dependency 'ProtonCore-Authentication-KeyGeneration', $version
    s.dependency 'ProtonCore-Foundations', $version
    s.dependency 'ProtonCore-UIFoundations', $version
    s.dependency 'ProtonCore-CoreTranslation', $version
    s.dependency 'ProtonCore-Challenge', $version
    s.dependency 'ProtonCore-DataModel', $version
    s.dependency 'ProtonCore-HumanVerification', $version
    
    s.dependency 'TrustKit'
    
    s.source_files  = "libraries/Login/Sources/*.swift", "libraries/Login/Sources/**/*.swift"
    s.resource_bundles = {
        'PMLogin' => ['libraries/Login/Sources/Assets.xcassets', "libraries/Login/Sources/**/*.xib", "libraries/Login/Sources/**/*.storyboard"]
    }
    
    s.test_spec 'Tests' do |login_tests|
        login_tests.script_phase = {
            :name => 'Obfuscation',
            :script => '../../../libraries/Login/Scripts/prepare_obfuscated_constants.sh',
            :execution_position => :before_compile,
            :output_files => ['../../../libraries/Login/Tests/ObfuscatedConstants.swift']
        }
        login_tests.source_files = 'libraries/Login/Tests/ObfuscatedConstants.swift', 'libraries/Login/Tests/*.swift', 'libraries/Login/Tests/**/*.swift'
        login_tests.resources = "libraries/Login/Tests/Mocks/Responses/**/*"
        login_tests.dependency 'ProtonCore-TestingToolkit/UnitTests/Login', $version
        login_tests.dependency 'OHHTTPStubs/Swift'
        login_tests.dependency 'TrustKit'
    end

    s.framework = 'UIKit'
    s.pod_target_xcconfig = { 'APPLICATION_EXTENSION_API_ONLY' => 'NO' }
            
end
