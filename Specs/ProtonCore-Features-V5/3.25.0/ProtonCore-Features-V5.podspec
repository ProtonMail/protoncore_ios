require_relative 'pods_configuration'

Pod::Spec.new do |s|

    s.name             = 'ProtonCore-Features-V5'
    s.module_name      = 'ProtonCore_Features'
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

    s.dependency 'ProtonCore-DataModel'
    s.dependency 'ProtonCore-Hash'

    make_subspec = ->(spec, crypto) {
        spec.subspec "#{crypto_subspec(crypto)}" do |subspec|
            subspec.dependency "#{crypto_module(crypto)}", $version
            subspec.dependency "ProtonCore-KeyManager/#{crypto_subspec(crypto)}", $version
            subspec.dependency "ProtonCore-Authentication/#{crypto_subspec(crypto)}", $version
            subspec.dependency "ProtonCore-Networking", $version
            subspec.dependency "ProtonCore-Common-V5", $version
            subspec.source_files = 'libraries/Features/Sources/*.swift'
        end
    }

    make_all_go_variants(make_subspec, s)

    no_default_subspecs(s)

end
