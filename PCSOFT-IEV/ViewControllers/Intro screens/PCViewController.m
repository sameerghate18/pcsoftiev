//
//  PCViewController.m
//  ERPMobile
//
//  Created by Sameer Ghate on 09/08/14.
//  Copyright (c) 2014 Sameer Ghate. All rights reserved.
//

#import "PCViewController.h"
#import "MBProgressHUD.h"
#import "SVProgressHUD.h"
#import "ConnectionHandler.h"
#import "PCUserLoginViewController.h"
#import "PCCompanyModel.h"
#import "PCUserModel.h"
#import "AppDelegate.h"
#import "UIViewController+MKDSlideViewController.h"

typedef enum {
    DATA_TYPE_COMPANYLIST,
    DATA_TYPE_USERLIST
}DATA_TYPE;

@interface PCViewController () <NSURLConnectionDelegate, UITableViewDataSource, UITableViewDelegate,ConnectionHandlerDelegate, UISearchBarDelegate>
{
//    UIAlertView *alert;
    NSMutableData *recievedData;
    NSMutableArray *companyList, *filteredCompanyList;
    NSMutableArray *usersList;
    DATA_TYPE dataType;
    NSMutableString *dataTypeURL;
    NSString *selectedCompany;
}

@property (nonatomic, weak) IBOutlet UITableView *companyTableview;

@property (nonatomic, weak) IBOutlet UIButton *backButton;

@property (nonatomic, weak) IBOutlet UIImageView *bgImageView;

@property (nonatomic, weak) IBOutlet UISearchBar *companySearchBar;

@end

@implementation PCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.navigationController.navigationBarHidden = TRUE;
    
    self.navigationItem.hidesBackButton = YES;
//    self.navigationItem.title = @"Select your company";
    
    dataType = DATA_TYPE_COMPANYLIST;
    [self pullData];
}

-(void)viewWillAppear:(BOOL)animated
{    
    BOOL isRegistered = [[NSUserDefaults standardUserDefaults] boolForKey:IS_REGISTRATION_COMPLETE_KEY];
    
    if (isRegistered) {
        _backButton.hidden = TRUE;
    }
    else {
        _backButton.hidden = FALSE;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)pullData
{
    AppDelegate *appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    [SVProgressHUD showWithStatus:@"Please wait" maskType:SVProgressHUDMaskTypeBlack];
    
    NSString *urlString;
    NSDictionary *postDict;
    
    if (dataType == DATA_TYPE_COMPANYLIST) {
        dataTypeURL = [NSMutableString stringWithString:kCompanyListService];
        urlString = [NSString stringWithFormat:@"%@/%@",appDel.baseURL,dataTypeURL];
        
        ConnectionHandler *handler = [[ConnectionHandler alloc] init];
        handler.delegate = self;
        
        [handler fetchDataForURL:urlString body:nil];
    }
    else if (dataType == DATA_TYPE_USERLIST) {
//        urlString = [NSString stringWithFormat:@"%@/%@%@",appDel.baseURL,kUsernamesService,dataTypeURL];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showSuccessWithStatus:@"Done"];
            
            PCUserLoginViewController *uvc = [kStoryboard instantiateViewControllerWithIdentifier:@"PCUserLoginViewController"];
            [uvc setUsersList:self->usersList];
            [uvc setSeletedCompany:self->selectedCompany];
            [self.navigationController pushViewController:uvc animated:NO];
        });
    }
    
//    ConnectionHandler *handler = [[ConnectionHandler alloc] init];
//    handler.delegate = self;
    
    //    NSDictionary *postDict = [[NSDictionary alloc] initWithObjectsAndKeys:
    //                              [defaults valueForKey:kAccessCode], kScoCodeKey,
    //                              appDel.appUniqueIdentifier,"deviceid",
    //                              [defaults valueForKey:kPhoneNumber],"mobno",
    //                              nil];
    
//    [handler fetchDataForURL:urlString body:nil];
}

-(void)connectionHandler:(ConnectionHandler*)conHandler didRecieveData:(NSData*)data
{
    
    if (dataType == DATA_TYPE_COMPANYLIST) {
        
        if (!companyList) {
            companyList = [[NSMutableArray alloc] init];
        }
        
        if (!filteredCompanyList) {
            filteredCompanyList = [[NSMutableArray alloc] init];
        }
        
        [companyList removeAllObjects];
        [filteredCompanyList removeAllObjects];
        
        NSError *error = nil;
        NSArray *arr;
        __block NSString *errorString;
        
        id output = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        
        if ([output isKindOfClass:[NSDictionary class]]) {
            arr = [output objectForKey:kDataKey];
//            arr = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            
            for (NSDictionary *dict in arr) {
                PCCompanyModel *cMod = [[PCCompanyModel alloc] init];
                [cMod setValuesForKeysWithDictionary:dict];
                [companyList addObject:cMod];
            }
            
            NSArray *sortedArray;
            sortedArray = [companyList sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                NSString *first = [(PCCompanyModel*)a NAME];
                NSString *second = [(PCCompanyModel*)b NAME];
                return [first compare:second];
            }];
            
            [companyList removeAllObjects];
            [companyList addObjectsFromArray:[sortedArray copy]];
            [filteredCompanyList addObjectsFromArray:companyList];
            
            if (companyList.count == 0) {
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No companies found." message:@"Could not find list of companies." preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction * retryAction = [UIAlertAction actionWithTitle:@"Retry" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self pullData];
                    });
                }];
                
                UIAlertAction * gobackAction = [UIAlertAction actionWithTitle:@"Go back" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.navigationController popViewControllerAnimated:TRUE];
                    });
                }];
                
                [alert addAction:retryAction];
                [alert addAction:gobackAction];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self presentViewController:alert animated:YES completion:nil];
                });
                
//                UIAlertView *noCompList = [[UIAlertView alloc] initWithTitle:@"No companies found." message:@"Could not find list of companies." delegate:self cancelButtonTitle:@"Retry" otherButtonTitles:@"Go back",nil];
//                noCompList.tag = 100;
//                [noCompList show];
                return;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showSuccessWithStatus:@"Done"];
                [self->_companyTableview reloadInputViews];
                [self->_companyTableview reloadData];
            });
            
        }
        else if ([output isKindOfClass:[NSString class]])   {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [SVProgressHUD dismiss];
                errorString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                errorString = [errorString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                errorString = [errorString substringWithRange:NSMakeRange(1, errorString.length-2)];
                errorString = [errorString capitalizedString];
                
                if ([errorString  caseInsensitiveCompare:@"IEV C003"] == NSOrderedSame) {
                    [Utility showAlertWithTitle:@"Sign in" message:@"Invalid connection string to connect to company.\nPlease try again." buttonTitle:@"OK" inViewController:self];
                }
            });
        } else {
            
        }
        
    } else if (dataType == DATA_TYPE_USERLIST) {
        
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
            
            PCUserLoginViewController *uvc = [kStoryboard instantiateViewControllerWithIdentifier:@"PCUserLoginViewController"];
            [uvc setUsersList:usersList];
            [uvc setSeletedCompany:selectedCompany];
            [self.navigationController pushViewController:uvc animated:NO];
        });
        
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
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error." message:@"Could not fetch data from server." preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction * retryAction = [UIAlertAction actionWithTitle:@"Retry" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self pullData];
            });
        }];
        
        [alert addAction:retryAction];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:alert animated:YES completion:nil];
        });
        
//        UIAlertView *noCompList = [[UIAlertView alloc] initWithTitle:@"Error." message:@"Could not fetch data from server." delegate:self cancelButtonTitle:@"Retry" otherButtonTitles:nil];
//        noCompList.tag = 100;
//        [noCompList show];
    });

    if (dataType == DATA_TYPE_COMPANYLIST) {
        
    }
    else if (dataType == DATA_TYPE_USERLIST) {
        
    }
}

-(void)searchCompanyList:(NSString *)searchText {
    
    NSLog(@"searchCompanyList - %@", searchText);
    
    @try
      {
        [filteredCompanyList removeAllObjects];

        if ([searchText length] > 0)
        {
            
            NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"NAME contains[c] %@", searchText];

            NSArray *results = [companyList filteredArrayUsingPredicate:resultPredicate];
            [filteredCompanyList addObjectsFromArray:results];
            
//            for (int i = 0; i < [companyList count] ; i++)
//            {
//                PCCompanyModel *cmp = [companyList objectAtIndex:i];
//                
//                if ([cmp.NAME localizedCaseInsensitiveContainsString:searchText]) {
//                    NSLog(@"%@ == %@",cmp.NAME,searchText);
//                    [filteredCompanyList addObject:cmp];
//                }
//            }
                
//                if (cmp.NAME.length >= searchText.length)
//                {
//                    NSRange titleResultsRange = [cmp.CO_CD rangeOfString:searchText options:NSCaseInsensitiveSearch];
//                    if (titleResultsRange.length > 0)
//                    {
//                        [filteredCompanyList addObject:cmp];
//                    }
//                }
//            }
        } else {
//            [filteredCompanyList addObjectsFromArray:companyList];
        }
          
        [_companyTableview reloadData];
    }
    @catch (NSException *exception) {
        
    }

}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return filteredCompanyList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [cell.textLabel setFont:[UIFont boldSystemFontOfSize:13.0f]];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor colorNamed:kCustomBlack];
    }
    
    PCCompanyModel *mod = [filteredCompanyList objectAtIndex:indexPath.row];
    
    cell.textLabel.text = mod.NAME;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    dataType = DATA_TYPE_USERLIST;
    PCCompanyModel *mod = [filteredCompanyList objectAtIndex:indexPath.row];
    AppDelegate *appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDel setSelectedCompany:mod];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:mod.CO_CD forKey:kSelectedCompanyCode];
    [defaults setValue:mod.LONG_CO_NM forKey:kSelectedCompanyLongname];
    [defaults setValue:mod.NAME forKey:kSelectedCompanyName];
    
    if (mod.TBGRP == true) {
        [defaults setValue:@1 forKey:kSelectedCompanyTbGrp];
    } else {
        [defaults setValue:@0 forKey:kSelectedCompanyTbGrp];
    }
    
    [defaults synchronize];
    
    selectedCompany = mod.LONG_CO_NM;
    dataTypeURL = [NSMutableString stringWithString:mod.CO_CD];
    [self pullData];
}

//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
//{
//    UILabel *footerLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
//    footerLbl.textAlignment = NSTextAlignmentCenter;
//    footerLbl.font = [UIFont systemFontOfSize:13];
//    footerLbl.textColor = [UIColor darkGrayColor];
//    footerLbl.backgroundColor = [UIColor clearColor];
//    
//    
//    footerLbl.text = [NSString stringWithFormat:@"PCSOFT ERP Solutions Pvt. Ltd."];
//    
//    return footerLbl;
//}
//- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
//{
//    if (alertView.tag == 100 || alertView.tag == 101) {
//        if (buttonIndex == 0) {
//            [self pullData];
//        }
//    }
//
//    if (alertView.tag == 100 && (buttonIndex == 1)) {
//        [self.navigationController popViewControllerAnimated:TRUE];
//    }
//}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self searchCompanyList:searchText];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [filteredCompanyList removeAllObjects];
    [filteredCompanyList addObjectsFromArray:companyList];
    [_companyTableview reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [self searchCompanyList:searchBar.text];
}
@end
