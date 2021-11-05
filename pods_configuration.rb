$version = "3.3.0"

$git_url = ENV['PROTON_CORE_GIT_URL']

$homepage = 'https://github.com/ProtonMail'
$license = { :type => 'GPLv3', :file => 'LICENSE' }
$author = { 'zhj4478' => 'feng@pm.me' }
$source = { :git => $git_url, :tag => $version }

$ios_deployment_target = "11.0"
$macos_deployment_target = "10.13"

$swift_versions = ['5.4']


def no_default_subspecs(s)

# Creating the default podspec with an error or warning emitting file is the workaround for https://github.com/CocoaPods/CocoaPods/issues/10264

    s.default_subspecs = ['ErrorWarningEmittingDefaultSubspec']
    s.subspec 'ErrorWarningEmittingDefaultSubspec' do |empty|
        empty.source_files = "libraries/ErrorWarningEmittingDefaultSubspec/ErrorWarningEmittingDefaultSubspec.swift"
    end
end

def this_pod_does_not_have_subspecs(s)
    s.default_subspecs = []
end