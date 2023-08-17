require_relative 'pods_configuration'

Pod::Spec.new do |s|
    
    s.name             = 'ProtonCore-Crypto'
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
    s.dependency 'ProtonCore-CryptoGoInterface', $version

    make_subspec = ->(spec, crypto) {
        spec.subspec "#{crypto_subspec(crypto)}" do |subspec|
            subspec.source_files  = "libraries/Crypto/Sources/*.swift", "libraries/Crypto/Sources/**/*.swift"
            
            subspec.test_spec "Tests" do |crypto_tests|
                crypto_tests.dependency "ProtonCore-CryptoGoImplementation/#{crypto_subspec(crypto)}", $version
                crypto_tests.source_files = "libraries/Crypto/Tests/*.swift"
                crypto_tests.resource = "libraries/Crypto/Tests/Resources/**/*"
            end
        end
    }

    make_all_go_variants(make_subspec, s)

    no_default_subspecs(s)
end
