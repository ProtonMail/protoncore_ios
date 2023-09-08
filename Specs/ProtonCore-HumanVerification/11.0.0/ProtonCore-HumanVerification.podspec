require_relative 'pods_configuration'

Pod::Spec.new do |s|

   s.name             = 'ProtonCore-HumanVerification'
   s.module_name      = 'ProtonCoreHumanVerification'
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

   s.ios.framework = 'UIKit'
   s.osx.framework = 'AppKit'
   
   s.dependency 'ProtonCore-UIFoundations', $version
   s.dependency 'ProtonCore-Foundations', $version
   s.dependency 'ProtonCore-Utilities', $version
   s.dependency 'ProtonCore-APIClient', $version
   s.dependency 'ProtonCore-Observability', $version

   s.dependency "ProtonCore-Crypto", $version
   s.dependency "ProtonCore-CryptoGoInterface", $version
   s.ios.source_files = 'libraries/HumanVerification/Sources/iOS/**/*.{h,m,swift}','libraries/HumanVerification/Sources/Shared/**/*.{h,m,swift}'
   s.osx.source_files = 'libraries/HumanVerification/Sources/macOS/**/*.{h,m,swift}', 'libraries/HumanVerification/Sources/Shared/**/*.{h,m,swift}'
   s.ios.resource_bundles = {
      'Resources-HumanVerification' => ['libraries/HumanVerification/Resources-iOS/**/*.{xib,storyboard,geojson}'],
      'Translations-HumanVerification' => ['libraries/HumanVerification/Resources-Shared/Translations/*']
   }
   s.osx.resource_bundles = {
      'Resources-HumanVerification' => ['libraries/HumanVerification/Resources-macOS/**/*.{xib,storyboard,geojson}'],
      'Translations-HumanVerification' => ['libraries/HumanVerification/Resources-Shared/Translations/*']
   }

   this_pod_does_not_have_subspecs(s)
    
   make_unit_tests_subspec = ->(spec, crypto) {
      spec.test_spec "#{crypto_test_subspec(crypto)}" do |test_spec|
         test_spec.dependency "ProtonCore-CryptoGoInterface", $version
         test_spec.dependency "ProtonCore-CryptoGoImplementation/#{crypto_subspec(crypto)}", $version
         test_spec.dependency "ProtonCore-TestingToolkit/UnitTests/Observability", $version
         test_spec.source_files = 'libraries/HumanVerification/Tests/UnitTests/**/*'
      end
   }

   make_all_go_variants(make_unit_tests_subspec, s)

end
