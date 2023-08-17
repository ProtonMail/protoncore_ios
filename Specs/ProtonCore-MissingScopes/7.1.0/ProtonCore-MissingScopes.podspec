require_relative 'pods_configuration'

Pod::Spec.new do |s|

    s.name             = 'ProtonCore-MissingScopes'
    s.version          = $version
    s.summary          = 'The MissingScopes pod contains the logic to handle missing scopes in network request'
    
    s.description      = <<-DESC
    The MissingScopes pod contains the logic to handle missing scopes such as `password`, `LOCKED`
    or others.
    DESC
    
    s.homepage         = $homepage
    s.license          = $license
    s.author           = $author
    s.source           = $source
    
    s.ios.deployment_target = $ios_deployment_target
    s.osx.deployment_target = $macos_deployment_target
    
    s.swift_versions = $swift_versions

    s.pod_target_xcconfig = { 'APPLICATION_EXTENSION_API_ONLY' => 'YES' }

    make_subspec = ->(spec, crypto) {
        spec.subspec "#{crypto_subspec(crypto)}" do |subspec|
            subspec.dependency "ProtonCore-APIClient", $version
            subspec.dependency "ProtonCore-Authentication/#{crypto_subspec(crypto)}", $version
            subspec.dependency "ProtonCore-Services", $version
            subspec.dependency "ProtonCore-UIFoundations", $version
            subspec.dependency "ProtonCore-CoreTranslation", $version
            subspec.source_files = 'libraries/MissingScopes/Sources/**/*.swift'
            
            subspec.test_spec "Tests" do |test_spec|
                test_spec.dependency "ProtonCore-TestingToolkit/UnitTests/Networking", $version
                test_spec.source_files = 'libraries/MissingScopes/Tests/**/*.swift'
            end
        end
    }

    make_all_go_variants(make_subspec, s)
    
    no_default_subspecs(s)
end
