// AUTOGENERATED FILE - DO NOT MODIFY!
// This file generated by Djinni from open_pgp.djinni

#import <Foundation/Foundation.h>
@class PMNITelephone;


@interface PMNITelephone : NSObject

- (nonnull NSArray<NSString *> *)getTypes;

- (nonnull NSString *)getText;

+ (nullable PMNITelephone *)createInstance:(nonnull NSString *)type
                                    number:(nonnull NSString *)number;

@end
