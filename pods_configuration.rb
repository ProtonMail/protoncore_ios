$version = "3.20.0"

$git_url = ENV['PROTON_CORE_GIT_URL']

$homepage = 'https://github.com/ProtonMail'
$license = { :type => 'GPLv3', :file => 'LICENSE' }
$author = { 'zhj4478' => 'feng@pm.me' }
$source = { :git => $git_url, :tag => $version }

$ios_deployment_target = "11.0"
$macos_deployment_target = "10.13"

$swift_versions = ['5.6']

def crypto_module(symbol)
    case symbol
    when :crypto
        return "ProtonCore-Crypto"
    when :crypto_vpn
        return "ProtonCore-Crypto-VPN"
    else
        raise "Unknown symbol passed to crypto_module_name function"
    end
end

def crypto_subspec(symbol)
    case symbol
    when :crypto
        return "UsingCrypto"
    when :crypto_vpn
        return "UsingCryptoVPN"
    else
        raise "Unknown symbol passed to crypto_subspec function"
    end
end

def networking_module(symbol)
    case symbol
    when :alamofire
        return "Alamofire"
    when :afnetworking
        return "AFNetworking"
    else
        raise "Unknown symbol passed to networking_module function"
    end
end

def networking_module_version(symbol)
    case symbol
    when :alamofire
        return '5.4.4'
    when :afnetworking
        return '~> 4.0'
    else
        raise "Unknown symbol passed to networking_module function"
    end
end

def networking_subspec(symbol)
    case symbol
    when :alamofire
        return "Alamofire"
    when :afnetworking
        return "AFNetworking"
    else
        raise "Unknown symbol passed to networking_subspec function"
    end
end

def crypto_test_subspec(symbol)
    case symbol
    when :crypto
        return "TestsUsingCrypto"
    when :crypto_vpn
        return "TestsUsingCryptoVPN"
    else
        raise "Unknown symbol passed to crypto_subspec function"
    end
end

def crypto_and_networking_subspec(crypto_symbol, networking_symbol)
    return "#{crypto_subspec(crypto_symbol)}+#{networking_subspec(networking_symbol)}"
end

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
