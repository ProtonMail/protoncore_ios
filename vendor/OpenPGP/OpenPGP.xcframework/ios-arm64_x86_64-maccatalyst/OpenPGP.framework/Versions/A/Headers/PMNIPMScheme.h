// AUTOGENERATED FILE - DO NOT MODIFY!
// This file generated by Djinni from open_pgp.djinni

#import <Foundation/Foundation.h>
@class PMNIPMScheme;


@interface PMNIPMScheme : NSObject

- (nonnull NSString *)getValue;

- (nonnull NSString *)getType;

- (nonnull NSString *)getGroup;

- (void)setGroup:(nonnull NSString *)g;

+ (nullable PMNIPMScheme *)createInstance:(nonnull NSString *)type
                                    value:(nonnull NSString *)value;

@end
