## 19.0.0 (2024-02-01)

### changed (1 change)

- [CP-5969 Refactor AccountRecovery to smooth integration work](apple/shared/protoncore@c0447fa1759bbbd22e51703270321cf833d5e597) ([merge request](apple/shared/protoncore!1627))

## 18.0.0 (2024-01-25)

### fix (1 change)

- [fix: Bump Sentry version to 8.18.0](apple/shared/protoncore@6c0d1b1814040937ccc8bd5241e4bb33117c9435) ([merge request](apple/shared/protoncore!1634))

### fixed (1 change)

- [[CP-7201] fix: Remove hard-coded cycle in purchase request, made it parameterizable](apple/shared/protoncore@0c10572c061d43dd6baedcd2b19e855fa4319445) ([merge request](apple/shared/protoncore!1632))
- [feat(dynamicPlans): Dynamic cycle in Validate subscription request](apple/shared/protoncore@749cb65d022e754b3143071f1ea9d4aad35a8d19) ([merge request](apple/shared/protoncore!1631))

## 17.0.0 (2024-01-24)

### added (7 changes)

- [[CP-7216] feat(sentry): Send Sentry event when PMLog.error is called](apple/shared/protoncore@d090cfe2771735fd8065ed3b0cc176222bfe680d) ([merge request](apple/shared/protoncore!1624))
- [[CALIOS-2598] Add week view and 3 days view icons to the ProtonIconSet](apple/shared/protoncore@ac03dc9ab8d5f651187b802259f298a50e3624e4) ([merge request](apple/shared/protoncore!1615))
- [[CP-7169] Report Observability event when making queries to app store for dynamic plans](apple/shared/protoncore@458035139428382f0ff8f16c21a3f864a5486bb3) ([merge request](apple/shared/protoncore!1613))
- [[CP-7168] Send static or dynamic version of payment events](apple/shared/protoncore@3c13ef62ff56f9ef1df36b4f2427899a1427ddbe) ([merge request](apple/shared/protoncore!1612))
- [Add SSO callback scheme to LoginService.  Pass as parameter for macOS SSO requests.](apple/shared/protoncore@b9b856c29347b77926652aacf407ac11f5c64455) ([merge request](apple/shared/protoncore!1609))
- [[CP-6518] New design for Grace period view](apple/shared/protoncore@a770eae1cc9086bee1827740644ba1a87dc3e99d) ([merge request](apple/shared/protoncore!1596))
- [[CP-7046] Make Account Recovery settings item dynamic and according with newest designs](apple/shared/protoncore@41c6a7a27658c4fcec07c26fe2228c82de986ef7) ([merge request](apple/shared/protoncore!1591))

### changed (11 changes)

- [[CP-7016] Podify AccountRecovery](apple/shared/protoncore@9bc6f93cb048e221fc12cf4b223b1c6b0c8e3026) ([merge request](apple/shared/protoncore!1623))
- [[L10N-2671] Improve comments for translators](apple/shared/protoncore@5074644398518ece0eb9a0edbc7c6b41f95e00b5) ([merge request](apple/shared/protoncore!1610))
- [[CP-7049] Update insecure state view](apple/shared/protoncore@077d33c5d8b5feccbf34b51490c1ba9fc35dc8bd) ([merge request](apple/shared/protoncore!1598))
- [[CP-7048] Update design for Cancelled state of account recovery](apple/shared/protoncore@0945f85871e13fb0bde198d98679446fb9806813) ([merge request](apple/shared/protoncore!1600))
- [[CP-7001] Migrate Account Recovery from FeatureSwitch to FeatureFlags](apple/shared/protoncore@a87f1de4a8e00d193c79c93c900872fb709a3a97) ([merge request](apple/shared/protoncore!1574))
- [feat(AccountRecovery): Update password request screen](apple/shared/protoncore@c6518e09aeeca48d8a1d0f2adc63e49be3eeab6a) ([merge request](apple/shared/protoncore!1616))
- [Remove token from log](apple/shared/protoncore@44e6e76fb5066ed7cac2b0b8590815e79d364d5d) ([merge request](apple/shared/protoncore!1597))
- [TPE-481 - Update quark commands](apple/shared/protoncore@a34cf0cbccd2cdada35cb1d3eb15d31454593a28) ([merge request](apple/shared/protoncore!1584))
- [[CP-6749]: Auto switch to sso login upon detection of sso login attempt](apple/shared/protoncore@024f80ceafcf54072d106ce19f0a8fc5c4e8ae2c) ([merge request](apple/shared/protoncore!1595))
- [[CP-6387] Expose default initializer on DefaultRemoteDatasource.](apple/shared/protoncore@34fdae0011bf9d8dd2d9f90b43b21c3d31e0e4eb) ([merge request](apple/shared/protoncore!1588))
- [[16.0.0] Releasing core version 16.0.0](apple/shared/protoncore@b5d503616b5f4522d77a3bcb4d8095cf89913aa7) ([merge request](apple/shared/protoncore!1561))

### fixed (4 changes)

- [Run UI related code in main queue](apple/shared/protoncore@f009e3ed8aa0da8814e6ee2e61813ae0b667c030) ([merge request](apple/shared/protoncore!1608))
- [[CP-7016] use SPM provided way to refer to current module's resource bundle](apple/shared/protoncore@94753520ade0f5752148675ef24fed285706c3f0) ([merge request](apple/shared/protoncore!1576))
- [Fix (account recovery): Fix account recovery status screen CP-7002](apple/shared/protoncore@efa6767c976ab0ac3e5416ff81ce219501296f12) ([merge request](apple/shared/protoncore!1575))
- [fix (payments tests): Fix a couple of auto-renewing purchase cases and update...](apple/shared/protoncore@96a8e47fcfb049e5bb50cc1232376d6d23fe7909) ([merge request](apple/shared/protoncore!1563))

## 16.0.0 (2023-12-01)

### added (9 changes)

- [feat(dynamicPlans): Persist userId in user defaults](apple/shared/protoncore@7ed6cdef2a1190c785f191e9676783e3eb647b0c) ([merge request](apple/shared/protoncore!1559))
- [feat(dynamicPlans)!: Merge single and multi-users functions](apple/shared/protoncore@7fd85ce17e2d3c6d17a76947a1e850d019b04425) ([merge request](apple/shared/protoncore!1558))
- [feat(dynamicPlans): manage static and dynamic value for flag](apple/shared/protoncore@39d912ffc2b24be8c9b08537704e171cdcbee4de) ([merge request](apple/shared/protoncore!1556))
- [[CP-6916] Simplify function to configure main view of PlanCell between static and dynamic plans.](apple/shared/protoncore@b9b5986132471840462744e876d3fe10f234385a) ([merge request](apple/shared/protoncore!1557))
- [feature(dynamicPlans): Add dependency injection for FF singleton](apple/shared/protoncore@a2f4c09e6df86be7d088d5b11982fcee9c0fe73a) ([merge request](apple/shared/protoncore!1555))
- [feature(dynamicPlans): Fix footer copy for dynamic plans](apple/shared/protoncore@8c57542e22b3e12eea4b74e24e1809f3d321824f) ([merge request](apple/shared/protoncore!1544))
- [refactor: Allow the credentials dependent functions to be async.](apple/shared/protoncore@2a6609158869c663a1d742b2b59877f07f117641) ([merge request](apple/shared/protoncore!1553))
- [test (payments): ensure current plan snapshots show expiration message CP-6912](apple/shared/protoncore@51213d890803e957d1ceb723a2cbb7c4fd0b3279) ([merge request](apple/shared/protoncore!1552))
- [Feature: Add snapshot tests for Dynamic plans CP-6481](apple/shared/protoncore@46f0552c85635569dd2d26f8869e8c9d33d9c285) ([merge request](apple/shared/protoncore!1543))

### fixed (4 changes)

- [Fix (payments): Ensure Token Requests have the correct Type and use the correct FF CP-6948](apple/shared/protoncore@739fa77b6133fa7b75f42643392119e32bd68155) ([merge request](apple/shared/protoncore!1554))
- [Fix (payments): Make check to avoid observer removals and redundant observer additions](apple/shared/protoncore@3b7c3b24abee09824c11a44ad110c31544156c38) ([merge request](apple/shared/protoncore!1551))
- [fix (payments): Avoid re-triggering a queue process with existing process in flight CP-6913](apple/shared/protoncore@015f64c9f97d3c5ddabb3383f5800035c149bef9) ([merge request](apple/shared/protoncore!1549))
- [[CP-6856] Re-enable disabled test](apple/shared/protoncore@b3dab56913bd9c80c70c7e688949d4b71fbfd3ce) ([merge request](apple/shared/protoncore!1541))

## 15.0.0 (2023-11-16)

### changed (14 changes)

- [feature (subscriptions): Prevent IAP when account has credits CP-6370](apple/shared/protoncore@c49df16fe1ff0ef99ad5dbcfb829bb77e5793233) ([merge request](apple/shared/protoncore!1506))
- [feature(dynamicPlans): remove swiftlint package](apple/shared/protoncore@7d658f496888acddc52662b4ae5132d893508cd2) ([merge request](apple/shared/protoncore!1519))
- [fix(unleash): Fix a bug in cleaning the flags](apple/shared/protoncore@a4683aaaaa2a565f733f822ab8227b7a39c98826) ([merge request](apple/shared/protoncore!1516))
- [feature(dynamicPlans): Remove swiftlint from package](apple/shared/protoncore@577dfaa39c8e619e8016b20c0f377fd0eb3b9bec) ([merge request](apple/shared/protoncore!1515))
- [feature(dynamicPlans): feature flags fetched in core](apple/shared/protoncore@f51d856dc273a72cbaeb04d72125a75d3d96160d) ([merge request](apple/shared/protoncore!1514))
- [feature(dynamicPlans): return login data](apple/shared/protoncore@addba067ff986af323f857eab124a1fbb1d00803) ([merge request](apple/shared/protoncore!1512))
- [feature(unleash): Persist user feature flags](apple/shared/protoncore@cda9a80b44590a4fe2b4fc9e5956799127690879) ([merge request](apple/shared/protoncore!1507))
- [feature(dynamicPlans): update unleash library](apple/shared/protoncore@aafbd4f7a887bbb3abd5aa675f21ab5a9b931875) ([merge request](apple/shared/protoncore!1505))
- [feature(dynamicPlans): Update podfile](apple/shared/protoncore@83a1dc5cdeabe25734ebdf86a6a09450a3490f00) ([merge request](apple/shared/protoncore!1501))
- [feature(unleash): Update library](apple/shared/protoncore@599e93979b53456a078cc7f26516fb1afc08296e) ([merge request](apple/shared/protoncore!1499))
- [bugfix(dynamicPlans): Fixes a crash](apple/shared/protoncore@99f04085cc1cb499deabf7604223e7f313daca25) ([merge request](apple/shared/protoncore!1498))
- [feature(dynamicPlans): update crypto library](apple/shared/protoncore@0b93fd88beb311d3f5b17f43b5544c3ff0436d2d) ([merge request](apple/shared/protoncore!1487))
- [i18n: Upgrade translations from crowdin (e017a58a).](apple/shared/protoncore@c5684594c6864e0e10aef00cab2142ceceb507a5) ([merge request](apple/shared/protoncore!1483))
- [feature(dynamicPlans): Hide amount for apple price](apple/shared/protoncore@4ed824de41c489be42031bcf9c854c7c9971b993) ([merge request](apple/shared/protoncore!1478))

### added (1 change)

- [Update the VCard library to support the anniversary field in contact](apple/shared/protoncore@99bf8cf986b699eeb5fc743a06091c561885a249) ([merge request](apple/shared/protoncore!1500))

### fixed (3 change)

- [fix (subscriptions): Allow arbitrary product IDs CP-6790](apple/shared/protoncore@6da2aed2ed56108c908be5c0388bc48f5a7bc959) ([merge request](apple/shared/protoncore!1517))
- [fix (subscriptions): Allow arbitrary product IDs CP-6790](apple/shared/protoncore@a1940ffe0402792a4ba28bf3e4dfc9e3df4bf02e) ([merge request](apple/shared/protoncore!1517))
- [fix (crypto): Update gopenpgp to v2.7.4](apple/shared/protoncore@4ba5adf491cac994b831e8d6e368882a56f96014) ([merge request](apple/shared/protoncore!1495))

## 14.0.0 (2023-10-18)

###  (1 change)

- [feature(dynamicPlans): update crypto libraries](apple/shared/protoncore@4cbb02510448804d1cc381837d0e97f0cf2cbc78) ([merge request](apple/shared/protoncore!1473))

### Changed (1 change)

- [refactor: Remove Reusable duplicate, expose methods for reuse](apple/shared/protoncore@a90a43c18b2480b97a971336c263323b4d8ad790) ([merge request](apple/shared/protoncore!1454))

## 12.0.0 (2023-09-29)

###  (1 change)

- [feat (dynamic plans): Add badge decoration](apple/shared/protoncore@b5fe0cb96a16cdb502b85dbad63efffc367ffad1) ([merge request](apple/shared/protoncore!1436))

## 11.0.0 (2023-09-05)

###  (7 changes)

- [feature(dynamic plans): Add UI](apple/shared/protoncore@74dc61faa871463f0dd343f05e798626416b90c8) ([merge request](apple/shared/protoncore!1409))
- [feature(dynamic plans): fetch icons](apple/shared/protoncore@b9072b69013c3b2c5e2f049541ad1403067e0e7b) ([merge request](apple/shared/protoncore!1405))
- [feature(dynamic plans): Update coordinator](apple/shared/protoncore@a799b42f0615157e1a4070057d8b804262c76e22) ([merge request](apple/shared/protoncore!1402))
- [feature(dynamic plans): update model and presentation](apple/shared/protoncore@d5b5186d117df4c6fcee406859999d53a61fbe35) ([merge request](apple/shared/protoncore!1399))
- [feature(dynamic plans): Move price formatter](apple/shared/protoncore@25fb4b35b8f016b117cdd657ac546117ed0a2cc6) ([merge request](apple/shared/protoncore!1398))
- [feature(dynamic plans): remove vendor's name](apple/shared/protoncore@05a862f9e0ee04235ea0d071da1a82807d1fee54) ([merge request](apple/shared/protoncore!1394))
- [feature(dynamic plans): update PaymentUI viewmodel](apple/shared/protoncore@694c74f6c6f73e19561f95d154c7fa05886099fc) ([merge request](apple/shared/protoncore!1391))

## 10.0.0 (2023-08-09)

###  (8 changes)

- [Update gopenpgp to v2.7.2 and vpn libs to latest (go 1.20.6)](apple/shared/protoncore@b86e86873cbffce2a76f5ab0b88083c03ae54ba3) ([merge request](apple/shared/protoncore!1366))
- [feature(dynamicPlans): add PlansDataSource](apple/shared/protoncore@4ebbdc40d2ebe4c0b81c4b994f2959aa5ad7bb7c) ([merge request](apple/shared/protoncore!1362))
- [feature(passwordRequest): Removing unnecessary protocol](apple/shared/protoncore@10747d9f4415a851294223b318736e8e0ba5b963) ([merge request](apple/shared/protoncore!1354))
- [feature(dynamicPlans): Add CurrentPlan](apple/shared/protoncore@0d9fcdd45ff1cd7990548d385726d501fd15ec8a) ([merge request](apple/shared/protoncore!1351))
- [bug:(sso) remove showButton logic](apple/shared/protoncore@c8e310bbee21167343d4c40059e866a1e85d6587) ([merge request](apple/shared/protoncore!1349))
- [feature(dymanicPlans): Add AvailablePlans request](apple/shared/protoncore@0cf5e09a2a1f59840030b1ea5b98d307c2501427) ([merge request](apple/shared/protoncore!1348))
- [feature(passwordRequest): add lock function](apple/shared/protoncore@10525e31d0f00c5f5f5b8c30beef24cd0ec8a5d0) ([merge request](apple/shared/protoncore!1344))
- [feature(passwordRequest): inject endpoint](apple/shared/protoncore@07517b07b426d4c040dc5be5dff503c4bddccc73) ([merge request](apple/shared/protoncore!1343))

## 9.4.0 (2023-07-10)

### added (1 change)

- [feature(spm): AccountDeletion, Common, Features, ForceUpgrade,...](apple/shared/protoncore@9082dc5216b0e4f84b012cc2d0c34d6445b6b121) ([merge request](apple/shared/protoncore!1310))

## 9.3.0 (2023-07-05)

### added (1 change)

- [[CP-5890] Add sso metrics](apple/shared/protoncore@3f8b7d71c5e68edb8c27905e5945755f7b795bc9) ([merge request](apple/shared/protoncore!1291))

###  (1 change)

- [[CP-6094] Move missing scopes title in view](apple/shared/protoncore@fbbb4f68e5bda375a96291723260c1dfcd6e32ac) ([merge request](apple/shared/protoncore!1307))

## 9.2.0 (2023-06-28)

No changes.

## 9.1.0 (2023-06-23)

###  (3 changes)

- [feat: [CP-5889] handle webView Response](apple/shared/protoncore@133b215ea9e3b504ed9a7ea953c211449e5a0250) ([merge request](apple/shared/protoncore!1288))
- [feat: [CP-5888] move webview into VC](apple/shared/protoncore@333466a24d63f5cb077fcc130618340479f786f3) ([merge request](apple/shared/protoncore!1283))
- [feat: [CP-5888] get token and UID from sso](apple/shared/protoncore@af0ab2b446fc851f059df0959c4b6e956f9c7eae) ([merge request](apple/shared/protoncore!1281))

## 9.0.0 (2023-06-14)

No changes.

## 8.0.2 (2023-06-13)

###  (5 changes)

- [fix: [CP-5652] call auth/info again on wrong password](apple/shared/protoncore@f4f343dec57b787a1ccf6e8da54c6db8c0a2e910) ([merge request](apple/shared/protoncore!1272))
- [feat: [CP-5887] Add ssoChallenge enum](apple/shared/protoncore@14fe206a1a7ce9d39baef1d5f4103e1533afd148) ([merge request](apple/shared/protoncore!1270))
- [fix(theming): Apply theme to missed navigation view controller in Payments](apple/shared/protoncore@0350c05d0140d0c81c3186475d3d0726fe0b5466) ([merge request](apple/shared/protoncore!1271))
- [[8.0.1] Releasing core version 8.0.1](apple/shared/protoncore@b5d3bb89abc7406d0f09b8255adb78bdeaa74fae) ([merge request](apple/shared/protoncore!1269))
- [feat: [CP-5887] Update SSOResponse name](apple/shared/protoncore@406bdeff0ac41bdd3e43d5f0d733fc6a347ddd0a) ([merge request](apple/shared/protoncore!1268))

## 8.0.1 (2023-06-09)

###  (1 change)

- [fix: [CP-5652] Not showing ask password twice](apple/shared/protoncore@582f4c160f7d1f34774a2338dab2a56eb2dfce47) ([merge request](apple/shared/protoncore!1267))

## 8.0.0 (2023-06-08)

### added (1 change)

- [feature(ui): Support overwriting of system theme in Login, Payments and HV](apple/shared/protoncore@908ad7446cd7bef02e7aee5ca68fa006580fe3a7) ([merge request](apple/shared/protoncore!1264))

### removed (1 change)

- [refactor (dead code): Remove ProtonCore-Common, Part the second CP-5495](apple/shared/protoncore@fa1f9bdf891da2cfd4555f7a70ee56c3b4d2b98b) ([merge request](apple/shared/protoncore!1247))

###  (2 changes)

- [fix: [CP-5652] Update topViewController](apple/shared/protoncore@a49f694100a5bd19d9e429ae092c90e1d509da06) ([merge request](apple/shared/protoncore!1265))
- [feat: [CP-5886] Update auth and info endpoint](apple/shared/protoncore@ac0a2f3d970247de5b61c344388975da8a35f55d) ([merge request](apple/shared/protoncore!1255))

## 7.1.0 (2023-06-06)

### changed (1 change)

- [feature(plans): Pass promo purchasability](apple/shared/protoncore@6ef47304c3ef86355cf153287ef51f70a13c22b1) ([merge request](apple/shared/protoncore!1258))

## 7.0.2 (2023-06-05)

###  (1 change)

- [[7.0.1] Releasing core version 7.0.1](apple/shared/protoncore@e0ae23d2d51186a962345e4365a4581253f7ea0b) ([merge request](apple/shared/protoncore!1260))

## 7.0.1 (2023-06-05)

###  (1 change)

- [feat: [CP-5652] update missing scopes podspec](apple/shared/protoncore@6445c7aa379020b7f31c7eb8444df9f3efb3e13b) ([merge request](apple/shared/protoncore!1257))

### fixed (1 change)

- [fix (copy): Remove New_Plans prefix and remove personal from calendars description CP-5975](apple/shared/protoncore@088f39e068f4f49be19fcfa82979b4360cd5f711) ([merge request](apple/shared/protoncore!1256))

## 7.0.0 (2023-06-01)

###  (7 changes)

- [fix: BREAKING CHANGE: [CP-5652] Fix missing scopes](apple/shared/protoncore@69ef3f2a350452b01c81fa1af90b46de0531e912) ([merge request](apple/shared/protoncore!1251))
- [Added DocC in keymaker for experimental](apple/shared/protoncore@657418a28b80c534e5a1f78ca5e1f39ad5044ddc) ([merge request](apple/shared/protoncore!1120))
- [feature(spm): FeatureSwitch, Foundations and CoreTranslation modules expressed in SPM](apple/shared/protoncore@2720151d91b2330fbc8bc9a665be41f9dbdf53e2) ([merge request](apple/shared/protoncore!1250))
- [MAILIOS-3422, Fix keyboard disappear issue in 2FA page](apple/shared/protoncore@02f1d53f3f853140fc21410fd7f3a4b949456173) ([merge request](apple/shared/protoncore!1212))
- [[CP-5876] Update view on sso tap](apple/shared/protoncore@a2fe8ae0b49e015a0f2f82201101d0e1a92aac9f) ([merge request](apple/shared/protoncore!1252))
- [feat: [CP-5874] Add signin with sso button](apple/shared/protoncore@4614ad71ec243db5fd400381e217505478944a1d) ([merge request](apple/shared/protoncore!1239))
- [[CP-5855] Update PaymentToken parameter](apple/shared/protoncore@3f4a507fece0dd691ea1486ebc310fcad161aadf) ([merge request](apple/shared/protoncore!1237))

### fixed (2 changes)

- [Fix memory leak in pinningValidatorCallback](apple/shared/protoncore@76c5675c6afb940a001ab1d0ca7785c68f5ea604) ([merge request](apple/shared/protoncore!1243))
- [fix(error_message): Conform AvailabilityError to LocalizedError to properly show the user message](apple/shared/protoncore@16a37eb0121294c6f45d98f1b63420f9dc595b57) ([merge request](apple/shared/protoncore!1238))

### added (2 changes)

- [Make KeyRingBuilder public](apple/shared/protoncore@0774f7a13fc785f201f04bff65dfd3abaa9ebeda) ([merge request](apple/shared/protoncore!1244))
- [feature(pass): Pass promo plan presentation](apple/shared/protoncore@50ec53236447d34645d72ffde2feaaf6b6c5870a) ([merge request](apple/shared/protoncore!1245))

### other (1 change)

- [i18n: Upgrade translations from crowdin (16a37eb0).](apple/shared/protoncore@6e26e104a8789fc360ad0fd39dc78772f77ed864) ([merge request](apple/shared/protoncore!1248))

### changed (1 change)

- [feature(spm): Crypto modules expressed via SPM](apple/shared/protoncore@c8fcc6149e7e27f0c3603947e73dbe6dceb2c632) ([merge request](apple/shared/protoncore!1228))

## 6.1.0 (2023-05-24)

### fixed (5 changes)

- [fix post call retry carry wrong parameters](apple/shared/protoncore@8518aef7a8485e016bfecb6397a76c32ad6d8b6e) ([merge request](apple/shared/protoncore!1233))
- [fix(error_handling): Conform SessionResponseError to LocalizedError plus expose the http code](apple/shared/protoncore@0877753f3eb6be71225ec2470ee9838e0f72fabe) ([merge request](apple/shared/protoncore!1204))
- [CLIENT-5289, Fix wrong logic when click action sheet item](apple/shared/protoncore@7ef2fe2b83c8f8af3bd6e0dc310c2e54e85ffb83) ([merge request](apple/shared/protoncore!1209))
- [i18n: Upgrade translations from crowdin (e10653b8).](apple/shared/protoncore@301838007d244decca31b04235d1bc42cbca95ee) ([merge request](apple/shared/protoncore!1210))
- [i18n: Upgrade translations from crowdin (7c2d219f).](apple/shared/protoncore@482080a8af9c70378838bdb415b02a8331f25420) ([merge request](apple/shared/protoncore!1207))

###  (7 changes)

- [feat: [CP-5696] Handle missing scopes](apple/shared/protoncore@706df2982540274f0e95925e54871250f0577610) ([merge request](apple/shared/protoncore!1231))
- [feat: [CP-5696] Add coordinator](apple/shared/protoncore@d31bd9992440bc6fb3282a2724727d51a8e7239b) ([merge request](apple/shared/protoncore!1224))
- [ci: Run code coverage reports on schedule](apple/shared/protoncore@dde8b70f9956390050b88e88e71a893a01c859ef) ([merge request](apple/shared/protoncore!1221))
- [[CP-5696] Add missing scopes handling view](apple/shared/protoncore@68d176f0c80a90a061d3104803f628425711bcc9) ([merge request](apple/shared/protoncore!1223))
- [feat: [CP-5696] Add MissingScopes viewModel](apple/shared/protoncore@442255ec0c64d357ba80d7d5b8370be7adfe14fd) ([merge request](apple/shared/protoncore!1219))
- [feat: [CP-5696] Extract SRP Builder](apple/shared/protoncore@076bb32e2426d7e15bbdaff51cf118cacc753ec1) ([merge request](apple/shared/protoncore!1213))
- [Add signature context to new signed key lists.](apple/shared/protoncore@0f0f44d21afd7e5e41aa18223a1b8f863f3d20f5) ([merge request](apple/shared/protoncore!1199))

### other (10 changes)

- [ci: Avoid having manual jobs on post-merge requests CP-4455](apple/shared/protoncore@6f384c3cd1b098a6c7afac630737cc7fca53a1e9) ([merge request](apple/shared/protoncore!1229))
- [i18n: Upgrade translations from crowdin (3bb6b42c).](apple/shared/protoncore@26e3f64720f80151a8a2a1ca3c14a7cdade84eca) ([merge request](apple/shared/protoncore!1230))
- [ci: Make test jobs run when branch is develop CP-4455](apple/shared/protoncore@3bb6b42cb3f24188e56fc0337d008992e97d1f0d) ([merge request](apple/shared/protoncore!1227))
- [ci: debug post-merge environment CP-4455](apple/shared/protoncore@e213e3499ee82f5304babf66d23218f1c0b1e4f1) ([merge request](apple/shared/protoncore!1226))
- [ci(template): Add MR description template](apple/shared/protoncore@627aaa7f920c404694c206633e32438dd9a37a9b) ([merge request](apple/shared/protoncore!1010))
- [i18n: Upgrade translations from crowdin (043bd5a9).](apple/shared/protoncore@43da7b51666460cab0f9d0604c474b23e68f4242) ([merge request](apple/shared/protoncore!1222))
- [feature(uifoundations): Updated icons assets](apple/shared/protoncore@6c88d4617fc66b1ae52a32679a38f25075099a09) ([merge request](apple/shared/protoncore!1217))
- [build: Update fastlane, CI and bump minimum iOS version CP-5809](apple/shared/protoncore@cf00ddf4b815257fab47f2b6b2b4918496722ae8) ([merge request](apple/shared/protoncore!1214))
- [ci: Implement code coverage badges CP-4455](apple/shared/protoncore@24515e8f5e7e7eae61f83fe3d1b47bd70c7e37d3) ([merge request](apple/shared/protoncore!1211))
- [ci: Changes to run tests on Xcode 14.3](apple/shared/protoncore@40eb74d7f89ad96f451c6c758d7476e81000b470) ([merge request](apple/shared/protoncore!1215))

### added (2 changes)

- [feature(spm): Package definitions for Log, Utilities, GoLibs frameworks (not...](apple/shared/protoncore@2d47ef51977e9fc657b89c5cd29b8b882f709e7b) ([merge request](apple/shared/protoncore!1225))
- [feature(payments): Pass-specific plan details](apple/shared/protoncore@c41e5362cc44d9b8d23129a47f28783e6f23e500) ([merge request](apple/shared/protoncore!1216))

### changed (1 change)

- [ci: Add code coverage badges and thresholds CP-4455](apple/shared/protoncore@e10653b87eadb61646b909b2d0a56dbdf0a3dfff) ([merge request](apple/shared/protoncore!1205))

## 6.0.0 (2023-05-02)

### changed (1 change)

- [Make startCountdown, releaseCountdown & shouldAutolockNow functions of Autolocker public](apple/shared/protoncore@dfe3162df2f9e17bac1688c0c5390cbb39bb7e6d) ([merge request](apple/shared/protoncore!1206))

###  (12 changes)

- [[CP-5696] add missing scopes getAuthInfo](apple/shared/protoncore@7c2d219f8b0c7778fb1dc56662e9e4c7cb24bc2c) ([merge request](apple/shared/protoncore!1203))
- [MAILIOS-3414, Question mark instead of initial in the account switcher](apple/shared/protoncore@8b306c399493f0025af57ad833bb6b54a64e09ac) ([merge request](apple/shared/protoncore!1202))
- [Crypto: Add optional signature context to signature generation and verification.](apple/shared/protoncore@71c0bc24f8399df0f70ef4b5c7bf77cbf5b59a1e) ([merge request](apple/shared/protoncore!1196))
- [[CP-5696] Code improvements](apple/shared/protoncore@15688cfd7dd9fb1e486c0ab4b065d79496f76c74) ([merge request](apple/shared/protoncore!1200))
- [Fix account switcher render issue](apple/shared/protoncore@8080203c201a1ddd526fcd1625b03e9ba268d1f0) ([merge request](apple/shared/protoncore!1192))
- [Update go libs to gopenpgp v2.7.1-proton](apple/shared/protoncore@f1fd4e17f08eea6b4e37437c82cfc0127a294818) ([merge request](apple/shared/protoncore!1195))
- [[CP-5696] Add new MissingScopes pod](apple/shared/protoncore@8e4f31355da233eba7cba717bba8a7402c6acadb) ([merge request](apple/shared/protoncore!1198))
- [[CP-5784] Fix for wrong title shown at the external signup password screen](apple/shared/protoncore@325daa9198b7c0830baa3bb77044d178ee6a56de) ([merge request](apple/shared/protoncore!1193))
- [Removal of ProtonCore-TestingToolkit/HumanVerification, as it contained no sources](apple/shared/protoncore@3b5f790f02485f27fa4197658b8ca5c5314d5d04) ([merge request](apple/shared/protoncore!1197))
- [[CP-5696] Add missing scopes handler](apple/shared/protoncore@9c7f1633d112db0d574f99a4a51124efe577a55e) ([merge request](apple/shared/protoncore!1191))
- [Pass-specific UI changes](apple/shared/protoncore@6ba1c147292e67978a648114b245cbd88b3f88b1) ([merge request](apple/shared/protoncore!1190))
- [[CP-5695] Handle missing scope error](apple/shared/protoncore@1efe1e7b93a50cf9ce48466380cbf0efb6aa5e2a) ([merge request](apple/shared/protoncore!1187))

### other (1 change)

- [Include underlying errors in certain API responses](apple/shared/protoncore@465db62bb62705bd7351077bf4968bb7e6aa9a4f) ([merge request](apple/shared/protoncore!1201))

### fixed (1 change)

- [i18n: Upgrade translations from crowdin (9c7f1633).](apple/shared/protoncore@dc05795624e5017a67749f7cc703fd61bcbeca65) ([merge request](apple/shared/protoncore!1194))

## 5.2.0 (2023-04-20)

### other (1 change)

- [Fix Krzysztof's username in CODEOWNERS.](apple/shared/protoncore@ee39d975888bbb79aa74c55d3beec31bb3ab71fc) ([merge request](apple/shared/protoncore!1188))

## 5.1.0 (2023-04-14)

###  (3 changes)

- [[CP-5603] Add manual test run](apple/shared/protoncore@dee7a40efe59cf56c4ed0ada6bd886baa31ffb9a) ([merge request](apple/shared/protoncore!1176))
- [i18n: Upgrade translations from crowdin (9bb9a037).](apple/shared/protoncore@994663f1a942dc71e5e0a0abc238e6ccadbd82ce) ([merge request](apple/shared/protoncore!1168))
- [[CP-4765] Update isKeyV2 requirement](apple/shared/protoncore@1fd4eb1b2e3a5ae2374f705b1e0ecdd14ea258eb) ([merge request](apple/shared/protoncore!1166))

### changed (1 change)

- [[CP-5645] Define OptionSet for `subscribed` property in User model](apple/shared/protoncore@40b4467e7488ee7bb5dc7cbb1f84a2ce66f53005) ([merge request](apple/shared/protoncore!1151))

### added (2 changes)

- [Restore (?) missing methods](apple/shared/protoncore@275604479d05208d3c2c70828c3f766c1659fbdd) ([merge request](apple/shared/protoncore!1174))
- [[CP-5686] Show user the internal signup flow if they try external flow with Proton domain](apple/shared/protoncore@798c59b46ff577e880e58a8bf9910816f3cebcdd) ([merge request](apple/shared/protoncore!1173))

### other (2 changes)

- [[CP-5603] Reorganise UnitTests fastfile](apple/shared/protoncore@b4cc8ec4f48cb866fc3f7d0366af8429078dad79) ([merge request](apple/shared/protoncore!1169))
- [Run integration tests on Atlas](apple/shared/protoncore@56e58659834736275a32a04ffd72b1e64fe928f5) ([merge request](apple/shared/protoncore!1171))

## 5.0.1 (2023-04-11)

###  (1 change)

- [[CP-4765] Remove unused deprecated code](apple/shared/protoncore@9bb9a0379f67236deb7bd0a0a2eca1ac51f86026) ([merge request](apple/shared/protoncore!1165))

### other (2 changes)

- [Update assignments in release script](apple/shared/protoncore@26b0f0c69452d84bddafd15ba06332cb32cebb19) ([merge request](apple/shared/protoncore!1164))
- [[CP-5603] Disable pipeline on commit branch](apple/shared/protoncore@acb3a4ed7c72af1cc65477ff6b5dec86a267d9ba) ([merge request](apple/shared/protoncore!1158))

### changed (1 change)

- [MAILIOS-3367 Change API endpoint for Mail from api.protonmail.ch to mail-api.proton.me](apple/shared/protoncore@42d9e9f98529a87ab44263ea8b50af9d8651b622) ([merge request](apple/shared/protoncore!1167))

### added (1 change)

- [VPN build, with go 1.20.2 patched for macos](apple/shared/protoncore@e3d941ff6251f8187dbf96c9d2a6204b54eb5528) ([merge request](apple/shared/protoncore!1162))

## 5.0.0 (2023-04-05)

###  (5 changes)

- [[CP-5676] VPN supports internal signup](apple/shared/protoncore@78908be4271639810b8f61ad9f8f0fdd84f5d0dc) ([merge request](apple/shared/protoncore!1161))
- [[CP-5603] Improve ci pipeline](apple/shared/protoncore@267b09fd0e00fd69041b22802b924dd9a93e27cc) ([merge request](apple/shared/protoncore!1138))
- [[CP-4540] Exposing action sheet properties used in the Mail's unit tests and...](apple/shared/protoncore@a128cab58a9daa2b7b008ea67da546659ed5d3e8) ([merge request](apple/shared/protoncore!1157))
- [MAILIOS-3300, Fix account switcher position issue to enable landscape](apple/shared/protoncore@c63c4c3c84f6340d2bd13a8b58e2bac91d86bee4) ([merge request](apple/shared/protoncore!1144))
- [Enable APPLICATION_EXTENSION_API_ONLY where applicable](apple/shared/protoncore@35264c94ecfbee62c929bef11c58b78aebf14387) ([merge request](apple/shared/protoncore!1156))

### fixed (1 change)

- [CP-5320 Fix race condition in Keychain](apple/shared/protoncore@ea6ffab661f968411dc53b8491d6ba97d4d2a56e) ([merge request](apple/shared/protoncore!1139))

### added (1 change)

- [[ABUSE-1863] Implement pow on iOS clients.](apple/shared/protoncore@cbf1457456883613c8eee92a84788d88cedf6d67) ([merge request](apple/shared/protoncore!1145))

## 4.0.1 (2023-03-29)

### fixed (3 changes)

- [Resolve CP-5234 "Fix/ treat account unavailable as failure"](apple/shared/protoncore@fe93952587547ce1417a13cf81a686ffafefbc27) ([merge request](apple/shared/protoncore!1152))
- [MAILIOS-3317 Fix ResponseError localizedDescription](apple/shared/protoncore@6b8bbc0ab38b7ddbe508fcf3575487d0441f90d2) ([merge request](apple/shared/protoncore!1154))
- [Fix invalid banner position in UITableViewController](apple/shared/protoncore@3dae933ca50a41daebf03dbaf890362651d2c101) ([merge request](apple/shared/protoncore!1140))

###  (4 changes)

- [[CP-5626] Clear session in the login flow on user coming back to the login screen](apple/shared/protoncore@a835ec24dcd301ee59ddec7d6d29b25e6829af1c) ([merge request](apple/shared/protoncore!1148))
- [Fix actionsheet UI related bug](apple/shared/protoncore@3c3e82834720de73fc1fde918762eb3333c2e7ca) ([merge request](apple/shared/protoncore!1146))
- [Update crypto builds to gopenpgp v2.6.1-proton and go-srp to v0.0.7 (go 1.20.2)](apple/shared/protoncore@3c5b20053bd108448ae03e04d6da902d8ec8d285) ([merge request](apple/shared/protoncore!1141))
- [Update crypto builds to gopenpgp v2.6.1-proton and go-srp to v0.0.7 (go 1.15.15)](apple/shared/protoncore@694ba46fa6e16f6aab4fc06d98b839a179234827) ([merge request](apple/shared/protoncore!1142))

### other (1 change)

- [Run unit tests targets on the dedicated simulator](apple/shared/protoncore@5a1e84e98557faf9d35d4efdcc3ae50fb4643227) ([merge request](apple/shared/protoncore!1153))

## 4.0.0 (2023-03-22)

### other (3 changes)

- [Remove the unnecessary description check from CompleteRobot to speed up the check](apple/shared/protoncore@3a87a90de17da2c1238869404a4f724588387f85) ([merge request](apple/shared/protoncore!1137))
- [[CP-5438] Snapshot tests for payments screen when there's a user with unknown plan](apple/shared/protoncore@a12debb8e8f937dbaa52e340555561be6d1b0ab5) ([merge request](apple/shared/protoncore!1123))
- [Crypto build, with go 1.20.2](apple/shared/protoncore@395b7dd6961f766ec13a1bf6d3f44a4fdbc86542) ([merge request](apple/shared/protoncore!1133))

### added (2 changes)

- [CP-5377, ActionSheet rewrite](apple/shared/protoncore@e017e9ee1b57a35cc642db01c3f9f859b8abf597) ([merge request](apple/shared/protoncore!1084))
- [[CP-5341] UI tests for EA cap C](apple/shared/protoncore@e3f9f584369d74980e874b92f36017ac3e2c1826) ([merge request](apple/shared/protoncore!1136))

###  (1 change)

- [Crypto build, with go 1.15.15](apple/shared/protoncore@801b19b0428a5edf65408a26af32e6ad6b0146d4) ([merge request](apple/shared/protoncore!1134))

## 3.29.1 (2023-03-17)

### fixed (2 changes)

- [[CP-5594] Fix issue in response code handler](apple/shared/protoncore@063c1551ac365d138e178f96f5a9f339c8a66b8e) ([merge request](apple/shared/protoncore!1131))
- [[CP-5592] Do not ask for second password if the app do not need keys](apple/shared/protoncore@3d681b996a545cc3e01f4b796dc1a5e7c09e4454) ([merge request](apple/shared/protoncore!1132))

### changed (3 changes)

- [[ABUSE-1831] Added login error message with link clickable](apple/shared/protoncore@90f6cc180f02fd3bcb9e1c8476711b033281b636) ([merge request](apple/shared/protoncore!1130))
- [Update gopenpgp to v2.6.0 and vpn libs to latest (go 1.20.2)](apple/shared/protoncore@a7fc4304cd2f712051fc540d586a23bd404b60e5) ([merge request](apple/shared/protoncore!1128))
- [Update gopenpgp to v2.6.0 and vpn libs to latest (go 1.15.15)](apple/shared/protoncore@bd4659c2b9903d6e523e3db00ec3ffaf59e43a22) ([merge request](apple/shared/protoncore!1129))

## 3.29.0 (2023-03-14)

### changed (1 change)

- [[CP-5560] Fixes for issues found during integration of EA cap B](apple/shared/protoncore@bc95930664927033b09d7b0453172187d5b1cb2a) ([merge request](apple/shared/protoncore!1125))

### fixed (2 changes)

- [[CP-5233] Fix observability integration tests not being run](apple/shared/protoncore@557e5422e601a72e6ab08b46c628d7d0f774fc39) ([merge request](apple/shared/protoncore!1118))
- [[CP-5247] Don't acquire new unauth session if there's one already available](apple/shared/protoncore@16eb7e8000698e047c8af4be3228f10839bc5abf) ([merge request](apple/shared/protoncore!1114))

###  (9 changes)

- [i18n: Upgrade translations from crowdin (50ec58b5).](apple/shared/protoncore@73a8de9f9f70c7e5997f692cbc8cb80e017bbf8f) ([merge request](apple/shared/protoncore!1106))
- [[3.28.2] Releasing core version 3.28.2](apple/shared/protoncore@2f9505d0f40aba73d9501c6ba2c4e630bf6f6f8b) ([merge request](apple/shared/protoncore!1115))
- [[CP-5407] Add metrics to HV](apple/shared/protoncore@b97b2ae451e2917cbd3ebb7f739d88dae169f137) ([merge request](apple/shared/protoncore!1110))
- [Add the `-dev` prefix to the app version](apple/shared/protoncore@fcac3311ef689c3678245e615cba52d937c5aa27) ([merge request](apple/shared/protoncore!1109))
- [[CP-5448] Add Observability feature flag](apple/shared/protoncore@9d657aa36ec202ece01d290e2944e78fe8558431) ([merge request](apple/shared/protoncore!1111))
- [[CP-5408] Implement Plan selection screen metrics](apple/shared/protoncore@9e267011151a39d4677a58af44f21a86021f564c) ([merge request](apple/shared/protoncore!1104))
- [[CP-5184] Generating keys when signing in with the external address without...](apple/shared/protoncore@970022230931339566bd0965440ad4abec88172b) ([merge request](apple/shared/protoncore!1105))
- [MAILIOS-2607 Add missing DocC documentation](apple/shared/protoncore@293a6deb8b2863d0845cb1de3bde1f6367525b23) ([merge request](apple/shared/protoncore!1093))
- [i18n: Upgrade translations from crowdin (ad4cd791).](apple/shared/protoncore@1c99555062bcc97f2a4d7e2981eb53d91e4bb197) ([merge request](apple/shared/protoncore!1098))

## 3.28.2 (2023-02-24)

### fixed (1 change)

- [[CP-5247] Don't acquire new unauth session if there's one already available](apple/shared/protoncore@16eb7e8000698e047c8af4be3228f10839bc5abf) ([merge request](apple/shared/protoncore!1114))

###  (7 changes)

- [[CP-5407] Add metrics to HV](apple/shared/protoncore@b97b2ae451e2917cbd3ebb7f739d88dae169f137) ([merge request](apple/shared/protoncore!1110))
- [Add the `-dev` prefix to the app version](apple/shared/protoncore@fcac3311ef689c3678245e615cba52d937c5aa27) ([merge request](apple/shared/protoncore!1109))
- [[CP-5448] Add Observability feature flag](apple/shared/protoncore@9d657aa36ec202ece01d290e2944e78fe8558431) ([merge request](apple/shared/protoncore!1111))
- [[CP-5408] Implement Plan selection screen metrics](apple/shared/protoncore@9e267011151a39d4677a58af44f21a86021f564c) ([merge request](apple/shared/protoncore!1104))
- [[CP-5184] Generating keys when signing in with the external address without...](apple/shared/protoncore@970022230931339566bd0965440ad4abec88172b) ([merge request](apple/shared/protoncore!1105))
- [MAILIOS-2607 Add missing DocC documentation](apple/shared/protoncore@293a6deb8b2863d0845cb1de3bde1f6367525b23) ([merge request](apple/shared/protoncore!1093))
- [i18n: Upgrade translations from crowdin (ad4cd791).](apple/shared/protoncore@1c99555062bcc97f2a4d7e2981eb53d91e4bb197) ([merge request](apple/shared/protoncore!1098))

## 3.28.1 (2023-02-20)

### fixed (2 changes)

- [[CP-5435] Fix for lack of behavioral fingerprints because of two PMChallenge instances used](apple/shared/protoncore@3be05070a6b2dad18e3ee425106565e1d409b5b7) ([merge request](apple/shared/protoncore!1107))
- [[CP-5245] Session is acquired only once even if multiple acquire call are performed](apple/shared/protoncore@10cf4f19759e4c6de2508e562a03138580767f94) ([merge request](apple/shared/protoncore!1100))

###  (4 changes)

- [[CP-5405] Add account creation metrics](apple/shared/protoncore@f3b1bd41178cf0ac98197b926567e7e44d19b721) ([merge request](apple/shared/protoncore!1099))
- [[CP-5424] Rename metrics](apple/shared/protoncore@7baa423f8c70a8232b4283c72d738f69887d1214) ([merge request](apple/shared/protoncore!1103))
- [[CP-5403] Add Observability Env singleton](apple/shared/protoncore@8a02a7b919116c0ddf771b2064d6175d7a365a23) ([merge request](apple/shared/protoncore!1097))
- [[CP-5262] Add timer for observability event](apple/shared/protoncore@ad4cd791bb19843b11501d5979c710801cda7963) ([merge request](apple/shared/protoncore!1094))

### other (1 change)

- [[CP-5404] Sending screen load events](apple/shared/protoncore@50ec58b585251e5a4a1d6c2dc8771e278f5c4c53) ([merge request](apple/shared/protoncore!1102))

### deprecated (1 change)

- [Deprecate udpate in favor of update](apple/shared/protoncore@43d73a77774e6bff1111d0cc3e93ffeb7701dac5) ([merge request](apple/shared/protoncore!1096))

## 3.28.0 (2023-02-07)

###  (2 changes)

- [[CP-5374] Remove flakiness from SignupHumanVerificationV3Robot when loading web view](apple/shared/protoncore@f0755af9d38c08e9798995829aeb4b0635d1aa00) ([merge request](apple/shared/protoncore!1091))
- [[CP-5261] Add Observability integration tests](apple/shared/protoncore@e209a21f4c9f1dcae00967ff9490f2078a65014f) ([merge request](apple/shared/protoncore!1088))

### changed (1 change)

- [[CP-5334] Opportunistic unauth session call in LoginUI and injecting PMAPIService instance](apple/shared/protoncore@467a5dea3bf683d3c7f45954d79e5518abf82325) ([merge request](apple/shared/protoncore!1090))

## 3.27.0 (2023-02-01)

###  (3 changes)

- [[CP-5261] Add Observability Endpoint and Service](apple/shared/protoncore@0128eaa5dd529f1db11de9237b7ad31c86e34bcd) ([merge request](apple/shared/protoncore!1086))
- [Fixed _key setupCryptoTransformers in keymaker](apple/shared/protoncore@14592ffa62f7bffdee4e1a0dcc09bdfdac1c6856) ([merge request](apple/shared/protoncore!1077))
- [Fix typos pmtest](apple/shared/protoncore@69dcd45e733d313bb1c798ce15fe8518ee8ff5d8) ([merge request](apple/shared/protoncore!1067))

### added (3 changes)

- [[CP-5260] Observability events definitions](apple/shared/protoncore@e213e9cfa26d59d6266f7630d9a15fb55e39724b) ([merge request](apple/shared/protoncore!1079))
- [[MAILIOS-2607] Option to add views to PMActionSheetHeaderView title row](apple/shared/protoncore@3e49bc109123bbd1b45627798780a4413e481496) ([merge request](apple/shared/protoncore!1080))
- [[CP-5052] Opportunistic session aquisition call](apple/shared/protoncore@91da72e32f056ba5ff91610bfbd0938a644fa0f7) ([merge request](apple/shared/protoncore!1078))

## 3.26.2 (2023-01-20)

### changed (2 changes)

- [Put DoH A record queries behind feature flag](apple/shared/protoncore@16f10cb1c6bd85cdce9cc2a8c6c6e3314a7d7657) ([merge request](apple/shared/protoncore!1074))
- [[CP-5201] Unauth session 401 error handling logic](apple/shared/protoncore@3989db6fd8aa31b7cee2d57bd84e413417871a8c) ([merge request](apple/shared/protoncore!1073))

###  (1 change)

- [[CP-5263] - [Core iOS] [EA Cap A] Wrong message for status-code 5098](apple/shared/protoncore@02f3a6f1bc829213d7e53dce922b3141d6c567a1) ([merge request](apple/shared/protoncore!1072))

## 3.26.1 (2023-01-13)

###  (2 changes)

- [Ignore user-defined certificate settings by default [CP-5258]](apple/shared/protoncore@c88dc257b26c4ae63089cc9b748810ade8f3c398) ([merge request](apple/shared/protoncore!1065))
- [CP-4629 - [iOS] VPN sign in - Text update](apple/shared/protoncore@de26057f3162d3dea345e91394550286fce8e1c7) ([merge request](apple/shared/protoncore!1064))

## 3.26.0 (2023-01-10)

###  (10 changes)

- [Removes deprecated HV v2](apple/shared/protoncore@671c21752957db60aace6fdd669633c841c4fbe3) ([merge request](apple/shared/protoncore!1034))
- [Update gopenpgp to v2.5.0](apple/shared/protoncore@5153aa9c7ae8c25377d4340456c21f7374d43fdf) ([merge request](apple/shared/protoncore!1042))
- [[CP-4894] Add new pod for Observability](apple/shared/protoncore@8c9fef8ada3486b311a4b6149d7c993ebf5fe57d) ([merge request](apple/shared/protoncore!1039))
- [Remove unnecessary logs that are litering the console output and log file](apple/shared/protoncore@3640d4005f82c836c6c76838b84f52e6f5aeaac7) ([merge request](apple/shared/protoncore!1050))
- [[CP-5188] - [iOS] V5 Modules renaming](apple/shared/protoncore@046c4593964124317cf33e155728b15b233ffae0) ([merge request](apple/shared/protoncore!1055))
- [Update gitignore and remove untracked files](apple/shared/protoncore@b4cac8b4085a1507d6109eee6978f5487e7f720d) ([merge request](apple/shared/protoncore!1047))
- [[CP-4522] - [iOS] V4 -> V5 Project structure migration](apple/shared/protoncore@c702e0416f5e70d89fc24504a331575ea8d861ac) ([merge request](apple/shared/protoncore!1054))
- [[CP-4521] - [iOS] V4 -> V5 CoreTranslation migration](apple/shared/protoncore@7ef2ddc14db0cc3fd3612d20d1fed9cc04249c44) ([merge request](apple/shared/protoncore!1052))
- [[CP-5053] - [iOS] Update the `PMAPIService` initialiser to expect the cached session UID on start](apple/shared/protoncore@90931051e824d1dc2849cfff1831930830a228d0) ([merge request](apple/shared/protoncore!1046))
- [[CP-4520] - [iOS] V4 -> V5 Module files migration](apple/shared/protoncore@df5f8e028175f858a23eb2b29654dbfbf29a1135) ([merge request](apple/shared/protoncore!1048))

### other (1 change)

- [Remove the dependency on ObfuscatedConstants from the TestingToolkit module](apple/shared/protoncore@1573955769e1988770ee98f2c4d5c3f83be3074e) ([merge request](apple/shared/protoncore!1058))

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
