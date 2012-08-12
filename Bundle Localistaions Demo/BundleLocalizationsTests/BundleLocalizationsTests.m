//
//  BundleLocalizationsTests.m
//  BundleLocalizationsTests
//
//  Created by Jesse Collis on 6/08/12.
//  Copyright (c) 2012 JCMultimedia Design. All rights reserved.
//

#import "BundleLocalizationsTests.h"

@interface BundleLocalizationsTests() {
  __strong NSBundle *_classBundle;
}

@end

@implementation BundleLocalizationsTests

- (void)setUp
{
  [super setUp];
  _classBundle = [NSBundle bundleForClass:[self class]];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testThatABundleWithNoLprojDirectoriesReturnsNil
{
  NSString *noLprojBundle = [_classBundle pathForResource:@"JCLocalizedStringNoLproj" ofType:@"bundle"];
  STAssertNotNil(noLprojBundle, @"the bundle should be there.. ;(");
  
  NSArray *localization = [[NSBundle bundleWithPath:noLprojBundle] localizations];
  STAssertNil(localization, @"bundle localization can't be nil");
}

- (void)testThatABundleWithRandomLprojDirectoriesHasLocalizationsOrNot
{
  NSString *bundle = [_classBundle pathForResource:@"JCLocalizedStringRandomLproj" ofType:@"bundle"];
  STAssertNotNil(bundle, @"the bundle should be there.. ;(");

  NSArray *localization = [[NSBundle bundleWithPath:bundle] localizations];
  STAssertNil(localization, @"bundle localization can't be nil");
  
}

@end
