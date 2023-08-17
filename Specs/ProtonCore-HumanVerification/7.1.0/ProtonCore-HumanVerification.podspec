require_relative 'pods_configuration'

Pod::Spec.new do |s|

    s.name             = 'ProtonCore-HumanVerification'
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
    s.dependency 'ProtonCore-CoreTranslation', $version
    s.dependency 'ProtonCore-Foundations', $version
    s.dependency 'ProtonCore-Utilities', $version
    s.dependency 'ProtonCore-APIClient', $version
    s.dependency 'ProtonCore-Observability', $version
    
    
    make_subspec = ->(spec, crypto) {
        spec.subspec "#{crypto_subspec(crypto)}" do |subspec|
            subspec.dependency "ProtonCore-Crypto/#{crypto_subspec(crypto)}", $version
            subspec.dependency "ProtonCore-CryptoGoImplementation/#{crypto_subspec(crypto)}", $version
            subspec.ios.source_files = 'libraries/HumanVerification/Sources/iOS/**/*.{h,m,swift}','libraries/HumanVerification/Sources/Shared/**/*.{h,m,swift}'
            subspec.osx.source_files = 'libraries/HumanVerification/Sources/macOS/**/*.{h,m,swift}', 'libraries/HumanVerification/Sources/Shared/**/*.{h,m,swift}'
            subspec.ios.resource_bundles = {'Resources-HumanVerification' => [
               'libraries/HumanVerification/Resources/**/*.{xib,storyboard,geojson}',
               'libraries/HumanVerification/Sources/iOS/*.{xib,storyboard,geojson}'
            ]}
            subspec.osx.resource_bundles = {'Resources-HumanVerification' => [
               'libraries/HumanVerification/Resources/**/*.{xib,storyboard,geojson}',
               'libraries/HumanVerification/Sources/macOS/*.{xib,storyboard,geojson}'
            ]}

            subspec.test_spec 'Tests' do |test_spec|
               test_spec.dependency "ProtonCore-CryptoGoInterface", $version
               test_spec.dependency "ProtonCore-CryptoGoImplementation/#{crypto_subspec(crypto)}", $version
               test_spec.dependency "ProtonCore-TestingToolkit/UnitTests/Observability", $version
               test_spec.source_files = 'libraries/HumanVerification/Tests/**/*'
           end
       end
    }

    make_all_go_variants(make_subspec, s)
    no_default_subspecs(s)
end
