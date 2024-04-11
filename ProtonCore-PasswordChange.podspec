require_relative 'pods_configuration'

Pod::Spec.new do |s|

    s.name             = 'ProtonCore-PasswordChange'
    s.module_name      = 'ProtonCorePasswordChange'
    s.version          = $version
    s.summary          = 'ProtonCore-PasswordChange provide the UI for the user to change its password'

    s.description      = <<-DESC
    ProtonCore-PasswordChange provide the UI for the user to change its password.
    DESC
    
    s.homepage         = $homepage
    s.license          = $license
    s.author           = $author
    s.source           = $source
    
    s.ios.deployment_target = $ios_deployment_target
    s.osx.deployment_target = $macos_deployment_target
    
    s.swift_versions = $swift_versions

    s.pod_target_xcconfig = { 'APPLICATION_EXTENSION_API_ONLY' => 'NO' }



    s.dependency "ProtonCore-Authentication", $version
    s.dependency "ProtonCore-Authentication-KeyGeneration", $version
    s.dependency "ProtonCore-FeatureFlags", $version
    s.dependency "ProtonCore-Networking", $version
    s.dependency "ProtonCore-Observability", $version
    s.dependency "ProtonCore-Services", $version
    s.dependency "ProtonCore-UIFoundations", $version
    s.dependency "ProtonCore-Utilities", $version

    s.source_files = 'libraries/PasswordChange/Sources/**/*.swift'
    s.resource_bundles = {
       'Translations-PasswordChange' => ["libraries/PasswordChange/Resources/*"]
    }

    make_unit_test_subspec = ->(spec, crypto) {
        spec.test_spec "Unit#{crypto_test_subspec(crypto)}" do |test_spec|
            test_spec.dependency "ProtonCore-Crypto", $version
            test_spec.dependency "ProtonCore-CryptoGoInterface", $version
            test_spec.dependency "ProtonCore-CryptoGoImplementation/#{crypto_subspec(crypto)}", $version
            test_spec.dependency "ProtonCore-Authentication", $version
            test_spec.dependency "ProtonCore-Authentication-KeyGeneration", $version
            test_spec.dependency "ProtonCore-Networking", $version
            test_spec.dependency "ProtonCore-TestingToolkit/UnitTests/Core", $version
            test_spec.dependency "ProtonCore-TestingToolkit/TestData", $version
            test_spec.source_files = 'libraries/PasswordChange/Tests/**/*.swift'
        end
    }

    this_pod_does_not_have_subspecs(s)

end
