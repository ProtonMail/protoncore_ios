require_relative 'pods_configuration'

Pod::Spec.new do |s|

    s.name             = 'ProtonCore-UIFoundations-V5'
    s.module_name      = 'ProtonCore_UIFoundations'
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
    s.dependency 'ProtonCore-CoreTranslation-V5', $version
    s.dependency 'ProtonCore-Foundations', $version
    s.dependency 'ProtonCore-Utilities', $version

    s.ios.source_files  = "libraries/UIFoundations/Sources/Colors/**/*.swift", 
                          "libraries/UIFoundations/Sources/Components/**/*.swift", 
                          "libraries/UIFoundations/Sources/Font/**/*.swift", 
                          "libraries/UIFoundations/Sources/Icons/**/*.swift", 
                          "libraries/UIFoundations/Sources/Utils/**/*.swift", 
                          "libraries/UIFoundations/Sources/V5/**/*.swift"
    s.ios.exclude_files = "libraries/UIFoundations/Sources/Icons/ProtonIconSet.swift", 
                          "libraries/UIFoundations/Sources/Colors/ProtonColorPaletteiOS.swift",
                          "libraries/UIFoundations/Sources/Colors/ProtonColorPalettemacOS.swift",
                          "libraries/UIFoundations/Sources/Utils/Settings.swift"

    s.osx.source_files  = "libraries/UIFoundations/Sources/Components/PMUIFoundations.swift", 
                          "libraries/UIFoundations/Sources/Colors/ColorProvider.swift", 
                          "libraries/UIFoundations/Sources/Components/Extension/NSColor+Helper.swift",
                          "libraries/UIFoundations/Sources/Utils/Brand.swift", 
                          "libraries/UIFoundations/Sources/Icons/**/*.swift",
                          "libraries/UIFoundations/Sources/V5/**/*.swift"
    s.osx.exclude_files = "libraries/UIFoundations/Sources/Icons/ProtonIconSet.swift",
                          "libraries/UIFoundations/Sources/V5/SplashScreenViewControllerFactory.swift"

    s.ios.preserve_path = "libraries/UIFoundations/LaunchScreens/**/*"
    
    s.ios.resource_bundles = {
        'Resources-UIFoundations' => ['libraries/UIFoundations/Sources/Assets-V5.xcassets', 
                                      'libraries/UIFoundations/Sources/**/*.{xib,storyboard,geojson}',
                                      'libraries/UIFoundations/LaunchScreens/*.storyboard']
    }
    s.osx.resource_bundles = {
        'Resources-UIFoundations' => ['libraries/UIFoundations/Sources/Assets-V5.xcassets']
    }
    
    s.test_spec 'Tests' do |uifoundations_tests|
        uifoundations_tests.source_files = 'libraries/UIFoundations/Tests/**/*'
    end

end
