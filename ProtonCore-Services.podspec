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

    s.dependency 'ProtonCore-Log', $version
    s.dependency 'ProtonCore-DataModel', $version
    s.dependency 'ProtonCore-Doh', $version
    s.dependency 'ProtonCore-Networking', $version
    s.dependency 'ProtonCore-Utilities', $version

    s.dependency 'PromiseKit', '~> 6.0'
    s.dependency 'AwaitKit', '~> 5.2.0'
    s.dependency 'TrustKit'
    
    s.source_files = 'libraries/Networking/Sources/Services/*.swift'
    
    s.pod_target_xcconfig = { 'APPLICATION_EXTENSION_API_ONLY' => 'NO' }
    
end
