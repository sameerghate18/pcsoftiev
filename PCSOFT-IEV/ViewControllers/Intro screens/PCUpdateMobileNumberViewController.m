//
//  PCUpdateMobileNumberViewController.m
//  ERPMobile
//
//  Created by Sameer Ghate on 29/10/15.
//  Copyright © 2015 Sameer Ghate. All rights reserved.
//

#import "PCUpdateMobileNumberViewController.h"
#import "ConnectionHandler.h"
#import "SVProgressHUD.h"
#import "AppDelegate.h"
#import "PrefixHeader.pch"

@interface PCUpdateMobileNumberViewController () <ConnectionHandlerDelegate>

@property (nonatomic, weak) IBOutlet UITextField *phoneNumberTF;

@property (nonatomic, strong) NSString *updatedMobileNumber;

@end

@implementation PCUpdateMobileNumberViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.phoneNumberTF.text = self.phoneNumber;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)cancel:(id)sender    {
    [SVProgressHUD dismiss];
    if ([self.delegate respondsToSelector:@selector(didCancelUpdatingNumber)]) {
        [self.delegate didCancelUpdatingNumber];
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(IBAction)updateMobileNumberToServer   {
    
    AppDelegate *appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    NSString *phoneNumber = _phoneNumberTF.text;
    phoneNumber = [phoneNumber stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    [self setUpdatedMobileNumber:phoneNumber];
    
    if (phoneNumber.length==0) {
        [SVProgressHUD dismiss];
        UIAlertView *blankAccessCode = [[UIAlertView alloc] initWithTitle:@"IEV" message:@"You need to provide your 10-digit phone number to register." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [blankAccessCode show];
        return;
    }
    
    [SVProgressHUD showWithStatus:@"Updating..."];
    
    ConnectionHandler *updateMobileHandler = [[ConnectionHandler alloc] init];
    updateMobileHandler.delegate = self;
    updateMobileHandler.tag = kUpdateMobileNumberTag;
    
    NSString *urlString = [NSString stringWithFormat:@"%@updatemobileno?scocd=%@&deviceid=%@&mobno=%@",
                           kAppBaseURL,
                           _accessCode,
                           appDel.appUniqueIdentifier,
                           phoneNumber];
    
    [updateMobileHandler fetchDataForURL:urlString body:nil];
}

-(void)connectionHandler:(ConnectionHandler*)conHandler didRecieveData:(NSData*)data
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSString *opString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        opString = [opString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if ([opString isEqualToString:@"true"]) {
            
            [SVProgressHUD showSuccessWithStatus:@"Done"];
            
            if ([self.phoneNumber isEqualToString:self.updatedMobileNumber]) {
                if ([self.delegate respondsToSelector:@selector(mobileNumberRemainUnchanged)]) {
                    [self.delegate mobileNumberRemainUnchanged];
                }
            }
            else {
                if ([self.delegate respondsToSelector:@selector(didUpdateMobileNumber:)]) {
                    [self.delegate didUpdateMobileNumber:self.updatedMobileNumber];
                }
            }
            [self dismissViewControllerAnimated:YES completion:NULL];
        }
        else {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Update Mobile number" message:@"Some unexpected error has occured. Please try again after sometime." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            
        }
    });
}

-(void)connectionHandler:(ConnectionHandler*)conHandler errorRecievingData:(NSError*)error
{
    if ([error code] == -5000) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [SVProgressHUD dismiss];
            
            UIAlertView *noInternetalert = [[UIAlertView alloc] initWithTitle:@"IEV" message:@"Internet connection appears to be unavailable.\nPlease check your connection and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [noInternetalert show];
            
        });
        return;
    }
}
@end
