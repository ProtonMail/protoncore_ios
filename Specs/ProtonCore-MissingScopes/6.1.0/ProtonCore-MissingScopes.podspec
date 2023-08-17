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

    this_pod_does_not_have_subspecs(s)

    s.source_files = 'libraries/MissingScopes/Sources/**/*.swift'

    s.dependency "ProtonCore-APIClient", $version
    s.dependency "ProtonCore-Authentication", $version
    s.dependency "ProtonCore-Services", $version
    s.dependency "ProtonCore-UIFoundations", $version
    s.dependency "ProtonCore-Settings", $version
    s.dependency "ProtonCore-CoreTranslation", $version
    
    s.test_spec "Tests" do |test_spec|
        test_spec.dependency "ProtonCore-TestingToolkit/UnitTests/Networking", $version
        test_spec.source_files = 'libraries/MissingScopes/Tests/**/*.swift'
    end

end
