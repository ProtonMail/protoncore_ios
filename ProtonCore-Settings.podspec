require_relative 'pods_configuration'

Pod::Spec.new do |s|

    s.name             = 'ProtonCore-Settings'
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

    s.default_subspecs = :none

    s.dependency 'ProtonCore-UIFoundations'

    s.source_files = 'libraries/Settings/Sources/**/*.swift'

    s.resource_bundles = {
        'Resources' => ['libraries/Settings/Resources/Settings.xcassets', 'libraries/Settings/Resources/*.lproj/*.strings' ]
    }

    s.test_spec 'Tests' do |settings_tests|
        settings_tests.source_files = 'libraries/Settings/Tests/**/*.swift'
    end
end
