//
//  JCLocalizedString.h
//
//  Created by Jesse Collis on 31/07/12.
//  Copyright (c) 2012, Jesse Collis JC Multimedia Design. <jesse@jcmultimedia.com.au>
//  All rights reserved.
//
//  * Redistribution and use in source and binary forms, with or without
//   modification, are permitted provided that the following conditions are met:
//
//  * Redistributions of source code must retain the above copyright
//   notice, this list of conditions and the following disclaimer.
//
//  * Redistributions in binary form must reproduce the above copyright
//   notice, this list of conditions and the following disclaimer in the
//   documentation and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE
//

#import <Foundation/Foundation.h>

#define JCLocalizedString(key, description) \
[[JCLocalizedManager sharedManager] localizedStringForKey:(key) value:nil table:nil]

#define JCLocalizedStringFromTable(key, tbl, comment) \
[[JCLocalizedManager sharedManager] localizedStringForKey:(key) value:nil table:(tbl)]

#define JCLocalizedStringFromTableInBundle(key, tbl, bundle, comment) \
[bundle JCLocalizedStringForKey:(key) value:nil table:(tbl)]

#define JCLocalizedStringWithDefaultValue(key, tbl, bundle, val, comment) \
[bundle JCLocalizedStringForKey:(key) value:(val) table:(tbl)]

#define kJCLocalizedStringMainBundleInfoPlistKey @"JCLocalizationBundle"
#define kJCLocalizedStringDefaultTableName @"Localizable"
#define kJCLocalisedStringActivteLocalizationChangedNotification @"JCLocalisedStringActivteLocalizationChangedNotification"

#define JCLocalizedPNGPath(filename) \
[[JClocalizedManager sharedManager] localizedResource:(filename) ofType:@"png"];

// TODO: consider integrating auto updating locale

@interface JCLocalizedManager : NSObject <NSCacheDelegate>{
  @private
  NSCache *_tableCache;
}

@property (nonatomic, readonly, strong) NSBundle *localizationBundle;
@property (nonatomic, strong) NSString *activeLocalization;

+ (JCLocalizedManager *)sharedManager;

+ (NSBundle *)localizationBundle;

- (NSArray *)preferredLanguages;

- (id)initWithLocalizationBundle:(NSBundle *)localizationBundle;
- (id)initWithLocalizationBundle:(NSBundle *)localizationBundle activeLocalization:(NSString *)localization;

- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName;
- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName bundle:(NSBundle *)bundle;

- (NSString *)localizedResource:(NSString *)resource ofType:(NSString *)type;

@end

@interface NSBundle (JCLocalizedManager)

/*
 key: The key for a string in the table identified by tableName.
 value: The value to return if key is nil or if a localized string for key can’t be found in the table.
 tableName: The receiver’s string table to search. If tableName is nil or is an empty string, the method attempts to use the table in Localizable.strings.
 */

// this can be called on any bundle, not just the localizationBundle, backs back onto JCLocalizedString
- (NSString *)JCLocalizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName;


/* Using the user default NSShowNonLocalizedStrings, you can alter the behavior of localizedStringForKey:value:table:
 to log a message when the method can’t find a localized string. If you set this default to YES
 (in the global domain or in the application’s domain), then when the method can’t find a localized string in the table,
 it logs a message to the console and capitalizes key before returning it.
 */

@end
