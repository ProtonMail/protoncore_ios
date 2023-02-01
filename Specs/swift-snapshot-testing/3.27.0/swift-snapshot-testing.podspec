Pod::Spec.new do |s|

    s.name             = 'swift-snapshot-testing'
    s.module_name      = 'SnapshotTesting'
    s.version          = '1.10.0'
    s.summary          = 'Tests that save and assert against reference data'
    
    s.description      = <<-DESC
    Automatically record app data into test assertions. Snapshot tests capture
    the entirety of a data structure and cover far more surface area than a
    typical unit test.
    DESC
    
    s.homepage         = "https://github.com/pointfreeco/swift-snapshot-testing"
    s.license          = "MIT"
    s.authors          = { "Stephen Celis" => "stephen@stephencelis.com", "Brandon Williams" => "mbw234@gmail.com" }
    s.social_media_url = "https://twitter.com/pointfreeco"
    s.source           = { :git => "https://github.com/pointfreeco/swift-snapshot-testing.git", :tag => s.version }
    
    s.ios.deployment_target = $ios_deployment_target
    s.osx.deployment_target = $macos_deployment_target
    
    s.swift_versions = $swift_versions

    s.frameworks = "XCTest"
    s.pod_target_xcconfig = { 'ENABLE_BITCODE' => 'NO' }

    s.source_files = "third-party/swift-snapshot-testing/Sources", "third-party/swift-snapshot-testing/Sources/**/*.swift"
end