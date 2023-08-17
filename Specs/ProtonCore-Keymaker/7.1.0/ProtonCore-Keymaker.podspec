require_relative 'pods_configuration'

Pod::Spec.new do |s|
  s.name = 'ProtonCore-Keymaker'
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

  make_subspec = lambda { |spec, crypto|
    spec.subspec "#{crypto_subspec(crypto)}" do |subspec|
      subspec.dependency "ProtonCore-CryptoGoImplementation/#{crypto_subspec(crypto)}", $version
      subspec.source_files = 'libraries/Keymaker/Sources/*.swift',
                             'libraries/Keymaker/Sources/**/*.swift'
                             "libraries/Keymaker/Docs/**/*"
      subspec.test_spec 'Tests' do |test_spec|
        test_spec.source_files = 'libraries/Keymaker/Tests/**/*'
      end
      
      subspec.test_spec 'AppHostedTests' do |test_spec|
        test_spec.source_files = 'libraries/Keymaker/AppHostedTests/**/*'
        test_spec.requires_app_host = true
        test_spec.osx.app_host_name = s.name + "/macOS-AppHost"
        test_spec.ios.app_host_name = s.name + "/iOS-AppHost"
        test_spec.osx.dependency s.name + "/macOS-AppHost"
        test_spec.ios.dependency s.name + "/iOS-AppHost"
      end
    end
  }

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

  make_all_go_variants(make_subspec, s)

  no_default_subspecs(s)
end
