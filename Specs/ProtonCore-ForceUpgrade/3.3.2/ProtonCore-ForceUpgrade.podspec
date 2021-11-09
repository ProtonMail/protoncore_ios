require_relative 'pods_configuration'

Pod::Spec.new do |s|

    s.name             = 'ProtonCore-ForceUpgrade'
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

    no_default_subspecs(s)

    s.dependency 'ProtonCore-CoreTranslation', $version
    s.dependency 'ProtonCore-UIFoundations', $version
    
    source_files = 'libraries/ForceUpgrade/Sources/**/*.{h,m,swift}'
    resource_bundles = {'Resources-FU' => ['libraries/ForceUpgrade/Sources/**/*.{xib,storyboard,xcassets}']}
    exclude_files = "Classes/Exclude"

    test_source_files = 'libraries/ForceUpgrade/Tests/**/*'

    s.subspec 'AFNetworking' do |afnetworking|
        afnetworking.dependency 'ProtonCore-Networking/AFNetworking', $version
        afnetworking.source_files = source_files
        afnetworking.resource_bundles = resource_bundles
        afnetworking.exclude_files = exclude_files

        afnetworking.test_spec 'Tests' do |forceupgrade_tests|
            forceupgrade_tests.source_files = test_source_files
        end
    end

    s.subspec 'Alamofire' do |alamofire|
        alamofire.dependency 'ProtonCore-Networking/Alamofire', $version
        alamofire.source_files = source_files
        alamofire.resource_bundles = resource_bundles
        alamofire.exclude_files = exclude_files
        alamofire.test_spec 'Tests' do |forceupgrade_tests|
            forceupgrade_tests.source_files = test_source_files
        end
    end

    s.framework = 'UIKit'
    s.pod_target_xcconfig = { 'APPLICATION_EXTENSION_API_ONLY' => 'NO' }

end
