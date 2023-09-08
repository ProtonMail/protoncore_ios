require_relative 'pods_configuration'

Pod::Spec.new do |s|

    s.name             = 'ProtonCore-KeyManager'
    s.module_name      = 'ProtonCoreKeyManager'
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

    s.dependency 'ProtonCore-DataModel', $version
    s.dependency "ProtonCore-CryptoGoInterface", $version
    s.dependency "ProtonCore-Crypto", $version
    s.source_files = "libraries/KeyManager/Sources/**/*.swift"

    this_pod_does_not_have_subspecs(s)

    make_unit_tests_subspec = ->(spec, crypto) {
        spec.test_spec "#{crypto_test_subspec(crypto)}" do |test_spec|
            test_spec.dependency 'ProtonCore-DataModel', $version
            test_spec.dependency "ProtonCore-CryptoGoImplementation/#{crypto_subspec(crypto)}", $version
            test_spec.source_files = 'libraries/KeyManager/Tests/**/*.swift'
            test_spec.resource = 'libraries/KeyManager/Tests/TestData/**/*'
        end
    }

    make_all_go_variants(make_unit_tests_subspec, s)

end
