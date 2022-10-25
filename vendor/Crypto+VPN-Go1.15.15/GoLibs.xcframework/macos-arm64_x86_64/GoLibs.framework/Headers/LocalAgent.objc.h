// Objective-C API for talking to github.com/ProtonVPN/go-vpn-lib/localAgent Go package.
//   gobind -lang=objc github.com/ProtonVPN/go-vpn-lib/localAgent
//
// File is generated by gobind. Do not edit.

#ifndef __LocalAgent_H__
#define __LocalAgent_H__

@import Foundation;
#include "ref.h"
#include "Universe.objc.h"


@class LocalAgentAgentConnection;
@class LocalAgentConsts;
@class LocalAgentErrorMessage;
@class LocalAgentFeatures;
@class LocalAgentGetMessage;
@class LocalAgentMessageSocket;
@class LocalAgentReason;
@class LocalAgentStatusMessage;
@class LocalAgentStringArray;
@protocol LocalAgentNativeClient;
@class LocalAgentNativeClient;

@protocol LocalAgentNativeClient <NSObject>
- (void)log:(NSString* _Nullable)text;
- (void)onError:(long)code description:(NSString* _Nullable)description;
- (void)onState:(NSString* _Nullable)state;
- (void)onStatusUpdate:(LocalAgentStatusMessage* _Nullable)status;
@end

@interface LocalAgentAgentConnection : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
- (nullable instancetype)init:(NSString* _Nullable)clientCertPEM clientKeyPEM:(NSString* _Nullable)clientKeyPEM serverCAsPEM:(NSString* _Nullable)serverCAsPEM host:(NSString* _Nullable)host certServerName:(NSString* _Nullable)certServerName client:(id<LocalAgentNativeClient> _Nullable)client features:(LocalAgentFeatures* _Nullable)features connectivity:(BOOL)connectivity;
@property (nonatomic) NSString* _Nonnull state;
@property (nonatomic) LocalAgentStatusMessage* _Nullable status;
- (void)close;
- (void)setConnectivity:(BOOL)available;
- (void)setFeatures:(LocalAgentFeatures* _Nullable)features;
@end

@interface LocalAgentConsts : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
- (nonnull instancetype)init;
/**
 * States
 */
@property (nonatomic) NSString* _Nonnull stateConnecting;
@property (nonatomic) NSString* _Nonnull stateConnected;
@property (nonatomic) NSString* _Nonnull stateSoftJailed;
@property (nonatomic) NSString* _Nonnull stateHardJailed;
@property (nonatomic) NSString* _Nonnull stateConnectionError;
@property (nonatomic) NSString* _Nonnull stateServerUnreachable;
@property (nonatomic) NSString* _Nonnull stateWaitingForNetwork;
@property (nonatomic) NSString* _Nonnull stateServerCertificateError;
@property (nonatomic) NSString* _Nonnull stateClientCertificateExpiredError;
@property (nonatomic) NSString* _Nonnull stateClientCertificateUnknownCA;
@property (nonatomic) NSString* _Nonnull stateDisconnected;
/**
 * Error codes
 */
@property (nonatomic) long errorCodeGuestSession;
@property (nonatomic) long errorCodeRestrictedServer;
@property (nonatomic) long errorCodeBadCertSignature;
@property (nonatomic) long errorCodeCertNotProvided;
@property (nonatomic) long errorCodeCertificateExpired;
@property (nonatomic) long errorCodeCertificateRevoked;
@property (nonatomic) long errorCodeMaxSessionsUnknown;
@property (nonatomic) long errorCodeMaxSessionsFree;
@property (nonatomic) long errorCodeMaxSessionsBasic;
@property (nonatomic) long errorCodeMaxSessionsPlus;
@property (nonatomic) long errorCodeMaxSessionsVisionary;
@property (nonatomic) long errorCodeMaxSessionsPro;
@property (nonatomic) long errorCodeKeyUsedMultipleTimes;
@property (nonatomic) long errorCodeServerError;
@property (nonatomic) long errorCodePolicyViolationLowPlan;
@property (nonatomic) long errorCodePolicyViolationDelinquent;
@property (nonatomic) long errorCodeUserTorrentNotAllowed;
@property (nonatomic) long errorCodeUserBadBehavior;
@end

@interface LocalAgentErrorMessage : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
- (nonnull instancetype)init;
@property (nonatomic) long code;
@property (nonatomic) NSString* _Nonnull description;
@end

@interface LocalAgentFeatures : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
- (nullable instancetype)init;
- (BOOL)getBool:(NSString* _Nullable)name;
- (long)getCount;
- (long)getInt:(NSString* _Nullable)name;
- (LocalAgentStringArray* _Nullable)getKeys;
- (NSString* _Nonnull)getString:(NSString* _Nullable)name;
- (BOOL)hasKey:(NSString* _Nullable)name;
- (NSData* _Nullable)marshalJSON:(NSError* _Nullable* _Nullable)error;
- (void)remove:(NSString* _Nullable)key;
- (void)setBool:(NSString* _Nullable)name value:(BOOL)value;
- (void)setInt:(NSString* _Nullable)name value:(long)value;
- (void)setString:(NSString* _Nullable)name value:(NSString* _Nullable)value;
- (BOOL)unmarshalJSON:(NSData* _Nullable)data error:(NSError* _Nullable* _Nullable)error;
@end

@interface LocalAgentGetMessage : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
- (nonnull instancetype)init;
@end

@interface LocalAgentMessageSocket : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
- (nonnull instancetype)init;
// skipped method MessageSocket.Receive with unsupported parameter or return types

// skipped method MessageSocket.Send with unsupported parameter or return types

@end

@interface LocalAgentReason : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
- (nonnull instancetype)init;
@property (nonatomic) long code;
@property (nonatomic) BOOL final;
@property (nonatomic) NSString* _Nonnull description;
@end

@interface LocalAgentStatusMessage : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
- (nonnull instancetype)init;
@property (nonatomic) NSString* _Nonnull state;
@property (nonatomic) LocalAgentFeatures* _Nullable features;
@property (nonatomic) LocalAgentReason* _Nullable reason;
@property (nonatomic) NSString* _Nonnull switchTo;
@property (nonatomic) NSString* _Nonnull clientIP;
@end

/**
 * StringArray - helper struct introduced because gomobile doesn't support array return types
 */
@interface LocalAgentStringArray : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
- (nonnull instancetype)init;
- (NSString* _Nonnull)get:(long)i;
- (long)getCount;
@end

FOUNDATION_EXPORT const long LocalAgentErrorClientCertExpired;
FOUNDATION_EXPORT const long LocalAgentErrorClientCertUnknownCA;
FOUNDATION_EXPORT const long LocalAgentErrorInvalidServerCert;
FOUNDATION_EXPORT const long LocalAgentErrorOther;
FOUNDATION_EXPORT const long LocalAgentErrorUnreachable;

/**
 * Constants export constants for the client
 */
FOUNDATION_EXPORT LocalAgentConsts* _Nullable LocalAgentConstants(void);

FOUNDATION_EXPORT LocalAgentAgentConnection* _Nullable LocalAgentNewAgentConnection(NSString* _Nullable clientCertPEM, NSString* _Nullable clientKeyPEM, NSString* _Nullable serverCAsPEM, NSString* _Nullable host, NSString* _Nullable certServerName, id<LocalAgentNativeClient> _Nullable client, LocalAgentFeatures* _Nullable features, BOOL connectivity, NSError* _Nullable* _Nullable error);

FOUNDATION_EXPORT LocalAgentFeatures* _Nullable LocalAgentNewFeatures(void);

@class LocalAgentNativeClient;

@interface LocalAgentNativeClient : NSObject <goSeqRefInterface, LocalAgentNativeClient> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
- (void)log:(NSString* _Nullable)text;
- (void)onError:(long)code description:(NSString* _Nullable)description;
- (void)onState:(NSString* _Nullable)state;
- (void)onStatusUpdate:(LocalAgentStatusMessage* _Nullable)status;
@end

#endif
