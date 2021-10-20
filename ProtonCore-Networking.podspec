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
  s.dependency 'ProtonCore-Log', $version
  
  s.pod_target_xcconfig = { 'APPLICATION_EXTENSION_API_ONLY' => 'NO' }
  
  s.default_subspecs = 'Alamofire'

  tests_preserve_paths = 'libraries/Networking/Tests/Networking/Scripts/*'

  s.dependency 'TrustKit'

  source_files = "libraries/Networking/Sources/Networking/**/*"

  s.subspec 'AFNetworking' do |afnetworking|
    afnetworking.dependency 'AFNetworking', '~> 4.0'
    afnetworking.source_files = source_files
    afnetworking.test_spec 'Tests' do |networking_tests|
      networking_tests.preserve_paths = tests_preserve_paths
      networking_tests.source_files = 'libraries/Networking/Tests/Networking/*.swift'
      networking_tests.dependency 'ProtonCore-TestingToolkit/UnitTests/Networking', $version
      networking_tests.dependency 'ProtonCore-Doh', $version
      networking_tests.dependency 'OHHTTPStubs/Swift'
    end
  end
  
  s.subspec 'Alamofire' do |alamofire|
    alamofire.dependency 'Alamofire', '~> 5.2'
    alamofire.source_files = source_files
    alamofire.test_spec 'Tests' do |networking_tests|
      networking_tests.preserve_paths = tests_preserve_paths
      networking_tests.source_files = 'libraries/Networking/Tests/Networking/*.swift'
      networking_tests.dependency 'ProtonCore-TestingToolkit/UnitTests/Networking', $version
      networking_tests.dependency 'ProtonCore-Doh', $version
      networking_tests.dependency 'OHHTTPStubs/Swift'
    end
  end
  

end
