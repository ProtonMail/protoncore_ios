require_relative 'pods_configuration'

Pod::Spec.new do |s|

    s.name             = 'ProtonCore-Services'
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

    no_default_subspecs(s)

    s.dependency 'PromiseKit', '~> 6.0'
    s.dependency 'AwaitKit', '~> 5.2.0'
    s.dependency 'TrustKit'

    s.dependency 'ProtonCore-Log', $version
    s.dependency 'ProtonCore-DataModel', $version
    s.dependency 'ProtonCore-Doh', $version
    s.dependency 'ProtonCore-Utilities', $version

    source_files = 'libraries/Networking/Sources/Services/*.swift'

    s.subspec 'AFNetworking' do |afnetworking|
        afnetworking.source_files = source_files
        afnetworking.dependency 'ProtonCore-Networking/AFNetworking', $version
    end

    s.subspec 'Alamofire' do |alamofire|
        alamofire.source_files = source_files
        alamofire.dependency 'ProtonCore-Networking/Alamofire', $version
    end
    
    s.pod_target_xcconfig = { 'APPLICATION_EXTENSION_API_ONLY' => 'NO' }
    
end
