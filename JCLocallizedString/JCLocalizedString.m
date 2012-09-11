//
//  JCLocalizedString.m
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

#import "JCLocalizedString.h"

#define kJCLocalizedStringStandardUserDefaultsStoredLocalizationKey @"kJCLocalizedStringStandardUserDefaultsStoredLocalizationKey"

@implementation JCLocalizedManager
@synthesize localizationBundle = _localizationBundle;
@synthesize activeLocalization = _activeLocalization;
@synthesize preferredLocalizations = _preferredLocalizations;

+ (JCLocalizedManager *)sharedManager
{
  static dispatch_once_t onceToken;
  static JCLocalizedManager *localizedString = nil;

  dispatch_once(&onceToken, ^{
    localizedString = [[self alloc] initWithLocalizationBundle:[self localizationBundle]];
  });

  return localizedString;
}

+ (NSBundle *)localizationBundle
{
  NSString *bundleName = [[NSBundle mainBundle] objectForInfoDictionaryKey:kJCLocalizedStringMainBundleInfoPlistKey];
  NSBundle *bundle = nil;
  if (bundleName)
  {
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:bundleName ofType:@"bundle"]; //wtf this returns anything of type bundle with nil path
    bundle = [NSBundle bundleWithPath:bundlePath];
  }

  return bundle ?: [NSBundle mainBundle];
}

- (id)init
{
  NSBundle *localizationBundle = [[self class] localizationBundle];
  return [self initWithLocalizationBundle:localizationBundle];
}

- (id)initWithLocalizationBundle:(NSBundle *)localizationBundle
{
  NSString *localization = [self defaultLocalizationForBundle:localizationBundle];
  return [self initWithLocalizationBundle:localizationBundle activeLocalization:localization];
}

- (id)initWithLocalizationBundle:(NSBundle *)localizationBundle activeLocalization:(NSString *)activeLocalization
{
  if (localizationBundle == nil)
  {
    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"localization bundle must not be nil" userInfo:nil];
  }
  else if ([localizationBundle localizations] == nil)
  {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"localization bundle must contain some localizations" userInfo:nil];
  }

  if ((self = [super init]))
  {
    _localizationBundle = localizationBundle;
#if !__has_feature(objc_arc)
    [localizationBundle retain];
#endif
    self.activeLocalization = activeLocalization;
    _tableCache = [[NSCache alloc] init];
    _tableCache.delegate = self;
    _tableCache.name = @"JCLocallizedString strings table cache";
  }

  return self;
}

- (void)dealloc
{
#if !__has_feature(objc_arc)
  [_localizationBundle release];
  [_activeLocalization release];
  [_tableCache release];
  [super dealloc];
#endif
}

- (NSArray *)preferredLocalizations
{
  if (nil == _preferredLocalizations)
  {
    NSArray *preferredLanguages = [NSLocale preferredLanguages];
    NSArray *bundleLanguages = [self.localizationBundle localizations];

    _preferredLocalizations = [bundleLanguages sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
      NSUInteger idx1 = [preferredLanguages indexOfObject:obj1];
      NSUInteger idx2 = [preferredLanguages indexOfObject:obj2];

      if (idx1 > idx2 || [obj2 isEqualToString:self.activeLocalization]) return NSOrderedDescending;
      if (idx1 < idx2 || [obj1 isEqualToString:self.activeLocalization]) return NSOrderedAscending;
      return NSOrderedSame;
    }];
#if !__has_feature(objc_arc)
    [_preferredLocalizations retain];
#endif
  }

  return _preferredLocalizations;
}

- (void)setActiveLocalization:(NSString *)activeLocalization
{
  if (activeLocalization == nil)
  {
    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"active localization must not be nil" userInfo:nil];
  }
  else if (![[self.localizationBundle localizations] containsObject:activeLocalization])
  {
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:activeLocalization,@"activeLocalization",self.localizationBundle,@"localizationBundle",nil];
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"active localization not found" userInfo:userInfo];
  }

  if (activeLocalization != _activeLocalization)
  {
#if __has_feature(objc_arc)
    _activeLocalization = activeLocalization;
    _preferredLocalizations = nil;
#else
    id old = _activeLocalization;
    _activeLocalization = [activeLocalization retain];
    [old release];
    [_preferredLocalizations release];
    _preferredLocalizations = nil;
#endif

    [[NSUserDefaults standardUserDefaults] setObject:_activeLocalization forKey:kJCLocalizedStringStandardUserDefaultsStoredLocalizationKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:_activeLocalization,@"activeLocalization",nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kJCLocalisedStringActivteLocalizationChangedNotification
                                                        object:self
                                                      userInfo:userInfo];
  }
}

- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName
{
  return [self localizedStringForKey:key value:value table:tableName bundle:self.localizationBundle];
}

- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName bundle:(NSBundle *)bundle
{
  NSDictionary *stringsFileDictionary = [self loadStringsTable:tableName localization:self.activeLocalization bundle:bundle];
    
  NSString *stringToReturn = [stringsFileDictionary objectForKey:key];
  
  if (nil != stringToReturn) return stringToReturn;

  if (nil != value) return value;

  BOOL showNonLocalizedString = [[[NSUserDefaults standardUserDefaults] valueForKey:@"NSShowNonLocalizedStrings"] boolValue];
  if (showNonLocalizedString)
  {
    NSLog(@"JCLocalizedManager: Unimplemented key '%@' for table '%@'", key, tableName);
    return [key uppercaseString];
  }

  return key;
}

- (NSString *)localizedResource:(NSString *)resource ofType:(NSString *)type
{
  return [self.localizationBundle pathForResource:resource ofType:type inDirectory:nil forLocalization:self.activeLocalization];
}

#pragma mark - Internal

- (NSDictionary *)loadStringsTable:(NSString *)tableName localization:(NSString *)localization bundle:(NSBundle *)bundle
{
  tableName = tableName ?: kJCLocalizedStringDefaultTableName;
  
  NSString *stringsFilePath = [bundle pathForResource:tableName ofType:@"strings" inDirectory:nil forLocalization:localization];
  NSAssert(stringsFilePath != nil, @"strings table not found in bundle");

  NSDictionary *cachedDictionary = [_tableCache objectForKey:stringsFilePath];
  if (cachedDictionary) return cachedDictionary;

  NSError *error = nil;
  id plist = [NSPropertyListSerialization propertyListWithData:[NSData dataWithContentsOfFile:stringsFilePath] options:NSPropertyListImmutable format:nil error:&error];

  NSAssert(error == nil, [error description]);

  [_tableCache setObject:plist forKey:stringsFilePath];

  return (NSDictionary *)plist;
}

- (NSString *)defaultLocalizationForBundle:(NSBundle *)localizationBundle
{
  //FIXME: similar logic to preferredLanguages
  NSString *storedLocalization = [[NSUserDefaults standardUserDefaults] objectForKey:kJCLocalizedStringStandardUserDefaultsStoredLocalizationKey];

  if (storedLocalization) return storedLocalization;

  NSArray *preferredLanguages = [NSLocale preferredLanguages];
  NSArray *bundleLocalizations = [localizationBundle localizations];

  for (NSString *IETF_BCP_47_identifier in preferredLanguages)
  {
    if ([bundleLocalizations containsObject:IETF_BCP_47_identifier])
    {
      return IETF_BCP_47_identifier;
    }
  }

  if ([bundleLocalizations count] > 0)
  {
    return [bundleLocalizations objectAtIndex:0];
  }

  return nil;
}

#pragma mark - NSCacheDelegate

- (void)cache:(NSCache *)cache willEvictObject:(id)obj
{
}

@end

@implementation NSBundle (JCLocalizedManager)

- (NSString *)JCLocalizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName
{
  return [[JCLocalizedManager sharedManager] localizedStringForKey:key value:value table:tableName bundle:self];
}

@end
