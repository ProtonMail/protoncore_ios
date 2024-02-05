require_relative 'pods_configuration'

Pod::Spec.new do |s|
  s.name             = 'ProtonCore-Keymaker'
  s.module_name      = 'ProtonCoreKeymaker'
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

  s.dependency 'EllipticCurveKeyPair', '~> 2.0'
  s.dependency "ProtonCore-CryptoGoInterface", $version

  s.source_files = 'libraries/Keymaker/Sources/*.swift',
                   'libraries/Keymaker/Sources/**/*.swift'
                   "libraries/Keymaker/Docs/**/*"

  this_pod_does_not_have_subspecs(s)

  make_unit_tests_subspec = ->(spec, crypto) {
      spec.test_spec "#{crypto_test_subspec(crypto)}" do |test_spec|
          test_spec.dependency "ProtonCore-CryptoGoImplementation/#{crypto_subspec(crypto)}", $version
          test_spec.dependency "ProtonCore-TestingToolkit/UnitTests/Core", $version
          test_spec.source_files = 'libraries/Keymaker/Tests/**/*'
      end
  }

  make_all_go_variants(make_unit_tests_subspec, s)
  
  s.test_spec 'AppHostedTests' do |test_spec|
    test_spec.source_files = 'libraries/Keymaker/AppHostedTests/**/*'
    test_spec.requires_app_host = true
    test_spec.osx.app_host_name = s.name + "/macOS-AppHost"
    test_spec.ios.app_host_name = s.name + "/iOS-AppHost"
    test_spec.osx.dependency s.name + "/macOS-AppHost"
    test_spec.ios.dependency s.name + "/iOS-AppHost"
  end

  [Platform.osx, Platform.ios].each do |platform|
    platform_name = "#{Platform.string_name(platform.symbolic_name)}"
    s.app_spec "#{platform_name}-AppHost" do |app_spec|
      app_spec.source_files = "libraries/Keymaker/AppHosts/#{platform_name}/*.m"
      app_spec.info_plist = { 'CFBundleIdentifier' => "me.proton.account.keymaker.#{platform_name}.apphost" }
      app_spec.pod_target_xcconfig = {
        'CODE_SIGN_ENTITLEMENTS' => "$(PODS_TARGET_SRCROOT)/libraries/Keymaker/AppHosts/#{platform_name}/AppHost.entitlements",
        'PRODUCT_BUNDLE_IDENTIFIER' => "me.proton.account.keymaker.#{platform_name}.apphost",
        'CODE_SIGN_IDENTITY' => 'Apple Development', # both macOS and iOS
        'CODE_SIGN_STYLE' => 'Automatic', 'PROVISIONING_PROFILE_SPECIFIER' => '', # Automatically managed
        'DEVELOPMENT_TEAM' => '2SB5Z68H26' # Proton AG
      }
    end
  end
end
