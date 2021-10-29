require_relative 'pods_configuration'

Pod::Spec.new do |s|

    s.name             = 'ProtonCore-HumanVerification'
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
    
    s.dependency 'ProtonCore-UIFoundations', $version
    s.dependency 'ProtonCore-CoreTranslation', $version
    s.dependency 'ProtonCore-Foundations', $version
    s.dependency 'ProtonCore-Utilities', $version

    source_files = ['libraries/HumanVerification/Sources/*.{h,m,swift}', 'libraries/HumanVerification/Sources/**/*.{h,m,swift}']
    test_source_files = 'libraries/HumanVerification/Tests/**/*'

    s.subspec 'AFNetworking' do |afnetworking|
        afnetworking.dependency 'ProtonCore-APIClient/AFNetworking', $version
        afnetworking.source_files = source_files

        afnetworking.test_spec 'Tests' do |humanverification_tests|
            humanverification_tests.dependency 'ProtonCore-TestingToolkit/UnitTests/HumanVerification/AFNetworking', $version
            humanverification_tests.source_files = test_source_files
        end
    end

    s.subspec 'Alamofire' do |alamofire|
        alamofire.dependency 'ProtonCore-APIClient/Alamofire', $version
        alamofire.source_files = source_files

        alamofire.test_spec 'Tests' do |humanverification_tests|
            humanverification_tests.dependency 'ProtonCore-TestingToolkit/UnitTests/HumanVerification/Alamofire', $version
            humanverification_tests.source_files = test_source_files
        end
    end
    
    s.resource_bundles = {'Resources-HV' => ['libraries/HumanVerification/Sources/**/*.{xib,storyboard,xcassets,geojson}']}
    s.exclude_files = "Classes/Exclude"

    s.framework = 'UIKit'
    s.pod_target_xcconfig = { 'APPLICATION_EXTENSION_API_ONLY' => 'NO' }

end
