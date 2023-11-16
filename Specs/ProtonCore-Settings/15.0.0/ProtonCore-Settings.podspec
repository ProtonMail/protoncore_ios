require_relative 'pods_configuration'

Pod::Spec.new do |s|

    s.name             = 'ProtonCore-Settings'
    s.module_name      = 'ProtonCoreSettings'
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

    this_pod_does_not_have_subspecs(s)

    s.dependency 'ProtonCore-UIFoundations', $version

    s.source_files = 'libraries/Settings/Sources/**/*.swift'

    s.resource_bundles = {
        'Resources-Settings' => ['libraries/Settings/Sources/Resources/*.lproj/*.strings' ]
    }

    s.test_spec 'Tests' do |settings_tests|
        settings_tests.dependency "ProtonCore-TestingToolkit/UnitTests/Core", $version
        settings_tests.source_files = 'libraries/Settings/Tests/**/*.swift'
    end
end
