require_relative 'pods_configuration'

Pod::Spec.new do |s|
    
    s.name             = 'ProtonCore-ObfustatedConstants'
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
       
    script_phase = {
        :name => 'Obfuscation',
        :script => '${PODS_TARGET_SRCROOT}/libraries/ObfuscatedConstants/Scripts/prepare_obfuscated_constants.sh',
        :execution_position => :before_compile,
        :output_files => ['${PODS_TARGET_SRCROOT}/libraries/ObfuscatedConstants/TestData/ObfuscatedConstants.swift']
    }
    
    s.script_phase = script_phase
    s.source_files = "libraries/ObfuscatedConstants/TestData/**/*.swift"
    s.dependency 'SwiftOTP'
end
