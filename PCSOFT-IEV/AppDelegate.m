//
//  AppDelegate.m
//  PCSOFT-IEV
//
//  Created by Sameer Ghate on 31/10/15.
//  Copyright © 2015 Sameer Ghate. All rights reserved.
//

#import "AppDelegate.h"

#import "PCViewController.h"
#import "PCSideMenuTableViewController.h"
#import "UIViewController+MKDSlideViewController.h"
#import "SSKeychain.h"
@import UserNotifications;
@import FirebaseCore;
@import FirebaseMessaging;

#define kAppIdentiier @"com.pcsofterp.IEV"
#define kAppKeychainIdentifier @"appUniqueCode"

@interface AppDelegate () <UNUserNotificationCenterDelegate>
@end

@implementation AppDelegate

NSString *const kGCMMessageIDKey = @"gcm.message_id";

- (void)instantiateAppFlowWithNavController:(UINavigationController *)rootNav
{
    PCSideMenuTableViewController *pcsvc = [kStoryboard instantiateViewControllerWithIdentifier:@"PCSideMenuTableViewController"];
    
    _slideViewController = [[MKDSlideViewController alloc] initWithMainViewController:rootNav];
    _slideViewController.leftViewController = pcsvc;
    _slideViewController.rightViewController = nil;
    
    self.window.rootViewController = self.slideViewController;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [FIRApp configure];
    
    [FIRMessaging messaging].delegate = self;
    
    [UNUserNotificationCenter currentNotificationCenter].delegate = self;
    
    [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
        if ([settings authorizationStatus] == UNAuthorizationStatusNotDetermined || [settings authorizationStatus] == UNAuthorizationStatusDenied) {
            
            [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:(UNAuthorizationOptionAlert|UNAuthorizationOptionBadge|UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error) {
                if (granted == true) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSLog(@"requestAuthorizationWithOptions GRANTED");
                    });
                    
                } else {
                    NSLog(@"requestAuthorizationWithOptions DENIED");
                }

            }];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"requestAuthorizationWithOptions PRE-GRANTED");
            });
            
        }
    }];
    
    [application registerForRemoteNotifications];
    
    if ([launchOptions objectForKey:UIApplicationLaunchOptionsURLKey] == nil) {
        // Normal launch
    } else {
        // Notification launch
    }
        
    NSString *retrieveuuid = [SSKeychain passwordForService:kAppIdentiier account:kAppKeychainIdentifier];
    if (retrieveuuid == nil) {
        NSString *uuid  = [self createNewUUID];
        
        // save newly created key to Keychain
        [SSKeychain setPassword:uuid forService:kAppIdentiier account:kAppKeychainIdentifier];
        
        retrieveuuid = [uuid copy];
    }
    _appUniqueIdentifier = retrieveuuid;
    
    _loggedUser = [[PCUserModel alloc] init];
    _selectedCompany = [[PCCompanyModel alloc] init];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _baseURL = [defaults valueForKey:kCompanyBaseURL];
    [defaults synchronize];
    
    UINavigationController *rootNav;
    
    BOOL isRegistered = [defaults boolForKey:IS_REGISTRATION_COMPLETE_KEY];
    
    if (isRegistered) {
        _baseURL = [defaults valueForKey:kCompanyBaseURL];
        _selectedCompany.CO_CD = [defaults valueForKey:@"selectedCompanyCode"];
        _selectedCompany.LONG_CO_NM = [defaults valueForKey:@"selectedCompanyLongName"];
        _selectedCompany.NAME = [defaults valueForKey:@"selectedCompanyName"];
        
        [defaults synchronize];
        
        rootNav = [kStoryboard instantiateViewControllerWithIdentifier:@"RootNavControllerForLogin"];
    }
    else {
        
        [defaults setBool:YES forKey:kPaymentAuthPwdEnabled];
        rootNav = [kStoryboard instantiateViewControllerWithIdentifier:@"RootNavController"];
    }
    
    [self instantiateAppFlowWithNavController:rootNav];
    
    return YES;
}

-(void)logoutAndBringToLoginPage
{
    
    UINavigationController *rootNav = [kStoryboard instantiateViewControllerWithIdentifier:@"RootNavControllerForLogin"];
    
    _slideViewController = [[MKDSlideViewController alloc] initWithMainViewController:rootNav];
}

- (NSString *)createNewUUID
{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return (__bridge NSString *)(string);
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    NSLog(@"didRegisterForRemoteNotificationsWithDeviceToken: %@", deviceToken);
    
    // With swizzling disabled you must set the APNs device token here.
    [FIRMessaging messaging].APNSToken = deviceToken;
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"didFailToRegisterForRemoteNotificationsWithError: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    // With swizzling disabled you must let Messaging know about the message, for Analytics
       [[FIRMessaging messaging] appDidReceiveMessage:userInfo];

      // [START_EXCLUDE]
      // Print message ID.
      if (userInfo[kGCMMessageIDKey]) {
        NSLog(@"Message ID: %@", userInfo[kGCMMessageIDKey]);
      }
      // [END_EXCLUDE]

      // Print full message.
      NSLog(@"%@", userInfo);

      completionHandler(UIBackgroundFetchResultNewData);
}

- (void)messaging:(FIRMessaging *)messaging didReceiveRegistrationToken:(NSString *)fcmToken {
    
    NSLog(@"FCM registration token: %@", fcmToken);
        // Notify about received token.
        NSDictionary *dataDict = [NSDictionary dictionaryWithObject:fcmToken forKey:@"token"];
        [[NSNotificationCenter defaultCenter] postNotificationName:
         @"FCMToken" object:nil userInfo:dataDict];
}

@end
