//
//  PCAccessCodeViewController.m
//  ERPMobile
//
//  Created by Sameer Ghate on 16/09/14.
//  Copyright (c) 2014 Sameer Ghate. All rights reserved.
//

#import "PCAccessCodeViewController.h"
#import "SVProgressHUD.h"
#import "ConnectionHandler.h"
#import "PCUserLoginViewController.h"
#import "PCViewController.h"
#import "AppDelegate.h"
#import "PCDeviceLicenseModel.h"
#import "PCDeviceRegisterModel.h"
#import "PCDemoViewController.h"
#import "PCDeviceRegisterCheckModel.h"
#import "PCUpdateMobileNumberViewController.h"

#ifdef DEBUG
#   define NSLog(...) NSLog(__VA_ARGS__)
#else
#   define NSLog(...)
#endif

typedef enum{
    SetupConnectionTypeDeviceRegister,
    SetupConnectionTypeUpdateLicense,
    SetupConnectionTypeCheckDevice
}SetupConnectionType;

@interface PCAccessCodeViewController () <UITextFieldDelegate, ConnectionHandlerDelegate,PCUpdateMobileNumberViewControllerDelegate>

{
    NSMutableArray *usersList;
    NSString *companyURL;
    SetupConnectionType setupConnectionType;
    AppDelegate *appDel;
    PCDeviceLicenseModel *licenseModel;
    PCDeviceRegisterModel *deviceRegisterModel;
}

@property (nonatomic, weak) IBOutlet UITextField *phoneNumberTF; //*codeTF
@property (nonatomic, weak) IBOutlet UIImageView *logoImageview;
@property (nonatomic, weak) IBOutlet UILabel *headerLabel;
@property (nonatomic, strong) NSString *userPhoneNumber;
@property (nonatomic, strong) IBOutlet UITextField *urlTextfield;

@end

@implementation PCAccessCodeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)animate {
    
    [UIView animateWithDuration:1.0 animations:^{
//        CGRect rect = _logoImageview.frame;
//        [_logoImageview setFrame:CGRectMake(rect.origin.x, rect.origin.y - 100, rect.size.width, rect.size.height)];
//        [_logoImageview setAlpha:1.0];
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:1.0 animations:^{
            [self->_urlTextfield setAlpha:1.0];
            [self->_phoneNumberTF setAlpha:1.0];
        }];
        
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigate_strip.png"] forBarMetrics:UIBarMetricsDefault];
//    
//    self.navigationController.view.backgroundColor =
//    [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg-568h@2x.png"]];
//    
//    self.navigationItem.title = @"Provide your access code";
//    
    appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc]
                                      initWithTarget:self action:@selector(handleSingleTap:)];
    tapper.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapper];
    
    
//    [self animate];
}

- (void)handleSingleTap:(UITapGestureRecognizer *)sender
{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startDemo:(id)sender
{
    
    CGSize result = [[UIScreen mainScreen] bounds].size;
    if(result.height == 480)
    {
        // iPhone Classic
        UINavigationController *navFor4 = [kStoryboard instantiateViewControllerWithIdentifier:@"DemoRootNavigation"];
        [self presentViewController:navFor4 animated:YES completion:NULL];
    }
    if(result.height >= 568)
    {
        UINavigationController *navFor4 = [kStoryboard instantiateViewControllerWithIdentifier:@"DemoRootNavigation-4"];
        [self presentViewController:navFor4 animated:YES completion:NULL];
    }
}

-(IBAction)verifyURLInput {
    
    // test url - https://www.ievmobile.com/https/service.svc/
    NSString *urlText = _urlTextfield.text;
    urlText = [urlText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (urlText.length > 0 && _phoneNumberTF.text.length > 0) {
        // Check for URL regex
        if ([self validateURL:urlText] == true) {
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:urlText forKey:kCompanyBaseURL];
            [defaults synchronize];
            [appDel setBaseURL:urlText];
            
            [self checkForIsDeviceAlreadyRegistered];
            
        } else {
            //
            [Utility showAlertWithTitle:@"Invalid URL" message:@"Please paste a valid URL in the text box. Please make sure the URL ends with '/'." buttonTitle:@"OK" inViewController:self];
        }
    } else {
        [Utility showAlertWithTitle:@"Empty fields" message:@"Please paste or enter the URL ending with '/' and provide your mobile number to use the app." buttonTitle:@"OK" inViewController:self];
    }
}

-(BOOL)validateURL:(NSString*)urlText {
    NSString *urlRegEx =
        @"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+/";
        NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
        return [urlTest evaluateWithObject:urlText];
}

//- (IBAction)registerButtonAction:(id)sender
//{
//    [self checkForIsDeviceAlreadyRegistered];
//}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
//    if (textField == _codeTF) {
//        [_phoneNumberTF becomeFirstResponder];
//        return NO;
//    }
//    
//    [textField resignFirstResponder];
//    [self checkForIsDeviceAlreadyRegistered];
    return YES;
}

- (void)checkForIsDeviceAlreadyRegistered
{
    [self resignFirstResponder];
    
    [SVProgressHUD showWithStatus:@"Please wait..."];
    
    NSString *accessCode = @"IE"; //_codeTF.text;
    
    NSString *phoneNumber = _phoneNumberTF.text;
    phoneNumber = [phoneNumber stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (accessCode.length == 0 || phoneNumber.length==0) {
        [SVProgressHUD dismiss];
        
        [Utility showAlertWithTitle:@"IEV" message:@"Please paste or enter the URL ending with '/' and provide your mobile number to use the app." buttonTitle:@"OK" inViewController:self];

        return;
    }
    
    [self setUserPhoneNumber:phoneNumber];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:self.userPhoneNumber forKey:kPhoneNumber];
    [defaults setValue:accessCode forKey:kAccessCode];
    [defaults synchronize];
    
    ConnectionHandler *registerDeviceConnection = [[ConnectionHandler alloc] init];
    registerDeviceConnection.delegate = self;
    registerDeviceConnection.tag = kCheckDeviceRegisteredTag;
    
    NSString *urlString = [NSString stringWithFormat:@"%@isregisterDevice?scocd=IE&DeviceId=%@&MobNo=%@",
                           appDel.baseURL,
                           appDel.appUniqueIdentifier,
                           self.userPhoneNumber];

    setupConnectionType = SetupConnectionTypeCheckDevice;
    
    [registerDeviceConnection fetchDataForURL:urlString body:nil];
}

-(void)updateMobileNumberToServer   {
    
    ConnectionHandler *updateMobileHandler = [[ConnectionHandler alloc] init];
    updateMobileHandler.delegate = self;
    updateMobileHandler.tag = kUpdateMobileNumberTag;
        
    NSString *urlString = [NSString stringWithFormat:@"%@updatemobileno?scocd=IE&deviceid=%@&mobno=%@",
                           appDel.baseURL,
                           appDel.appUniqueIdentifier,
                           self.userPhoneNumber];
    
    setupConnectionType = SetupConnectionTypeCheckDevice;
    
    [updateMobileHandler fetchDataForURL:urlString body:nil];
}

-(void)updateDeviceRegistration {
    
    ConnectionHandler *updateDevieRegHandler = [[ConnectionHandler alloc] init];
    updateDevieRegHandler.delegate = self;
    updateDevieRegHandler.tag = kUpdateDeviceRegisterTag;
    
    NSString *urlString = [NSString stringWithFormat:@"%@updatedeviceid?scocd=IE&deviceid=%@&mobno=%@&token=%@&tokentype=I",
                           appDel.baseURL,
                           appDel.appUniqueIdentifier,
                           self.userPhoneNumber,
                           appDel.fcmToken];
    
    [updateDevieRegHandler fetchDataForURL:urlString body:nil];
    
}

-(void)updateLicenseCount
{
    NSString *accessCode = @"IE"; //_codeTF.text;
    
    accessCode = [accessCode stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSString *phoneNumber = _phoneNumberTF.text;
    phoneNumber = [phoneNumber stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (accessCode.length == 0 || phoneNumber.length==0) {
        [SVProgressHUD dismiss];
        
        [Utility showAlertWithTitle:@"IEV" message:@"You need to provide the access code and your 10-digit phone number to use the application." buttonTitle:@"OK" inViewController:self];

        return;
    }
    
    [self setUserPhoneNumber:phoneNumber];
    
    ConnectionHandler *registerDeviceConnection = [[ConnectionHandler alloc] init];
    registerDeviceConnection.delegate = self;
    registerDeviceConnection.tag = kUpdateLicenseTag;
    
    NSString *urlString = [NSString stringWithFormat:@"%@GetUpdateLic?scocd=IE",appDel.baseURL];
    setupConnectionType = SetupConnectionTypeUpdateLicense;
    
    [registerDeviceConnection fetchDataForURL:urlString body:nil];
}

- (void)registerDeviceN {
    
    [SVProgressHUD showWithStatus:@"Registering device..."];

    ConnectionHandler *registerDeviceConnection = [[ConnectionHandler alloc] init];
    registerDeviceConnection.delegate = self;
    registerDeviceConnection.tag = kRegisterDeviceTag;
    
    NSString *urlString = [NSString stringWithFormat:@"%@registerDeviceN?scocd=IE&DeviceId=%@&MobNo=%@&token=%@&tokentype=I",
                           appDel.baseURL,
                           appDel.appUniqueIdentifier,
                           self.userPhoneNumber,
                           appDel.fcmToken];
    
    setupConnectionType = SetupConnectionTypeDeviceRegister;
    
    [registerDeviceConnection fetchDataForURL:urlString body:nil];
    
}

- (void)registerDevice {
    [SVProgressHUD showWithStatus:@"Registering device..."];
    
    NSString *accessCode = @"IE"; //[NSString stringWithString:
                            //_codeTF.text];
    
    accessCode = [accessCode stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSString *phoneNumber = [NSString stringWithString:_phoneNumberTF.text];
    phoneNumber = [phoneNumber stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (accessCode.length == 0 || phoneNumber.length==0) {
        [SVProgressHUD dismiss];
        
        [Utility showAlertWithTitle:@"IEV" message:@"You need to provide the access code and your 10-digit phone number to use the application." buttonTitle:@"OK" inViewController:self];
        
        return;
    }
    
    ConnectionHandler *registerDeviceConnection = [[ConnectionHandler alloc] init];
    registerDeviceConnection.delegate = self;
    registerDeviceConnection.tag = kRegisterDeviceTag;
    
    NSString *urlString = [NSString stringWithFormat:@"%@registerDeviceID?scocd=%@&DeviceId=%@&MobNo=%@",
                           appDel.baseURL,
                           accessCode,
                           appDel.appUniqueIdentifier,
                           phoneNumber];
    
    setupConnectionType = SetupConnectionTypeDeviceRegister;
    
    [registerDeviceConnection fetchDataForURL:urlString body:nil];
}

-(void)verifyCode:(NSString*)userCode
{
    NSString *accessCode = @"IE"; //_codeTF.text;
    
    accessCode = [accessCode stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSString *phoneNumber = _phoneNumberTF.text;
    phoneNumber = [phoneNumber stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (accessCode.length == 0 || phoneNumber.length==0) {
        [SVProgressHUD dismiss];
        
        [Utility showAlertWithTitle:@"IEV" message:@"You need to provide the access code and your 10-digit phone number to use the application." buttonTitle:@"OK" inViewController:self];

        return;
    }
    
    [SVProgressHUD showWithStatus:@"Verifying"];
    ConnectionHandler *verifyCode = [[ConnectionHandler alloc] init];
    verifyCode.delegate = self;
    verifyCode.tag = kGetServiceURLTag;
    
//    NSString *urlString = [NSString stringWithFormat:@"%@%@",kVerifyCodeURL,accessCode];
//    setupConnectionType = SetupConnectionTypeUpdateLicense;
//    [verifyCode fetchDataForURL:urlString body:nil];
}

- (void)getUsernamesList
{
    [SVProgressHUD showWithStatus:@"Please wait..."];
    ConnectionHandler *fetchUsers = [[ConnectionHandler alloc] init];
    fetchUsers.delegate = self;
    fetchUsers.tag = kGetUserNamesListTag;
    
    NSString *url = [NSString stringWithFormat:@"%@/%@",companyURL,kUsernamesService];
    
    [fetchUsers fetchDataForURL:url body:nil];
}

-(void)connectionHandler:(ConnectionHandler*)conHandler didRecieveData:(NSData*)data
{
    switch (conHandler.tag) {

        case kCheckDeviceRegisteredTag:
        {
            NSError *error = nil;
            NSArray *opArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            
            if (!error) {
                
                if (opArray.count > 0) {
                    
                    NSDictionary *dict = [opArray objectAtIndex:0];
                    
                    PCDeviceRegisterCheckModel *model = [[PCDeviceRegisterCheckModel alloc] init];
                    [model setValuesForKeysWithDictionary:dict];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        if ([model.IsDeviceRegistered isEqualToString:@"YES"] && [model.IsMobileRegistered isEqualToString:@"YES"]) {
                            
                            if ([model.IsActive isEqualToString:@"A"]) {
                                // registered and active.
                                
                                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IS_REGISTRATION_COMPLETE_KEY];
                                [[NSUserDefaults standardUserDefaults] synchronize];
                                
//                                [SVProgressHUD showSuccessWithStatus:@"Done"];
                                
                                PCViewController *compListVC = [kStoryboard instantiateViewControllerWithIdentifier:@"PCViewController"];
                                [compListVC setTitle:@"Select your company"];
                                
                                [self.navigationController pushViewController:compListVC animated:NO];
//                                [self verifyCode:nil];
                                
                            }
                            else {
                                // registered but not active.
                                
                                NSMutableDictionary* details = [NSMutableDictionary dictionary];
                                [details setValue:@"Your limited use of IEV services for this device has ended.\nPlease contact PCSOFT ERP Solutions for enabling IEV services." forKey: NSLocalizedDescriptionKey];
                                NSError *error_device = [NSError errorWithDomain:kErrorDomainDeviceErrors code:-5002 userInfo:details];
                                
                                [self connectionHandler:nil errorRecievingData:error_device];
                            }
                        }
                        else if ([model.IsDeviceRegistered isEqualToString:@"YES"] && [model.IsMobileRegistered isEqualToString:@"NO"]) {
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                
                                UIAlertController *registerMobileAlert = [UIAlertController alertControllerWithTitle:@"IEV" message:@"Your mobile number is not registered. Please select 'Continue' to register." preferredStyle:UIAlertControllerStyleAlert];
                                
                                UIAlertAction *contAction = [UIAlertAction actionWithTitle:@"Continue" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                    
                                    [self navigateToUpdateMobileNumberViewController];
                                }];
                                
                                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:nil];
                                
                                [registerMobileAlert addAction:contAction];
                                [registerMobileAlert addAction:cancelAction];
                                
                                [self presentViewController:registerMobileAlert animated:YES completion:nil];
                            });
                            
                        }
                        else if ([model.IsDeviceRegistered isEqualToString:@"NO"] && [model.IsMobileRegistered isEqualToString:@"YES"]) {
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                
                                UIAlertController *registerDeviceAlert = [UIAlertController alertControllerWithTitle:@"IEV" message:@"You have not registered your device. Please select 'Continue' to register." preferredStyle:UIAlertControllerStyleAlert];
                                
                                UIAlertAction *contAction = [UIAlertAction actionWithTitle:@"Continue" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                    
                                    [self updateDeviceRegistration];
                                }];
                                
                                [registerDeviceAlert addAction:contAction];
                                
                                [self presentViewController:registerDeviceAlert animated:YES completion:nil];
                            });
                            
                        }
                        else {
                            // device not registered. Proceed with device registration.
//                            [self updateLicenseCount];
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self registerDeviceN];
                            });
                        }
                        
                        
                    });
                    
                }
            }
            else {
                NSMutableDictionary* details = [NSMutableDictionary dictionary];
                [details setValue:@"There seems some problem connecting with the server.\nPlease try again after some time." forKey: NSLocalizedDescriptionKey];
                
                NSError *error = [NSError errorWithDomain:kErrorDomainUnwantedOutput code:-5001 userInfo:details];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self connectionHandler:nil errorRecievingData:error];
                });

            }
        }
            break;
            
        case kUpdateLicenseTag:
        {
            NSError *error = nil;
            NSArray *arr = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            
            if (arr.count > 0) {
                NSDictionary *dict = [arr objectAtIndex:0];
                licenseModel = [[PCDeviceLicenseModel alloc] init];
                [licenseModel setValuesForKeysWithDictionary:dict];
            }
            else {
                
            }
            // TODO : 100 needs to be replaced with a definite number.
            int totalLicenses = licenseModel.LIC_NOS==nil?100:[licenseModel.LIC_NOS intValue];
            int usedLicenses = [licenseModel.LIC_USED intValue];
            if (usedLicenses < totalLicenses) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self registerDeviceN];
                });
                
            }
            else {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [SVProgressHUD dismiss];
                    
                    [Utility showAlertWithTitle:@"IEV" message:@"Available licenses for are already used.\nPlease contact your license adminstrator for getting access to the IEV app.\nMeanwhile, you can take a demo tour of the features." buttonTitle:@"OK" inViewController:self];

                });
                
                return;
            }
        }
            
            break;
            
        case kRegisterDeviceTag:
        {
            NSError *error = nil;
            NSArray *arr = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            
            if (arr.count > 0) {
                NSDictionary *dict = [arr objectAtIndex:0];
                deviceRegisterModel = [[PCDeviceRegisterModel alloc] init];
                [deviceRegisterModel setValuesForKeysWithDictionary:dict];
                
                NSString *activeString = [deviceRegisterModel.ACTIVE stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                
                if ([activeString isEqualToString:@"A"]) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [SVProgressHUD showSuccessWithStatus:@"Done"];
                        
                        PCViewController *compListVC = [kStoryboard instantiateViewControllerWithIdentifier:@"PCViewController"];
                        [compListVC setTitle:@"Select your company"];
                        
                        [self.navigationController pushViewController:compListVC animated:NO];
                    });
                    
//                    [self verifyCode:nil];
                }
                else {
                    
                    NSMutableDictionary* details = [NSMutableDictionary dictionary];
                    [details setValue:@"Your limited use of IEV services for this device has ended.\nPlease contact PCSOFT ERP Solutions for enabling IEV services." forKey: NSLocalizedDescriptionKey];
                    NSError *error_device = [NSError errorWithDomain:kErrorDomainDeviceErrors code:-5002 userInfo:details];
                    
                    [self connectionHandler:nil errorRecievingData:error_device];
                }
            }
            else {
                NSMutableDictionary* details = [NSMutableDictionary dictionary];
                [details setValue:@"Device registration failed.\nPlease try again." forKey: NSLocalizedDescriptionKey];
                NSError *error_blank = [NSError errorWithDomain:kErrorDomainBlankOutput code:-5003 userInfo:details];
                
                [self connectionHandler:nil errorRecievingData:error_blank];
            }
            
        }
            break;
            
        case kGetServiceURLTag:
        {
            NSError *error = nil;
            NSArray *arr;
            __block NSString *errorString;
            
            id output = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            
            if ([output isKindOfClass:[NSArray class]]) {
                arr = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
                
                if (arr.count > 0) {
                    
                    NSDictionary *dict = [arr objectAtIndex:0];
                    
                    companyURL = [[NSString alloc] initWithString:[dict valueForKey:@"WEB_URL"]];
                    
                }
                else {
                    
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if (companyURL) {
                        
                        // License code goes here.
                        
                        
                        [SVProgressHUD showSuccessWithStatus:@"Verified"];
                        
                        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IS_REGISTRATION_COMPLETE_KEY];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                        [defaults setObject:companyURL forKey:kCompanyBaseURL];
                        [defaults synchronize];
                        [self->appDel setBaseURL:companyURL];
                        
                        [self performSelector:@selector(getUsernamesList) withObject:nil afterDelay:1.0];
                        
                    }
                    else {
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            [SVProgressHUD dismiss];
                            
                            [Utility showAlertWithTitle:@"Invalid code" message:@"Wrong access code provided. Please try again." buttonTitle:@"OK" inViewController:self];
                            
                        });
                        
                        
                    }
                    
                });
                
            }
            else if ([output isKindOfClass:[NSString class]])   {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [SVProgressHUD dismiss];
                    errorString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    errorString = [errorString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    errorString = [errorString substringWithRange:NSMakeRange(1, errorString.length-2)];
                    errorString = [errorString capitalizedString];
                    
                    if ([errorString  caseInsensitiveCompare:@"IEV C001"] == NSOrderedSame) {
                        
                        [SVProgressHUD dismiss];
                        
                        [Utility showAlertWithTitle:@"Register" message:@"Unable to connect to PCSOFT services.\nPlease try again." buttonTitle:@"OK" inViewController:self];

                    }
                    else if ([errorString  caseInsensitiveCompare:@"IEV C002"] == NSOrderedSame)   {
                        
                        [Utility showAlertWithTitle:@"Register" message:@"Invalid company code provided.\nPlease try again." buttonTitle:@"OK" inViewController:self];

                    }
                });
                return;
            }
            
        }
            
            break;
            
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
            
        case kUpdateDeviceRegisterTag:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSString *opString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                opString = [opString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                
                if ([opString isEqualToString:@"true"]) {
                    [SVProgressHUD dismiss];
                    
                    UIAlertController *deviceSuccessVC = [UIAlertController alertControllerWithTitle:@"Registration" message:@"Device registered succesfully." preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction * okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

                        PCViewController *compListVC = [kStoryboard instantiateViewControllerWithIdentifier:@"PCViewController"];
                        [compListVC setTitle:@"Select your company"];
                        
                        [self.navigationController pushViewController:compListVC animated:NO];
                    }];
                    
                    [deviceSuccessVC addAction:okAction];
                    
                    [self presentViewController:deviceSuccessVC animated:YES completion:nil];
                    
                    //                    UIAlertView *deviceSuccess = [[UIAlertView alloc] initWithTitle:@"Registration" message:@"Device registered succesfully." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    //                    deviceSuccess.tag = 104;
                    //                    [deviceSuccess show];
                    
                } else {
                    
                    [Utility showAlertWithTitle:@"Registration" message:@"Some unexpected error has occured, could not register the device." buttonTitle:@"OK" inViewController:self];

                }
                
            });
        }
            
        default:
            break;
    }
    
}


-(void)connectionHandler:(ConnectionHandler*)conHandler errorRecievingData:(NSError*)error
{
    if ([error code] == -5000) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [SVProgressHUD dismiss];
            
            [Utility showAlertWithTitle:@"IEV" message:noInternetMessage buttonTitle:@"OK" inViewController:self];
            
        });
        return;
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [SVProgressHUD dismiss];
            
            [Utility showAlertWithTitle:@"IEV" message:[error localizedDescription] buttonTitle:@"OK" inViewController:self];
            
        });
        return;
    }
    
    /*
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [SVProgressHUD dismiss];
        
        switch (conHandler.tag) {
                
            case kCheckDeviceRegisteredTag:
            {
                
            }
                break;
                
            case kUpdateLicenseTag:
            {
                
            }
                
                break;
                
            case kRegisterDeviceTag:
            {
                
            }
                break;
                
            case kGetServiceURLTag:
            {
                
            }
                
                break;
                
            case kGetUserNamesListTag:
            {
                
            }
                break;
                
            default:
                break;
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"IEV" message:@"Some unexpected error has occured. Please try again after sometime." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
    });
     */
}

- (void)navigateToUpdateMobileNumberViewController {
    PCUpdateMobileNumberViewController *updateMobVC = [kStoryboard instantiateViewControllerWithIdentifier:@"PCUpdateMobileNumberViewController"];
    
    NSString *accessCode = @"IE"; //[NSString stringWithString:
    //_codeTF.text];
    
    accessCode = [accessCode stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    updateMobVC.accessCode = accessCode;
    
    NSString *phoneNumber = _phoneNumberTF.text;
    phoneNumber = [phoneNumber stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    updateMobVC.phoneNumber = phoneNumber;
    
    updateMobVC.delegate = self;
    
    [self presentViewController:updateMobVC animated:YES completion:NULL];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [SVProgressHUD dismiss];
    
    switch (alertView.tag) {
        case 100:
            if (buttonIndex == 0) {
                [self startDemo:nil];
            }
            break;
            
        case 101:
            if (buttonIndex == 0) {
                
            }
            else if (buttonIndex == 1) {
                
            }
            break;
            
        case 102: // Require mobile no. update alert
            if (buttonIndex == 0) {
                
                [self navigateToUpdateMobileNumberViewController];
                
            }
            else if (buttonIndex == 1) {
                
            }
            break;
            
        case 103: // Require device update alert
            if (buttonIndex == 0) {
                
                [self updateDeviceRegistration];
            }
            else if (buttonIndex == 1) {
                
            }
            break;
            
        case 104: // Device update success alert
            if (buttonIndex == 0) {
                
                PCViewController *compListVC = [kStoryboard instantiateViewControllerWithIdentifier:@"PCViewController"];
                [compListVC setTitle:@"Select your company"];
                
                [self.navigationController pushViewController:compListVC animated:NO];
            }
            else if (buttonIndex == 1) {
                
            }
            break;
            
        default:
            break;
    }
}

-(void)didUpdateMobileNumber:(NSString*)newNumber   {
    
    [self setUserPhoneNumber:newNumber];
    self.phoneNumberTF.text = self.userPhoneNumber;
}

-(void)didCancelUpdatingNumber  {
    
}

-(void)mobileNumberRemainUnchanged  {
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
