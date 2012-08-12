//
//  ViewController.m
//  Bundle Localizations
//
//  Created by Jesse Collis on 31/07/12.
//  Copyright (c) 2012 JCMultimedia Design. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize bundleNameLabel;
@synthesize helloWorldLabel;
@synthesize nextButton;

- (id)initWithCoder:(NSCoder *)aDecoder
{
  if ((self = [super initWithCoder:aDecoder]))
  {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(activeLocalizationChanged)
                                                 name:kJCLocalisedStringActivteLocalizationChangedNotification
                                               object:nil];
  }
  return self;
}

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  [self setLabels];
}

- (void)setLabels
{
  self.helloWorldLabel.text = JCLocalizedStringFromTable(@"hello-world", @"ViewController", @"Hello World Title String");
  self.bundleNameLabel.text = [[JCLocalizedManager sharedManager] activeLocalization];

  self.nextButton.titleLabel.text = JCLocalizedStringFromTable(@"non-localized", @"ViewController", @"Unlocalized string to test errors");
  
  //NSLog(@"No Comment: %@", JCLocalizedString(@"No Comment or table", @""));
}

- (void)activeLocalizationChanged
{
  NSLog(@"active localization changed. ripping out the view.");
  if (self.navigationController.topViewController != self && [self isViewLoaded])
  {
    [self.view removeFromSuperview];
    self.view = nil; //needed?
  }
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

@end
