require_relative 'pods_configuration'

Pod::Spec.new do |s|

    s.name             = 'ProtonCore-Common'
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

    s.default_subspecs = :none

    s.dependency 'ProtonCore-UIFoundations', $version

    source_files = 'libraries/Common/Sources/*'
    test_source_files = 'libraries/Common/Tests/**/*.swift'

    s.subspec 'AFNetworking' do |afnetworking|
        afnetworking.dependency 'ProtonCore-Services/AFNetworking', $version
        afnetworking.dependency 'ProtonCore-Networking/AFNetworking', $version
        afnetworking.source_files = source_files

        afnetworking.test_spec 'Tests' do |common_tests|
            common_tests.source_files = test_source_files
        end
    end

    s.subspec 'Alamofire' do |alamofire|
        alamofire.dependency 'ProtonCore-Services/Alamofire', $version
        alamofire.dependency 'ProtonCore-Networking/Alamofire', $version
        alamofire.source_files = source_files

        alamofire.test_spec 'Tests' do |common_tests|
            common_tests.source_files = test_source_files
        end
    end

    s.pod_target_xcconfig = { 'APPLICATION_EXTENSION_API_ONLY' => 'NO' }
    
end
