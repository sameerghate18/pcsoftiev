//
//  AppDelegate.h
//  PCSOFT-IEV
//
//  Created by Sameer Ghate on 31/10/15.
//  Copyright © 2015 Sameer Ghate. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PCCompanyModel.h"
#import "PCUserModel.h"
#import "MKDSlideViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) PCUserModel *loggedUser;
@property (strong, nonatomic) PCCompanyModel *selectedCompany;
@property (strong, nonatomic) NSString *selectedUserName, *selectedCompanyName, *baseURL, *userPhoneNumber, *accessCode;
@property (nonatomic) BOOL userLoggedIn;
@property (strong, nonatomic) NSString *appUniqueIdentifier;

@property (nonatomic, strong) MKDSlideViewController * slideViewController;

- (void)logoutAndBringToLoginPage;
- (void)instantiateAppFlowWithNavController:(UINavigationController *)rootNav;

@end

