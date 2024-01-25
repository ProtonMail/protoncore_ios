require_relative 'pods_configuration'

Pod::Spec.new do |s|

    s.name             = 'ProtonCore-UIFoundations'
    s.module_name      = 'ProtonCoreUIFoundations'
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

    s.pod_target_xcconfig = { 'APPLICATION_EXTENSION_API_ONLY' => 'YES' }

    this_pod_does_not_have_subspecs(s)

    s.dependency 'ProtonCore-Log', $version
    s.dependency 'ProtonCore-Foundations', $version
    s.dependency 'ProtonCore-Utilities', $version

    s.source_files  = "libraries/UIFoundations/Sources/**/*.swift"

    s.preserve_path = "libraries/UIFoundations/Resources-iOS/LaunchScreenColors/**/*"

    s.ios.resource_bundles = {
        'Resources-UIFoundations' => ['libraries/UIFoundations/Resources-Shared/Assets.xcassets',
                                      'libraries/UIFoundations/Resources-iOS/Resources-iOS/**/*.{xib,storyboard,geojson}']
    }
    s.osx.resource_bundles = {
        'Resources-UIFoundations' => ['libraries/UIFoundations/Resources-Shared/Assets.xcassets']
    }

    s.test_spec 'Tests' do |uifoundations_tests|
        uifoundations_tests.dependency "ProtonCore-TestingToolkit/UnitTests/Core", $version
        uifoundations_tests.source_files = 'libraries/UIFoundations/Tests/**/*'
    end

end
