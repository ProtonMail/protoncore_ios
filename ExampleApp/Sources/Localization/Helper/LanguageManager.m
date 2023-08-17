//
//  LocalizationManager.m
//  ProtonMail - Created on 6/5/17.
//
//  Copyright (c) 2022 Proton Technologies AG
//
//  This file is part of Proton Technologies AG and ProtonCore.
//
//  ProtonCore is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  ProtonCore is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonCore. If not, see https://www.gnu.org/licenses/.
//

#import "LanguageManager.h"
#import "NSBundle+Language.h"

//Note:: this is port from mail in rush. improve needed
static NSString * const LanguageCodes[] = { @"en", @"de", @"fr",
                                            @"ru", @"es", @"tr",
                                            @"pl", @"uk", @"nl",
                                            @"it", @"pt-BR",
                                            @"zh-Hans", @"zh-Hant", @"ca", @"da", @"cs", @"pt", @"ro", @"hr",
                                            @"hu", @"is", @"kab", @"sv", @"ja", @"id"
};

static NSString * const LanguageStrings[] = { @"English", @"German", @"French",
                                              @"Russian", @"Spanish", @"Turkish",
                                              @"Polish", @"Ukrainian", @"Dutch",
                                              @"Italian", @"PortugueseBrazil", @"Chinese Simplified",
                                              @"Chinese Traditional", @"Catalan", @"Danish",
                                              @"Czech", @"portuguese", @"Romanian", @"Croatian",
                                              @"Hungarian", @"Icelandic", @"Kabyle", @"Swedish",
                                              @"Japanese", @"Indonesian"
};

static NSString * const LanguageSaveKey = @"kProtonMailCurrentLanguageKey";

#ifndef Enterprise
static NSString * const LanguageAppGroup = @"group.com.protonmail.protonmail";
#else
static NSString * const LanguageAppGroup = @"group.ch.protonmail.protonmail";
#endif

#if !defined(NS_BLOCK_ASSERTIONS)
#define STATIC_ASSERT(cond, message_var_name) \
extern char static_assert_##message_var_name[(cond) ? 1 : -1]

STATIC_ASSERT(ELanguageCount == sizeof(LanguageCodes) / sizeof(NSString*), language_count_mismatch_add_or_remove_languageCodes);
STATIC_ASSERT(ELanguageCount == sizeof(LanguageStrings) / sizeof(NSString*), language_count_mismatch_add_or_remove_LanguageStrings);

#endif

@implementation LanguageManager

+ (void)setupCurrentLanguage
{
    NSUserDefaults* shared = [[NSUserDefaults alloc] initWithSuiteName:LanguageAppGroup];
    NSString *currentLanguage = [shared objectForKey:LanguageSaveKey];
    if (!currentLanguage) {
        NSArray *languages = [shared objectForKey:@"AppleLanguages"];
        if (languages.count > 0) {
            currentLanguage = languages[0];
            [shared setObject:currentLanguage forKey:LanguageSaveKey];
            [shared synchronize];
        }
    }
#ifndef USE_ON_FLY_LOCALIZATION
    [shared setObject:@[currentLanguage] forKey:@"AppleLanguages"];
    [shared synchronize];
#else
    [NSBundle setLanguage:currentLanguage];
#endif
}

+ (void)setupCurrentLanguage:(NSBundle *)bundle
{
    NSUserDefaults* shared = [[NSUserDefaults alloc] initWithSuiteName:LanguageAppGroup];
    NSString *currentLanguage = [shared objectForKey:LanguageSaveKey];
    if (!currentLanguage) {
        NSArray *languages = [shared objectForKey:@"AppleLanguages"];
        if (languages.count > 0) {
            currentLanguage = languages[0];
            [shared setObject:currentLanguage forKey:LanguageSaveKey];
            [shared synchronize];
        }
    }
#ifndef USE_ON_FLY_LOCALIZATION
    [shared setObject:@[currentLanguage] forKey:@"AppleLanguages"];
    [shared synchronize];
#else
    [NSBundle setLanguage:currentLanguage passinBundle:bundle];
#endif
}


+ (NSArray * _Nonnull)languageStrings
{
    NSMutableArray *array = [NSMutableArray array];
    for (NSInteger i = 0; i < ELanguageCount; ++i) {
        [array addObject:NSLocalizedString(LanguageStrings[i], @"")];
    }
    return [array copy];
}

+ (NSString * _Nonnull)currentLanguageString
{
    NSString *string = @"";
    NSString *currentCode = [[[NSUserDefaults alloc] initWithSuiteName:LanguageAppGroup] objectForKey:LanguageSaveKey];
    for (NSInteger i = 0; i < ELanguageCount; ++i) {
        if ([currentCode isEqualToString:LanguageCodes[i]]) {
            string = NSLocalizedString(LanguageStrings[i], @"");
            break;
        }
    }
    return string;
}

+ (NSString * _Nullable)currentLanguageCode
{
    return [[[NSUserDefaults alloc] initWithSuiteName:LanguageAppGroup] objectForKey:LanguageSaveKey];
}

+ (NSInteger)currentLanguageIndex
{
    NSInteger index = 0;
    NSString *currentCode = [[[NSUserDefaults alloc] initWithSuiteName:LanguageAppGroup] objectForKey:LanguageSaveKey];
    for (NSInteger i = 0; i < ELanguageCount; ++i) {
        if ( [currentCode containsString: LanguageCodes[i] ] ) {
            index = i;
            break;
        }
    }
    return index;
}


+ (ELanguage)currentLanguageEnum {
    NSInteger index = [self currentLanguageIndex];
    return (ELanguage)(index);
}

+ (void)saveLanguageByIndex:(NSInteger)index
{
    if (index >= 0 && index < ELanguageCount) {
        NSString *code = LanguageCodes[index];
        NSUserDefaults* shared = [[NSUserDefaults alloc] initWithSuiteName:LanguageAppGroup];
        [shared setObject:code forKey:LanguageSaveKey];
        [shared synchronize];
#ifdef USE_ON_FLY_LOCALIZATION
        [NSBundle setLanguage:code];
#endif
    }
}

+ (void)saveLanguageByCode:(NSString* _Nonnull)code {
    NSUserDefaults* shared = [[NSUserDefaults alloc] initWithSuiteName:LanguageAppGroup];
    [shared setObject:code forKey:LanguageSaveKey];
    [shared synchronize];
#ifdef USE_ON_FLY_LOCALIZATION
    [NSBundle setLanguage:code];
#endif
    
}

+ (void)saveLanguageByCode:(NSString* _Nonnull)code passin: (NSBundle * _Nonnull) bundle {
    NSUserDefaults* shared = [[NSUserDefaults alloc] initWithSuiteName:LanguageAppGroup];
    [shared setObject:code forKey:LanguageSaveKey];
    [shared synchronize];
#ifdef USE_ON_FLY_LOCALIZATION
    [NSBundle setLanguage:code passinBundle:bundle];
#endif
    
}


+ (BOOL)isCurrentLanguageRTL
{
    NSInteger currentLanguageIndex = [self currentLanguageIndex];
    return ([NSLocale characterDirectionForLanguage:LanguageCodes[currentLanguageIndex]] == NSLocaleLanguageDirectionRightToLeft);
}

@end
