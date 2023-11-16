require_relative 'pods_configuration'

Pod::Spec.new do |s|

    s.name             = 'ProtonCore-AccountDeletion'
    s.module_name      = 'ProtonCoreAccountDeletion'
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

    s.dependency 'ProtonCore-Doh', $version
    s.dependency 'ProtonCore-Foundations', $version
    s.dependency 'ProtonCore-Log', $version
    s.dependency 'ProtonCore-Utilities', $version
    s.dependency 'ProtonCore-UIFoundations', $version
    s.dependency "ProtonCore-Authentication", $version
    s.dependency "ProtonCore-Networking", $version
    s.dependency "ProtonCore-Services", $version

    s.ios.source_files = "libraries/AccountDeletion/Sources/iOS/*.swift", "libraries/AccountDeletion/Sources/Shared/*.swift"
    s.osx.source_files = "libraries/AccountDeletion/Sources/macOS/*.swift", "libraries/AccountDeletion/Sources/Shared/*.swift"

    s.resource_bundles = { 
        'Translations-AccountDeletion' => ['libraries/AccountDeletion/Sources/Shared/Resources/*']
    }
            
    s.test_spec 'Tests' do |test_spec|
        test_spec.dependency "ProtonCore-TestingToolkit/UnitTests/AccountDeletion", $version
        test_spec.dependency "ProtonCore-TestingToolkit/UnitTests/Doh", $version
        test_spec.dependency "ProtonCore-TestingToolkit/UnitTests/Networking", $version
        test_spec.dependency "ProtonCore-TestingToolkit/UnitTests/Services", $version
        test_spec.source_files = 'libraries/AccountDeletion/Tests/UnitTests/**/*.swift'
    end

    this_pod_does_not_have_subspecs(s)
    
end
