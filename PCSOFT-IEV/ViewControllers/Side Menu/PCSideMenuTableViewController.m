//
//  PCSideMenuTableViewController.m
//  ERPMobile
//
//  Created by Sameer Ghate on 04/09/14.
//  Copyright (c) 2014 Sameer Ghate. All rights reserved.
//

#import "PCSideMenuTableViewController.h"
#import "MKDSlideViewController.h"
#import "UIViewController+MKDSlideViewController.h"
#import "PCDailySalesViewController.h"
#import "PCRejectionsTableViewController.h"
#import "PCAttendanceTableViewController.h"
#import "PCCashFlowProjectionTableViewController.h"
#import "PCInvoicesTableViewController.h"
#import "PCPOSOTransactionsTableViewController.h"
#import "PCRejectionsViewController.h"
#import "PCHomeViewController.h"
#import "PCSettingsViewController.h"
#import "PCPOSOHomeTableViewController.h"
#import "PCViewController.h"
#import "ConnectionHandler.h"
#import "SVProgressHUD.h"

@interface PCSideMenuTableViewController () <ConnectionHandlerDelegate>

@property (nonatomic, strong) NSArray *reportsArray, *reportsIconsArray, *transactionsArray, *transactionsIconsArray, *moreArray, *moreIconsArray;

@end
@implementation PCSideMenuTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    _reportsArray = @[@"Sales", @"Cash Flow Projection", @"Rejections", @"Attendance"];
    _reportsIconsArray = @[@"dailysales-side-icon.png",@"cashflow-side-icon.png",@"rejections-side-icon.png",@"attendance-side-icon.png"];
    
//    _transactionsArray = @[@"Purchase Indents",@"Purchase Order", @"Sale Order", @"Expense Booking", @"Bill Passing", @"Payments", @"Employee Expense"];
    _transactionsArray = @[@"Approvals"];
    
    _transactionsIconsArray = @[@"pi-side-icon.png"];
    _moreArray = @[@"Settings",@"About this app", @"Logout"];
    _moreIconsArray = @[@"settings-side-icon.png",@"info-side-icon.png",@"logout-side-icon.png"];
    
    UIView *tblHdr = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 70)];
    [tblHdr setBackgroundColor:[UIColor clearColor]];
    
    UIImageView *imgv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ONLY PCSOFT LOGO"]];
    [imgv setFrame:CGRectMake(100, 10, 100, 40)];
    [imgv setContentMode:UIViewContentModeScaleAspectFit];
    
    [tblHdr addSubview:imgv];
    
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(50, 50, 250, 10)];
    lbl.font = [UIFont systemFontOfSize:12];
    lbl.textColor = [UIColor lightGrayColor];
    lbl.text = @"PCSOFT ERP Solutions Pvt. Ltd.";
    
    [tblHdr addSubview:lbl];
    
    [self.tableView setTableFooterView:tblHdr];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 64;
    }
    return 44;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 5;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = nil;
    switch (section) {
        case 0:
            title = nil;
            break;
            
            
        case 1:
            title = nil;
            break;
            
        case 2:
            title = @"Reports";
            break;
            
        case 3:
            title = @"Authorizations";
            break;
        
        case 4:
            title = @"More";
            break;
            
        default:
            break;
    }
    
    return title;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSInteger rows = 0;
    switch (section) {
        case 0:
            rows = 1;
            break;
            
        case 1:
            rows = 1;
            break;
            
        case 2:
            rows = _reportsArray.count;
            break;
            
        case 3:
            rows = _transactionsArray.count;
            break;
            
        case 4:
            rows = _moreArray.count;
            break;
            
        default:
            break;
    }
    
    return rows;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    // Configure the cell...
    
    cell.imageView.image = nil;
    
    switch (indexPath.section) {
            
        case 0:
        {
            AppDelegate *appdel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
            cell.textLabel.text= appdel.loggedUser.USER_NAME;
            cell.imageView.image = [UIImage imageNamed:@"userDefault.png"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
            break;
            
        case 1:
            
            cell.textLabel.text = @"Home";
            cell.imageView.image = [UIImage imageNamed:@"home-side-icon.png"];
            break;
            
        case 2:
            
            cell.textLabel.text = [_reportsArray objectAtIndex:indexPath.row];
            cell.imageView.image = [UIImage imageNamed:[_reportsIconsArray objectAtIndex:indexPath.row]];
            break;
            
        case 3:
            cell.textLabel.text = [_transactionsArray objectAtIndex:indexPath.row];
            cell.imageView.image = [UIImage imageNamed:[_transactionsIconsArray objectAtIndex:indexPath.row]];;
            break;
            
        case 4:
            cell.textLabel.text = [_moreArray objectAtIndex:indexPath.row];
            cell.imageView.image = [UIImage imageNamed:[_moreIconsArray objectAtIndex:indexPath.row]];
            break;
            
        default:
            break;
    }
    
    cell.imageView.layer.cornerRadius = 5.0;
    cell.imageView.layer.masksToBounds = YES;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    AppDelegate *appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    UINavigationController *mainNavController = (UINavigationController*)appDel.slideViewController.mainViewController;
    
    switch (indexPath.section) {
        case 0:
            
            return;
            
            break;
            
        case 1:
            
        {
            if( [mainNavController.topViewController isKindOfClass:[PCHomeViewController class]] )
                [appDel.slideViewController showMainViewControllerAnimated:YES];
            else
            {
                PCHomeViewController * cfpvc = [kStoryboard instantiateViewControllerWithIdentifier:@"PCHomeViewController"];
                [mainNavController popViewControllerAnimated:NO];
                [mainNavController pushViewController:cfpvc animated:NO];
                //                        [appDel.slideViewController setMainViewController:cfpvc animated:YES];
            }
        }
            break;
            
            break;
            
        case 2:
        {
            switch (indexPath.row) {
                case 0:
                {
                    if( [mainNavController.topViewController isKindOfClass:[PCDailySalesViewController class]] )
                        
                        [appDel.slideViewController showMainViewControllerAnimated:YES];
                    else
                    {
                        PCDailySalesViewController * dsvc = [kStoryboard instantiateViewControllerWithIdentifier:@"PCDailySalesViewController"];
                        [mainNavController popViewControllerAnimated:NO];
                        [mainNavController pushViewController:dsvc animated:NO];
                        
//                        [appDel.slideViewController setMainViewController:dsvc animated:YES];
                    }
                }
                    
                    break;
                    
                    
//                case 0:
//                {
//                    if( [mainNavController.topViewController isKindOfClass:[PCInvoicesTableViewController class]] )
//                        [appDel.slideViewController showMainViewControllerAnimated:YES];
//                    else
//                    {
//                        PCInvoicesTableViewController * invc = [kStoryboard instantiateViewControllerWithIdentifier:@"PCInvoicesTableViewController"];
//                        [mainNavController popViewControllerAnimated:NO];
//                        [mainNavController pushViewController:invc animated:NO];
//                        
////                        [appDel.slideViewController setMainViewController:invc animated:YES];
//                    }
//                }
//                    
//                    break;
                    
                case 1:
                {
                    if( [mainNavController.topViewController isKindOfClass:[PCCashFlowProjectionTableViewController class]] )
                        [appDel.slideViewController showMainViewControllerAnimated:YES];
                    else
                    {
                        PCCashFlowProjectionTableViewController * cfpvc = [kStoryboard instantiateViewControllerWithIdentifier:@"PCCashFlowProjectionTableViewController"];
                        [mainNavController popViewControllerAnimated:NO];
                        [mainNavController pushViewController:cfpvc animated:NO];
//                        [appDel.slideViewController setMainViewController:cfpvc animated:YES];
                    }
                }
                    break;
                    
                case 2:
                {
                    if( [mainNavController.topViewController isKindOfClass:[PCRejectionsTableViewController class]] )
                        [self.navigationController.slideViewController showMainViewControllerAnimated:YES];
                    else
                    {
                        PCRejectionsViewController * rejvc = [kStoryboard instantiateViewControllerWithIdentifier:@"PCRejectionsViewController"];
                        [mainNavController popViewControllerAnimated:NO];
                        [mainNavController pushViewController:rejvc animated:NO];
//                        [appDel.slideViewController setMainViewController:rejvc animated:YES];
                    }
                }
                    break;
                    
                case 3:
                {
                    if( [mainNavController.topViewController isKindOfClass:[PCAttendanceTableViewController class]] )
                        [appDel.slideViewController showMainViewControllerAnimated:YES];
                    else
                    {
                        PCAttendanceTableViewController * attVc = [kStoryboard instantiateViewControllerWithIdentifier:@"PCAttendanceTableViewController"];
                        [mainNavController popViewControllerAnimated:NO];
                        [mainNavController pushViewController:attVc animated:NO];
//                        [appDel.slideViewController setMainViewController:attVc animated:YES];
                    }
                }
                    break;
                    
                default:
                    break;
            }
        }
            
            break;
            
        case 3:
        {
                PCPOSOHomeTableViewController *posoHome = [kStoryboard instantiateViewControllerWithIdentifier:@"PCPOSOHomeTableViewController"];
                [mainNavController popViewControllerAnimated:NO];
                [mainNavController pushViewController:posoHome animated:NO];
        }
            break;
            
        case 4:
            
            if (indexPath.row == 0) {
                
                UIViewController *settingsViewcontroller = [kStoryboard instantiateViewControllerWithIdentifier:@"PCSettingsViewController"];
                [mainNavController popViewControllerAnimated:NO];
                [mainNavController pushViewController:settingsViewcontroller animated:NO];
                
            }
            
            else if (indexPath.row == 1) {
                
                UIViewController *aboutappViewcontroller = [kStoryboard instantiateViewControllerWithIdentifier:@"PCAboutAppViewController"];
                [mainNavController popViewControllerAnimated:NO];
                [mainNavController pushViewController:aboutappViewcontroller animated:NO];
                
            }
            else if (indexPath.row == 2) {
                
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Logout" message:@"Are you sure you want to log out?" preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction * yesAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                    [self logout];
                    
                }];
                
                UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                }];
                
                [alert addAction:yesAction];
                [alert addAction:cancelAction];
                
                [self presentViewController:alert animated:YES completion:nil];
                
//                UIAlertView *confirmLogout = [[UIAlertView alloc] initWithTitle:@"Logout?" message:@"Are you sure you want to log out?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"Cancel", nil];
//                confirmLogout.tag = 101;
//                [confirmLogout show];
                return;
            }
            
            
            break;
            
        default:
            break;
    }
    
    [appDel.slideViewController showMainViewControllerAnimated:YES];
        
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
//{
//    if (alertView.tag == 101) {
//        if (buttonIndex == 0) {
//            [self logout];
//        }
//    }
//}

- (void)logout
{
    AppDelegate *appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    appDel.loggedUser = nil;
    UINavigationController *mainNavController = (UINavigationController*)appDel.slideViewController.mainViewController;
    
    NSArray *arr = mainNavController.viewControllers;
    
    [arr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[PCViewController class]]) {
            
            [mainNavController popToViewController:[arr objectAtIndex:idx] animated:NO];
            *stop = TRUE;
        }
    }];
    
    [appDel.slideViewController showMainViewControllerAnimated:YES];
    
    /*
    AppDelegate *appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    [SVProgressHUD showWithStatus:@"Logging out..." maskType:SVProgressHUDMaskTypeBlack];
    ConnectionHandler *handler = [[ConnectionHandler alloc] init];
    handler.delegate = self;
    
    NSString *url = [NSString stringWithFormat:@"%@%@%@",appDel.baseURL,kUserLogoutService,appDel.selectedCompany.CO_CD];
    
    [handler fetchDataForURL:url body:nil];
     */
}

-(void)connectionHandler:(ConnectionHandler*)conHandler didRecieveData:(NSData*)data
{
    
    NSString *outputString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    outputString = [outputString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [SVProgressHUD dismiss];
        
        if ([outputString rangeOfString:@"false"].location == NSNotFound) {
            
            AppDelegate *appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];

            appDel.loggedUser = nil;
            UINavigationController *mainNavController = (UINavigationController*)appDel.slideViewController.mainViewController;
            
            NSArray *arr = mainNavController.viewControllers;
            
            [arr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if ([obj isKindOfClass:[PCViewController class]]) {
                    
                    [mainNavController popToViewController:[arr objectAtIndex:idx] animated:NO];
                    *stop = TRUE;
                }
            }];
            
            [appDel.slideViewController showMainViewControllerAnimated:YES];
        }
        else {
            
            [Utility showAlertWithTitle:@"Logout" message:@"There seems some problem while logging out from the system. Please try again after some time." buttonTitle:@"OK" inViewController:self];
            
        }
    });
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
        
    });
}


#pragma Set user name

-(void)setuserName
{
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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
