//
//  PCSettingsViewController.m
//  PCSOFT-IEV
//
//  Created by Sameer Ghate on 14/12/15.
//  Copyright © 2015 Sameer Ghate. All rights reserved.
//

#import "PCSettingsViewController.h"
@import UserNotifications;

@interface PCSettingsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *settingsTableview;

@end

@implementation PCSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.settingsTableview registerClass:[UITableViewCell class] forCellReuseIdentifier:@"SwitchCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)showSideMenu:(id)sender  {

    AppDelegate *appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    [appDel.slideViewController showLeftViewControllerAnimated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 1;
            break;
            
        case 1:
            return 1;
            break;
            
        default:
            return 0;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath  {
    
    UITableViewCell* aCell;
    switch (indexPath.section) {
        case 0:
        {
            if (aCell==nil) {
                aCell = [tableView dequeueReusableCellWithIdentifier:@"SwitchCell"];
                aCell.textLabel.text = @"Ask for credentials";
                aCell.textLabel.font = [UIFont boldSystemFontOfSize:15];
                aCell.selectionStyle = UITableViewCellSelectionStyleNone;
                aCell.backgroundColor = [UIColor clearColor];
                UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
                aCell.accessoryView = switchView;
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                if ([defaults boolForKey:kPaymentAuthPwdEnabled]) {
                    [switchView setOn:YES animated:NO];
                }
                else {
                    [switchView setOn:NO animated:NO];
                }
                
                [switchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
            }
        }
            break;
            
        case 1:
        {
            if (aCell==nil) {
                aCell = [tableView dequeueReusableCellWithIdentifier:@"SwitchCell"];
                aCell.textLabel.text = @"Push notifications";
                aCell.textLabel.font = [UIFont boldSystemFontOfSize:15];
                aCell.selectionStyle = UITableViewCellSelectionStyleNone;
                aCell.backgroundColor = [UIColor clearColor];
                UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
                aCell.accessoryView = switchView;
                
                [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
                    if ([settings authorizationStatus] == UNAuthorizationStatusNotDetermined || [settings authorizationStatus] == UNAuthorizationStatusDenied) {
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [switchView setOn:NO animated:NO];
                            NSLog(@"requestAuthorizationWithOptions DENIED");
                        });
                        
                    } else {
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [switchView setOn:YES animated:NO];
                            NSLog(@"requestAuthorizationWithOptions PRE-GRANTED");
                        });
                        
                    }
                }];
                
                [switchView addTarget:self action:@selector(notificationSwitchChanged:) forControlEvents:UIControlEventValueChanged];
            }
        }
            
        default:
            break;
    }
    
    return aCell;
}

- (void) switchChanged:(id)sender {
    UISwitch* switchControl = sender;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (switchControl.on) {
        [defaults setBool:YES forKey:kPaymentAuthPwdEnabled];
    }
    else {
        [defaults setBool:NO forKey:kPaymentAuthPwdEnabled];
    }
    [defaults synchronize];
}

- (void) notificationSwitchChanged:(id)sender {
    UISwitch* switchControl = sender;
    
    if (switchControl.on) {
        
        [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:(UNAuthorizationOptionAlert|UNAuthorizationOptionBadge|UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted == true) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [switchControl setOn:TRUE];
                    NSLog(@"push notifications GRANTED");
                });
                
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [switchControl setOn:FALSE];
                    NSLog(@"push notifications DENIED");
                });
            }
        }];
    }
    else {
        [switchControl setOn:FALSE];
        [[UIApplication sharedApplication] unregisterForRemoteNotifications];
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView   {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 75;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section   {
    
    return 0;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section   {
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, tableView.frame.size.width-40, 20)];
    headerLabel.backgroundColor = [UIColor colorNamed:kCustomGray];
    headerLabel.font = [UIFont systemFontOfSize:13];
    headerLabel.textColor = [UIColor colorNamed:kCustomWhite];
    headerLabel.numberOfLines = 1;
    headerLabel.text = @"Payments Authorization";
    headerLabel.textAlignment = NSTextAlignmentLeft;
    
    return nil;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section   {
    
    UILabel *footerLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, tableView.frame.size.width-40, 75)];
    footerLabel.backgroundColor = [UIColor clearColor];
    footerLabel.font = [UIFont systemFontOfSize:12];
    footerLabel.textColor = [UIColor colorNamed:kCustomGray];
    footerLabel.numberOfLines = 3;
    
    if (section == 0) {
        footerLabel.text = @"Turning on this feature will ask the user for login credentials whenever any payment authorization happens. It is recommended to keep this feature enabled.";
    } else if (section == 1) {
        footerLabel.text = @"You can turn on and off the push notifications through the Notifications section of the Settings app.";
    }
    
    footerLabel.textAlignment = NSTextAlignmentCenter;
    
    return footerLabel;
}

@end
