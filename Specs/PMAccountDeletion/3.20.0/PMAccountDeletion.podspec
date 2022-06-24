require_relative 'pods_configuration'

Pod::Spec.new do |s|

    s.name             = 'PMAccountDeletion'
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

    s.static_framework = true

    s.dependency 'OpenPGP'
    s.dependency 'PMCrypto'
    s.dependency 'PMCoreTranslation'
    s.dependency 'PMCommon'
    s.dependency 'PMLog'
    s.dependency 'PMUIFoundations'
    s.dependency "PMAuthentication"
    
    s.ios.source_files = "libraries/AccountDeletion/Sources/iOS/*.swift", "libraries/AccountDeletion/Sources/Shared/*.swift", "libraries/AccountDeletion/Sources/PMAccountDeletion/*.swift"
    
end
