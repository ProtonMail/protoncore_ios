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

  s.pod_target_xcconfig = { 'APPLICATION_EXTENSION_API_ONLY' => 'YES' }

  s.dependency 'ProtonCore-CoreTranslation', $version
  s.dependency 'ProtonCore-Log', $version
  s.dependency 'ProtonCore-Utilities', $version
  s.dependency 'ProtonCore-Environment', $version

  s.dependency "Alamofire", '5.4.4'
  s.dependency 'TrustKit'

  this_pod_does_not_have_subspecs(s)

  s.source_files = "libraries/Networking/Sources/**/*"

  s.test_spec "Tests" do |test_spec|
    test_spec.source_files = "libraries/Networking/Tests/*.swift"
    test_spec.dependency "ProtonCore-TestingToolkit/UnitTests/Networking", $version
    test_spec.dependency "ProtonCore-Doh", $version
    test_spec.dependency "OHHTTPStubs/Swift"
  end

end
