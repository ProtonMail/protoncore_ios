// Objective-C API for talking to github.com/ProtonMail/gopenpgp/v2/constants Go package.
//   gobind -lang=objc github.com/ProtonMail/gopenpgp/v2/constants
//
// File is generated by gobind. Do not edit.

#ifndef __Constants_H__
#define __Constants_H__

@import Foundation;
#include "ref.h"
#include "Universe.objc.h"


/**
 * Cipher suite names.
 */
FOUNDATION_EXPORT NSString* _Nonnull const ConstantsAES128;
/**
 * Cipher suite names.
 */
FOUNDATION_EXPORT NSString* _Nonnull const ConstantsAES192;
/**
 * Cipher suite names.
 */
FOUNDATION_EXPORT NSString* _Nonnull const ConstantsAES256;
/**
 * Constants for armored data.
 */
FOUNDATION_EXPORT NSString* _Nonnull const ConstantsArmorHeaderComment;
/**
 * Constants for armored data.
 */
FOUNDATION_EXPORT NSString* _Nonnull const ConstantsArmorHeaderVersion;
/**
 * Cipher suite names.
 */
FOUNDATION_EXPORT NSString* _Nonnull const ConstantsCAST5;
FOUNDATION_EXPORT const int64_t ConstantsDefaultCompression;
FOUNDATION_EXPORT const int64_t ConstantsDefaultCompressionLevel;
/**
 * Constants for armored data.
 */
FOUNDATION_EXPORT NSString* _Nonnull const ConstantsPGPMessageHeader;
/**
 * Constants for armored data.
 */
FOUNDATION_EXPORT NSString* _Nonnull const ConstantsPGPSignatureHeader;
/**
 * Constants for armored data.
 */
FOUNDATION_EXPORT NSString* _Nonnull const ConstantsPrivateKeyHeader;
/**
 * Constants for armored data.
 */
FOUNDATION_EXPORT NSString* _Nonnull const ConstantsPublicKeyHeader;
FOUNDATION_EXPORT const long ConstantsSIGNATURE_FAILED;
FOUNDATION_EXPORT const long ConstantsSIGNATURE_NOT_SIGNED;
FOUNDATION_EXPORT const long ConstantsSIGNATURE_NO_VERIFIER;
FOUNDATION_EXPORT const long ConstantsSIGNATURE_OK;
/**
 * Cipher suite names.
 */
FOUNDATION_EXPORT NSString* _Nonnull const ConstantsThreeDES;
/**
 * Cipher suite names.
 */
FOUNDATION_EXPORT NSString* _Nonnull const ConstantsTripleDES;
FOUNDATION_EXPORT NSString* _Nonnull const ConstantsVersion;

#endif
