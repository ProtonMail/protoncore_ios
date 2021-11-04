require_relative 'pods_configuration'

Pod::Spec.new do |s|
    
    s.name             = 'ProtonCore-Log'
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

    s.default_subspecs = :none
    
    s.source_files  = "libraries/Log/Sources/*.swift", "libraries/Log/Sources/**/*.swift"
    
    s.test_spec 'Tests' do |log_tests|
        log_tests.source_files = 'libraries/Log/Tests/**/*'
    end

    awaitkit_script_phase = {
        :name => 'AwaitKit Xcode 13 update',
        :execution_position => :before_compile,
        :output_files => ['DispatchQueue+Await.swift'],
        :script => <<-AWAIT
            if [ "$XCODE_VERSION_MAJOR" = "1300" ]; then
                echo "Xcode 13 detected, changing the DispatchQueue+Await.swift file"
                pwd
                find . -name "DispatchQueue+Await.swift"
                find . -name "DispatchQueue+Await.swift" -exec sed -i '' "s/return try await(promise)/return try \\`await\\`(promise)/g" {} \\;
            else
                echo "Xcode 13 not detected, leaving the DispatchQueue+Await.swift file be"
            fi
            AWAIT
    }

    s.script_phase = awaitkit_script_phase

    s.pod_target_xcconfig = { 'APPLICATION_EXTENSION_API_ONLY' => 'YES' }

end
