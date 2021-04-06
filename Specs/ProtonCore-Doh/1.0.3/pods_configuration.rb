$version = "1.0.3"

$git_url = ENV['PROTON_CORE_GIT_URL']

$homepage = 'https://github.com/ProtonMail'
$license = { :type => 'GPLv3', :file => 'LICENSE' }
$author = { 'zhj4478' => 'feng@pm.me' }
$source = { :git => $git_url, :tag => $version }

$ios_deployment_target = "11.0"
$macos_deployment_target = "10.12.1"

$swift_versions = ['5.1']
