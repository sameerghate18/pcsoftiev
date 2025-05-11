//
//  PCURLViewController.m
//  PCSOFT-IEV
//
//  Created by Harsha Jain on 02/07/22.
//  Copyright © 2022 Sameer Ghate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PCURLViewController.h"
#import "SVProgressHUD.h"
#import "ConnectionHandler.h"
#import "PCViewController.h"

#ifdef DEBUG
#   define NSLog(...) NSLog(__VA_ARGS__)
#else
#   define NSLog(...)
#endif

@interface PCURLViewController()

{
    AppDelegate *appDel;
    NSMutableArray *usersList;
    NSString *companyURL;
}

@end

@implementation PCURLViewController

-(void)viewDidLoad {
    
    appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc]
                                      initWithTarget:self action:@selector(handleSingleTap:)];
    tapper.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapper];
    
}

-(void)viewWillAppear:(BOOL)animated {
    
}

- (void)handleSingleTap:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
}

-(IBAction)verifyURLInput {
    
    NSString *urlText = _urlTextfield.text;
    urlText = [urlText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (urlText.length > 0) {
        // Check for URL regex
        if ([self validateURL:urlText] == true) {
            
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IS_REGISTRATION_COMPLETE_KEY];
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:urlText forKey:kCompanyBaseURL];
            [defaults synchronize];
            [appDel setBaseURL:urlText];
            
            companyURL = [[NSString alloc] initWithString:urlText];
            
            [self performSelector:@selector(getUsernamesList) withObject:nil afterDelay:1.0];
            
        } else {
            //
            [Utility showAlertWithTitle:@"Invalid URL" message:@"Please paste a valid URL in the text box. Please make sure the URL ends with '/'." buttonTitle:@"OK" inViewController:self];
            
        }
    } else {
        
        [Utility showAlertWithTitle:@"Empty field" message:@"Please paste the URL in the text box. Please make sure the URL ends with '/'." buttonTitle:@"OK" inViewController:self];
        
    }
}

-(BOOL)validateURL:(NSString*)urlText {
    
    // [A-Za-z]+://([A-Za-z0-9]+(\.[A-Za-z0-9]+)+):[0-9]+/[A-Za-z0-9]+\.[A-Za-z0-9]+/
    
//    NSString *urlRegEx = @"[A-Za-z]+://([A-Za-z0-9])[:0-9]+/[A-Za-z0-9]+\\.[A-Za-z0-9]+/";
//    NSString *urlRegEx = @"([0-9]+)";
    
//    NSString *urlRegEx =
//        @"(http|https|ftp)://((\\w)*|([0-9]*)|([-|_])*)+[\\:|[0-9]*]+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+/";
//        NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
//        return [urlTest evaluateWithObject:urlText];
    return true;
}

- (void)getUsernamesList
{
    [SVProgressHUD showWithStatus:@"Please wait..."];
    ConnectionHandler *fetchUsers = [[ConnectionHandler alloc] init];
    fetchUsers.delegate = self;
    fetchUsers.tag = kGetUserNamesListTag;
    
    NSString *url = [NSString stringWithFormat:@"%@/%@",companyURL,kUsernamesService];
    
    NSDictionary *postDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              appDel.selectedCompany.CO_CD, kScoCodeKey,
                              nil];
    
    [fetchUsers fetchDataForURL:[NSString stringWithFormat:@"%@/iev/GetUser",companyURL] body:postDict];
}

-(void)connectionHandler:(ConnectionHandler*)conHandler didRecieveData:(NSData*)data
{
    switch (conHandler.tag) {
        case kGetUserNamesListTag:
        {
            if (!usersList) {
                usersList = [[NSMutableArray alloc] init];
            }
            
            NSError *error = nil;
            NSArray *arr = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            
            for (NSDictionary *dict in arr) {
                
                PCUserModel *uMod = [[PCUserModel alloc] init];
                [uMod setValuesForKeysWithDictionary:dict];
                [usersList addObject:uMod];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showSuccessWithStatus:@"Done"];
                
                PCViewController *compListVC = [kStoryboard instantiateViewControllerWithIdentifier:@"PCViewController"];
                [compListVC setTitle:@"Select your company"];
                
                [self.navigationController pushViewController:compListVC animated:NO];
            });
        }
            break;
    }
}
@end
