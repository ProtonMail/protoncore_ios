// Objective-C API for talking to gitlab.protontech.ch/ProtonVPN/development/clients-shared.git/vpnPing Go package.
//   gobind -lang=objc gitlab.protontech.ch/ProtonVPN/development/clients-shared.git/vpnPing
//
// File is generated by gobind. Do not edit.

#ifndef __VpnPing_H__
#define __VpnPing_H__

@import Foundation;
#include "ref.h"
#include "Universe.objc.h"


FOUNDATION_EXPORT BOOL VpnPingPingSync(NSString* _Nullable ip, long port, NSString* _Nullable serverKeyBase64, long timeoutMilliseconds);

FOUNDATION_EXPORT BOOL VpnPingPingSyncWithError(NSString* _Nullable ip, long port, NSString* _Nullable serverKeyBase64, long timeoutMilliseconds, BOOL* _Nullable ret0_, NSError* _Nullable* _Nullable error);

#endif
