$version = "11.0.0"

$git_url = ENV['PROTON_CORE_GIT_URL']

$homepage = 'https://github.com/ProtonMail'
$license = { :type => 'GPLv3', :file => 'LICENSE' }
$author = {
    'zhj4478' => 'feng@pm.me',
    'magohamote' => 'cedric.rolland@proton.ch',
    'siejkowski' => 'krzysztof.siejkowski@proton.ch',
    'vjalencas' => 'victor.jalencas@proton.ch' 
}
$source = { :git => $git_url, :tag => $version }

$ios_deployment_target = "14.0"
$macos_deployment_target = "11.0"

$swift_versions = ['5.6']

def all_go_variants
    [
        :crypto_go,
        :crypto_patched_go,
        :crypto_vpn_patched_go,
        :crypto_search_go
    ]
end

def single_go_variant_for_linting
    [
        :crypto_patched_go
    ]
end

def make_all_go_variants(make_subspec, spec)
    all_go_variants.map { |variant| 
        make_subspec.call(spec, variant) 
    }
end

def crypto_subspec(symbol)
    case symbol
    when :crypto_go
        return "Crypto-Go"
    when :crypto_patched_go
        return "Crypto-patched-Go"
    when :crypto_vpn_patched_go
        return "Crypto+VPN-patched-Go"
    when :crypto_search_go
        return "Crypto+Search-Go"
    else
        raise "Unknown symbol passed to crypto_subspec function"
    end
end

def crypto_xcframework(symbol)
    return "vendor/#{crypto_subspec(symbol)}/GoLibs.xcframework"
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

def add_dynamic_domain_to_info_plist(s)
    s.info_plist = { 'DYNAMIC_DOMAIN' => '$(DYNAMIC_DOMAIN)' }
end
