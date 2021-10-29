require_relative 'pods_configuration'

Pod::Spec.new do |s|

    s.name             = 'ProtonCore-Features'
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
    # s.osx.deployment_target = $macos_deployment_target

    s.swift_versions = $swift_versions

    s.dependency 'ProtonCore-DataModel'
    s.dependency 'ProtonCore-SRP'

    s.default_subspecs = :none

    source_files = 'libraries/Features/Sources/*.swift'

    s.subspec 'UsingCrypto+Alamofire' do |crypto|
        crypto.dependency 'ProtonCore-Crypto', $version
        crypto.dependency 'ProtonCore-KeyManager/UsingCrypto', $version
        crypto.dependency 'ProtonCore-Authentication/UsingCrypto+Alamofire', $version
        crypto.dependency 'ProtonCore-Networking/Alamofire', $version
        crypto.dependency 'ProtonCore-Common/Alamofire', $version
        crypto.source_files = source_files
    end
  
    s.subspec 'UsingCryptoVPN+Alamofire' do |crypto_vpn|
        crypto_vpn.dependency 'ProtonCore-Crypto-VPN', $version
        crypto_vpn.dependency 'ProtonCore-KeyManager/UsingCryptoVPN', $version
        crypto_vpn.dependency 'ProtonCore-Authentication/UsingCryptoVPN+Alamofire', $version
        crypto_vpn.dependency 'ProtonCore-Networking/Alamofire', $version
        crypto_vpn.dependency 'ProtonCore-Common/Alamofire', $version
        crypto_vpn.source_files = source_files
    end

    s.subspec 'UsingCrypto+AFNetworking' do |crypto|
        crypto.dependency 'ProtonCore-Crypto', $version
        crypto.dependency 'ProtonCore-KeyManager/UsingCrypto', $version
        crypto.dependency 'ProtonCore-Authentication/UsingCrypto+AFNetworking', $version
        crypto.dependency 'ProtonCore-Networking/AFNetworking', $version
        crypto.dependency 'ProtonCore-Common/AFNetworking', $version
        crypto.source_files = source_files
    end
  
    s.subspec 'UsingCryptoVPN+AFNetworking' do |crypto_vpn|
        crypto_vpn.dependency 'ProtonCore-Crypto-VPN', $version
        crypto_vpn.dependency 'ProtonCore-KeyManager/UsingCryptoVPN', $version
        crypto_vpn.dependency 'ProtonCore-Authentication/UsingCryptoVPN+AFNetworking', $version
        crypto_vpn.dependency 'ProtonCore-Networking/AFNetworking', $version
        crypto_vpn.dependency 'ProtonCore-Common/AFNetworking', $version
        crypto_vpn.source_files = source_files
    end
end
