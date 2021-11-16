require_relative 'pods_configuration'

Pod::Spec.new do |s|

    s.name             = 'ProtonCore-UIFoundations'
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

    this_pod_does_not_have_subspecs(s)
        
    s.dependency 'ProtonCore-Log', $version
    s.dependency 'ProtonCore-CoreTranslation', $version
    s.dependency 'ProtonCore-Foundations', $version

    s.ios.source_files  = "libraries/UIFoundations/Sources/**/*.swift"
    s.osx.source_files  = "libraries/UIFoundations/Sources/PMUIFoundations.swift", "libraries/UIFoundations/Sources/Colors/ColorProvider.swift", "libraries/UIFoundations/Sources/Colors/ProtonColorPallete.swift", "libraries/UIFoundations/Sources/Extension/NSColor+Helper.swift",
        "libraries/UIFoundations/Sources/Utils/Brand.swift"
    
    s.ios.resource_bundles = {
        'Resources-UIFoundations' => ['libraries/UIFoundations/Sources/Assets.xcassets', "libraries/UIFoundations/Sources/**/*.{xib,storyboard,geojson}"]
    }
    s.osx.resource_bundles = {
        'Resources-UIFoundations' => ['libraries/UIFoundations/Sources/Assets.xcassets']
    }
    
    s.test_spec 'Tests' do |uifoundations_tests|
        uifoundations_tests.source_files = 'libraries/UIFoundations/Tests/**/*'
    end

end
