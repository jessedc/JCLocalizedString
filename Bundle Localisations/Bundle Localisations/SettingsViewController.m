//
//  SettingsViewController.m
//  Bundle Localizations
//
//  Created by Jesse Collis on 31/07/12.
//  Copyright (c) 2012 JCMultimedia Design. All rights reserved.
//

#import "SettingsViewController.h"
#import "JCLocalizedString.h"

@interface SettingsViewController ()
@property (nonatomic, strong) NSBundle *bundle;
@end

@implementation SettingsViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
  if ((self = [super initWithCoder:aDecoder]))
  {
    self.bundle = [[JCLocalizedManager sharedManager] localizationBundle];
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSString *localization = [[self.bundle localizations] objectAtIndex:indexPath.row];
  [[JCLocalizedManager sharedManager] setActiveLocalization:localization];
  [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [[self.bundle localizations] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
  if ((nil == cell))
  {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
  }

  NSString *localization = [[self.bundle localizations] objectAtIndex:indexPath.row];

  NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:localization];
  
  cell.textLabel.text = [locale displayNameForKey:NSLocaleIdentifier value:localization];

  if ([localization isEqualToString:[[JCLocalizedManager sharedManager] activeLocalization]])
  {
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
  }
  else
  {
    cell.accessoryType = UITableViewCellAccessoryNone;
  }

  return cell;
}

@end
