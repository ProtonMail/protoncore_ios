$version = "3.23.0"

$git_url = ENV['PROTON_CORE_GIT_URL']

$homepage = 'https://github.com/ProtonMail'
$license = { :type => 'GPLv3', :file => 'LICENSE' }
$author = { 'zhj4478' => 'feng@pm.me' }
$source = { :git => $git_url, :tag => $version }

$ios_deployment_target = "11.0"
$macos_deployment_target = "10.13"

$swift_versions = ['5.6']

def all_go_variants
    [
        :crypto_go_1_15_15,
        :crypto_go_1_18_3,
        :crypto_vpn_go_1_15_15,
        :crypto_vpn_go_1_18_3,
        # :crypto_search_go_1_15_15,
        # :crypto_search_go_1_18_3,
    ]
end

def make_all_go_variants(make_subspec, spec)
    all_go_variants.map { |variant| 
        make_subspec.call(spec, variant) 
    }
end

def crypto_subspec(symbol)
    case symbol
    when :crypto_go_1_15_15 
        return "Crypto-Go1.15.15"
    when :crypto_go_1_18_3
        return "Crypto-Go1.18.3"
    when :crypto_vpn_go_1_15_15
        return "Crypto+VPN-Go1.15.15"
    when :crypto_vpn_go_1_18_3
        return "Crypto+VPN-Go1.18.3"
    when :crypto_search_go_1_15_15
        return "Crypto+Search-Go1.15.15"
    when :crypto_search_go_1_18_3
        return "Crypto+Search-Go1.18.3"
    else
        raise "Unknown symbol passed to crypto_subspec function"
    end
end

def crypto_xcframework(symbol)
    return "vendor/#{crypto_subspec(symbol)}/GoLibs.xcframework"
end

def crypto_module(symbol)
    return "ProtonCore-GoLibs/#{crypto_subspec(symbol)}"
end

def crypto_test_subspec(symbol)
    return "Tests-#{crypto_subspec(symbol)}"
end

def no_default_subspecs(s)

    # Creating the default podspec with an error or warning emitting file 
    # It's the workaround for https://github.com/CocoaPods/CocoaPods/issues/10264

    s.default_subspecs = ['ErrorWarningEmittingDefaultSubspec']
    s.subspec 'ErrorWarningEmittingDefaultSubspec' do |empty|
        empty.source_files = "libraries/ErrorWarningEmittingDefaultSubspec/ErrorWarningEmittingDefaultSubspec.swift"
    end
end

def this_pod_does_not_have_subspecs(s)
    s.default_subspecs = []
end
