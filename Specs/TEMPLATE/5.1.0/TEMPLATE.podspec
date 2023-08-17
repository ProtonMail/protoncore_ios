require_relative 'pods_configuration'

Pod::Spec.new do |s|

    s.name             = 'ProtonCore-TEMPLATE_NAME'
    s.version          = $version
    s.summary          = 'ADD A RELEVANT SUMMARY'
    
    s.description      = <<-DESC
    ADD A RELEVANT DESCRIPTION
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

    s.source_files = 'libraries/TEMPLATE_NAME/Sources/**/*.swift'

    s.test_spec "Tests" do |test_spec|
        test_spec.source_files = "libraries/TEMPLATE_NAME/Tests/**/*.swift"
    end

end
