## 3.25.0 (2022-12-08)

###  (15 changes)

- [[CP-5027] Fix `externalAccountConversionEnabled` feature flag blocking the signing and signup](apple/shared/protoncore@e1509f5b5a51ee64330de0cdde063e6da108509f) ([merge request](apple/shared/protoncore!1027))
- [[CP-3593] - [iOS] [Cap B] Support domains selection in the external account...](apple/shared/protoncore@4d9183d3d7f88a2e55b2677f0d8b188ca34bd95e) ([merge request](apple/shared/protoncore!1020))
- [[CP-5026] added account conversion feature flag. unit tests.](apple/shared/protoncore@2e0bfe9f4ff451c4a71ca469a3a692e8e93439ca) ([merge request](apple/shared/protoncore!1022))
- [[CP-5025] Hide EA Cap B behind feature flag](apple/shared/protoncore@2045468b53d3d1f9649abbdee9d21758398315f8) ([merge request](apple/shared/protoncore!1019))
- [[CP-5042] Create address key causes "Signed key list did not match updated keys" error](apple/shared/protoncore@478a4e3b421e17327be87c8a26c77adf4e91725d) ([merge request](apple/shared/protoncore!1018))
- [MAILIOS-2973 Fix dynamic font size won't update in real time](apple/shared/protoncore@da17546fb289774be4215e51dce469c6c1d376dc) ([merge request](apple/shared/protoncore!1012))
- [[CP-4536] Control the complete screen wait time](apple/shared/protoncore@8a8bfeceb21b2ed33378c640ed19ce6bf44ffaa0) ([merge request](apple/shared/protoncore!1013))
- [[CP-4906] Add Drive's Telemetry config to Core](apple/shared/protoncore@02af4eff5feae9eb6435f03f18268adcb49339e3) ([merge request](apple/shared/protoncore!1001))
- [Add domain to "Create your Proton address" screen](apple/shared/protoncore@33ae81d9f7b0a091f2c9ecb0218678d94ac13df6) ([merge request](apple/shared/protoncore!1002))
- [Update golang vpn libs](apple/shared/protoncore@6e928aa1a88378f824a783ed61dca23ddd482379) ([merge request](apple/shared/protoncore!1008))
- [i18n: Upgrade translations from crowdin (3687e167).](apple/shared/protoncore@53c3dd34be86d2748c2fe122e9c82f79a8520505) ([merge request](apple/shared/protoncore!1006))
- [[CP-4976] - [iOS] [Cap B] Create view for "You’re in Luck!" screen](apple/shared/protoncore@09ffdf88c666522ed01ade83769b95ae72cb1b34) ([merge request](apple/shared/protoncore!1003))
- [[CP-4905] [CP-4906]: [iOS] Pass / Drive Settings allow users to switch telemetry on and off](apple/shared/protoncore@3d892ab6933e20e9e410e90ce95f43af0927b4e3) ([merge request](apple/shared/protoncore!998))
- [Fix: Crypto builds with 1.17.9 need to target iOS 11 as the minimum version](apple/shared/protoncore@6dd99b59c66e16a1bc881118ae843653ccefd787) ([merge request](apple/shared/protoncore!994))
- [Add async variant to some perform functions of APIService](apple/shared/protoncore@40626736d5e7525c6c8f961e1c46ec1e2e338b88) ([merge request](apple/shared/protoncore!975))

### other (4 changes)

- [i18n: Upgrade translations from crowdin (12db31fd).](apple/shared/protoncore@80b99e32e20182c76179427791838f6dc48f16dc) ([merge request](apple/shared/protoncore!1024))
- [i18n: Upgrade translations from crowdin (4ba7c569).](apple/shared/protoncore@5b0047d53196d63dd5968f8ed1ca28b5c580e91c) ([merge request](apple/shared/protoncore!1015))
- [Fix/pin fastlane simulator](apple/shared/protoncore@4ba7c569b3eaca8f49f9367bdd8657efc9e61e27) ([merge request](apple/shared/protoncore!987))
- [Add missing Crypto-patched-Go1.19.2 go libs variant](apple/shared/protoncore@28f1be19dfee50eb9e541c4b3a6df4f653fa1852) ([merge request](apple/shared/protoncore!990))

### added (4 changes)

- [[CP-5028] Login always overwrites the stored credentials](apple/shared/protoncore@e166b11d9299ff239881b4e6cb93a117bc57160d) ([merge request](apple/shared/protoncore!1023))
- [[CP-4536] Core internal feature flag for external accounts debug header](apple/shared/protoncore@e1ceb77f45f79feb552f58c5575325ce2aa77c3c) ([merge request](apple/shared/protoncore!1017))
- [Add ic-swipe-left](apple/shared/protoncore@5d66fd9e7c1dff9fb14d2438a2aa487efdd1663c) ([merge request](apple/shared/protoncore!1007))
- [update quark commands](apple/shared/protoncore@d0db066e025272e9a5a2a8b9e4099a6e172d4b67) ([merge request](apple/shared/protoncore!992))

### changed (3 changes)

- [[CP-4536] Enable the useKeymigrationPhaseV2 flag for the clients](apple/shared/protoncore@ba9df8da27984a6e10e8231ba969fe43ee894778) ([merge request](apple/shared/protoncore!1011))
- [Update golang vpn libs in crypto-vpn builds](apple/shared/protoncore@0ab05649540b852a7eea4fdc9eded5baf4a8129a) ([merge request](apple/shared/protoncore!1005))
- [MAILIOS-2957, Bigger font size than expectation](apple/shared/protoncore@474899ee8961505ac9595e2e58e11f8f71730343) ([merge request](apple/shared/protoncore!995))

### fixed (4 changes)

- [[CP-4988] Synchronize cookies if the Session-Id was obtained via alternative routing](apple/shared/protoncore@c68ad7d30a0f54b3a430be8dfe721e7e34ae5bf5) ([merge request](apple/shared/protoncore!1004))
- [[CP-4979] Error response decoding doesn't throw if "Details" key is in the response](apple/shared/protoncore@6f310d7e2fe8b06fd457a39925e5ea57e5d503d7) ([merge request](apple/shared/protoncore!999))
- [[DRVIOS-1562] Make keychain on macOS always work like on iOS](apple/shared/protoncore@ddf19f9aa335070dbf8165dc45c685d039ba5327) ([merge request](apple/shared/protoncore!996))
- [Uses the dedicated tests runner for running tests on CI](apple/shared/protoncore@d0c2175d9170672e00c1e0a22a506dbaf1d9c578) ([merge request](apple/shared/protoncore!988))

## 3.24.0 (2022-11-04)

### added (7 changes)

- [Add support for Drive2022 plan CP-4845](apple/shared/protoncore@bd7c8c62ade94a537b9953810e39696daae22577) ([merge request](apple/shared/protoncore!976))
- [[CP-4544] Present a popup when the external accounts are not supported according to the backend](apple/shared/protoncore@a50732b4c195046303e141cb705f719653a91c69) ([merge request](apple/shared/protoncore!939))
- [Crypto build, with go 1.19.2](apple/shared/protoncore@e5b88f848662066c90330085e71768e3c9c21b96) ([merge request](apple/shared/protoncore!980))
- [[CP-4533] key setup - external account no key with address](apple/shared/protoncore@435a13117275e518160baf99582d2f31dadd8c94) ([merge request](apple/shared/protoncore!933))
- [MAILIOS-2874: Add referral program into UserInfo](apple/shared/protoncore@e28dbafb03c8c87d860f2a2b936ee1ed3632e9f5) ([merge request](apple/shared/protoncore!935))
- [CP-4535 - [iOS] [Cap A] Allow the clients to easily check if the key is...](apple/shared/protoncore@92a972037e6166a218dcd2cecfbcaa0bc1fddc89) ([merge request](apple/shared/protoncore!958))
- [[CP-4543] [iOS] [Cap A] Ensure we can consume external keys when retrieving them during login](apple/shared/protoncore@2ab67119a80aec549b4724f16d9a4afdc5158e83) ([merge request](apple/shared/protoncore!942))

### fixed (4 changes)

- [[CP-4899] Fix wrong substitution format in a localized string](apple/shared/protoncore@0286eb8314cc6b44dfc598abc11fdea4773c0767) ([merge request](apple/shared/protoncore!982))
- [[CP-4853] Update the SKL flag for the external address key to be 15 instead of 7](apple/shared/protoncore@7a426464dff215a2c5d5f0da8c1c59d0eedf440b) ([merge request](apple/shared/protoncore!972))
- [Updates lottie-ios to 3.4.3, which is the latest version that we know works fine on Mail and VPN](apple/shared/protoncore@22834e20b2a3bdf8408a5ad1a889dcc7b19a6a0a) ([merge request](apple/shared/protoncore!967))
- [Regression UITests suite passing again](apple/shared/protoncore@35ae62c02241958c2f186501553096dcbb03c633) ([merge request](apple/shared/protoncore!952))

### removed (1 change)

- [[CP-3934] Remove unused deprecated code](apple/shared/protoncore@1ee75e3c4f0cedfbede1af11bebd1fff1f57f3b9) ([merge request](apple/shared/protoncore!962))

### changed (3 changes)

- [[DRVIOS-1512] Fix aspect fit of logo on Unlock screen](apple/shared/protoncore@bc6a58865b05665b2fde44c165cc3d57ab4c0380) ([merge request](apple/shared/protoncore!978))
- [[CP-4671] Changed go libs distribution to ease the support for many go libs variants](apple/shared/protoncore@ab04bf0c15867b02578c74c45ec0a95c1faa436c) ([merge request](apple/shared/protoncore!970))
- [Fixes the unnecessary dependency on ObfuscatedConstants in the production code](apple/shared/protoncore@04639fd44004655ab4851bbd23ca1a0ec64de958) ([merge request](apple/shared/protoncore!961))

### security (1 change)

- [[DRVIOS-1404] Make the `AFSession` configuration being ephemeral by default](apple/shared/protoncore@e9d58279dbe7fd9f988fe6aa9333ec1818124118) ([merge request](apple/shared/protoncore!969))

## 3.22.3 (2022-09-01)

### changed (1 change)

- [Return error from request method](apple/shared/protoncore@0f6682a4e623dcc6332d6ed97e9e6237442239b6) ([merge request](apple/shared/protoncore!887))

### added  (1 change)

- [MAILIOS-2659 Pixel tracker protection setting](apple/shared/protoncore@72b5a846b5dfb87d57eb1b82f42198ae663f4c15) ([merge request](apple/shared/protoncore!884))

### removed (1 change)

- [[CP-3933][CP-4039] AFNetworking and PromiseKit support removed](apple/shared/protoncore@55c5f8c84652c1d6877c80d0b35e4cdcba2ba128) ([merge request](apple/shared/protoncore!878))

## 3.22.1 (2022-08-31)

### removed (1 change)

- [[CP-3933][CP-4039] AFNetworking and PromiseKit support removed](apple/shared/protoncore@55c5f8c84652c1d6877c80d0b35e4cdcba2ba128) ([merge request](apple/shared/protoncore!878))

## 3.22.0 (2022-08-30)

### changed (2 changes)

- [CP-4490 Fix the error message not propagaed for Decodable-based responses](apple/shared/protoncore@267fe57b0c16e70efffda4fdb23459a91be66f4b) ([merge request](apple/shared/protoncore!875))
- [MAILIOS-2365 Refactor UserInfo to facilitate making further changes](apple/shared/protoncore@c22262548fb95bcf299cb1421ea12fdbca937b96) ([merge request](apple/shared/protoncore!872))

### added (2 changes)

- [CP-3032 Troubleshooting view will be triggered in login modules like sign up/sign in views.](apple/shared/protoncore@5a163551f927eb7307dd44ab99d0edbff99b6dce) ([merge request](apple/shared/protoncore!874))
- [MAILIOS-2771 Add telemetry and crashReports to UserInfo](apple/shared/protoncore@f620e4ecf445db22b3cfd7c3d3cc426aab2fd49b) ([merge request](apple/shared/protoncore!876))

### fixed (1 change)

- [CP-4491 Fix for Crypto VPN support](apple/shared/protoncore@63ecad4946e1bd86157007a798eb10fed5c9cba6) ([merge request](apple/shared/protoncore!879))
- [CP-4092 Improve handling of Invalid access token](apple/shared/protoncore@065e542a6f3af7c9263ec2926c3126d33e43390a) ([merge request](apple/shared/protoncore!873))


## 3.21.1 (2022-08-10)

No changes.
