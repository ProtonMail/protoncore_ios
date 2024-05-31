require_relative 'pods_configuration'

Pod::Spec.new do |s|
    
    s.name             = 'ProtonCore-ObfuscatedConstants'
    s.module_name      = 'ProtonCoreObfuscatedConstants'
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

    s.dependency 'TrustKit'
    s.dependency 'SwiftOTP', '~> 2.0'
    s.dependency 'CryptoSwift', '1.3.1'
    s.dependency 'ProtonCore-Authentication', $version
    s.dependency 'ProtonCore-DataModel', $version
    s.dependency 'ProtonCore-Networking', $version
     
    s.preserve_paths = 'libraries/ObfuscatedConstants/Scripts/*'
    s.source_files = [
        "libraries/ObfuscatedConstants/Sources/ObfuscatedConstants.swift", 
        "libraries/ObfuscatedConstants/Sources/LoginTestUser.swift", 
        "libraries/ObfuscatedConstants/Sources/TestData.swift",
        "libraries/ObfuscatedConstants/Sources/TestUser.swift",
    ]
    s.script_phase = {
        :name => 'Create ObfuscatedConstants file',
        :script => '${PODS_TARGET_SRCROOT}/libraries/ObfuscatedConstants/Scripts/create_obfuscated_constants.sh',
        :execution_position => :before_compile,
        :output_files => ['${PODS_TARGET_SRCROOT}/libraries/ObfuscatedConstants/Sources/ObfuscatedConstants.swift']
    }
    
end
