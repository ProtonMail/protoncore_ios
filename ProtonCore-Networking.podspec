require_relative 'pods_configuration'

Pod::Spec.new do |s|
  
  s.name             = 'ProtonCore-Networking'
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
  
  s.dependency 'ProtonCore-CoreTranslation', $version
      
  s.source_files = "libraries/Networking/Sources/Networking/**/*"

  s.prepare_command = 'bash libraries/Networking/Tests/Networking/Scripts/prepare_obfuscated_constants.sh'

  s.pod_target_xcconfig = { 'APPLICATION_EXTENSION_API_ONLY' => 'NO' }
  
  s.default_subspecs = 'AFNetworking'

  s.subspec 'AFNetworking' do |afnetworking|
    afnetworking.dependency 'AFNetworking', '~> 4.0'
    afnetworking.dependency 'TrustKit'
  end
  
  s.subspec 'Alamofire' do |alamofire|
    alamofire.dependency 'Alamofire', '~> 5.2'
    alamofire.dependency 'TrustKit'
  end
  
  s.test_spec 'Tests' do |networking_tests|
    networking_tests.preserve_paths = 'libraries/Networking/Tests/Networking/Scripts/*'
    networking_tests.script_phase = {
        :name => 'Obfuscation',
        :script => '${PODS_TARGET_SRCROOT}/libraries/Networking/Tests/Networking/Scripts/prepare_obfuscated_constants.sh',
        :execution_position => :before_compile,
        :output_files => ['${PODS_TARGET_SRCROOT}/libraries/Networking/Tests/Networking/ObfuscatedConstants.swift']
    }
    networking_tests.source_files = 'libraries/Networking/Tests/Networking/*.swift'
    networking_tests.dependency 'ProtonCore-TestingToolkit/UnitTests/Networking', $version
    networking_tests.dependency 'ProtonCore-Doh', $version
    networking_tests.dependency 'ProtonCore-Services', $version
    networking_tests.dependency 'ProtonCore-APIClient', $version
    networking_tests.dependency 'OHHTTPStubs/Swift'
    networking_tests.dependency 'TrustKit'
  end 
end
