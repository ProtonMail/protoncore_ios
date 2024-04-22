require_relative 'pods_configuration'

Pod::Spec.new do |s|

    s.name             = 'ProtonCore-PasswordRequest'
    s.module_name      = 'ProtonCorePasswordRequest'
    s.version          = $version
    s.summary          = 'ProtonCore-PasswordRequest provide the UI to request user their password'
    
    s.description      = <<-DESC
    ProtonCore-PasswordRequest provide the UI to request
    user their password and acquire the unlock scope.
    DESC
    
    s.homepage         = $homepage
    s.license          = $license
    s.author           = $author
    s.source           = $source
    
    s.ios.deployment_target = $ios_deployment_target
    s.osx.deployment_target = $macos_deployment_target
    
    s.swift_versions = $swift_versions

    s.pod_target_xcconfig = { 'APPLICATION_EXTENSION_API_ONLY' => 'YES' }

    s.source_files = 'libraries/PasswordRequest/Sources/**/*.swift'

    s.resource_bundles = {
        'Translations-PasswordRequest' => ['libraries/PasswordRequest/Sources/Resources/*']
    }

    s.dependency "ProtonCore-Authentication", $version
    s.dependency "ProtonCore-Networking", $version
    s.dependency "ProtonCore-Services", $version
    s.dependency "ProtonCore-UIFoundations", $version

    s.test_spec "Tests" do |test_spec|
        test_spec.dependency "ProtonCore-TestingToolkit/UnitTests/Networking", $version
        test_spec.source_files = 'libraries/PasswordRequest/Tests/UnitTests/**/*.swift'
    end

    this_pod_does_not_have_subspecs(s)

end
