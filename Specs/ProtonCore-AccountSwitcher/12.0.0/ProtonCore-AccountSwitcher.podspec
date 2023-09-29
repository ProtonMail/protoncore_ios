require_relative 'pods_configuration'

Pod::Spec.new do |s|

    s.name             = 'ProtonCore-AccountSwitcher'
    s.module_name      = 'ProtonCoreAccountSwitcher'
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
    s.dependency 'ProtonCore-UIFoundations', $version
    s.dependency 'ProtonCore-Utilities', $version

    this_pod_does_not_have_subspecs(s)

    s.source_files = "libraries/AccountSwitcher/Sources/**/*.swift"
    s.resource_bundles = { 
        'Resources-AccountSwitcher' => ['libraries/AccountSwitcher/Resources-iOS/Resources/*.xib'],
        'Translations-AccountSwitcher' => ['libraries/AccountSwitcher/Sources/Resources/*']
    }

    s.test_spec 'Tests' do |account_switcher_tests|
      account_switcher_tests.dependency "ProtonCore-TestingToolkit/UnitTests/Core", $version
        account_switcher_tests.source_files = 'libraries/AccountSwitcher/Tests/UnitTests/**/*'
    end
    
end
