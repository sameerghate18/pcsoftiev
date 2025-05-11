//
//  PCRejectionsViewController.m
//  ERPMobile
//
//  Created by Sameer Ghate on 03/09/14.
//  Copyright (c) 2014 Sameer Ghate. All rights reserved.
//

#import "PCRejectionsViewController.h"
#import "PCRejectionModel.h"
#import "ConnectionHandler.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "SVProgressHUD.h"
#import "PCRejectionsTableViewCell.h"
#import "PCRejectionsGraphViewController.h"
#import "SVProgressHUD.h"

#define kCellHeight 60.0

@interface PCRejectionsViewController () <UITableViewDataSource,UITableViewDelegate, ConnectionHandlerDelegate, UITextFieldDelegate>

{
    NSMutableArray *rejectionsArray;
    UIRefreshControl *refreshControl;
    NSString *searchText;
    NSString *lastRefreshTime;
    BOOL isKeyboardRefresh;
    NSMutableDictionary *selectedIndexes;
}

- (BOOL)cellIsSelected:(NSIndexPath *)indexPath;

@property (nonatomic, weak) IBOutlet UITextField *valueTextfield;
@property (nonatomic, weak) NSString *rejectionValue;
@property (nonatomic, weak) IBOutlet UITableView *rejectionsTableview;
@property (nonatomic, weak) IBOutlet UITextField *searchTextField;

@end


@implementation PCRejectionsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    self.navigationController.navigationBarHidden = TRUE;
    
    selectedIndexes = [[NSMutableDictionary alloc] init];
    
    [self.rejectionsTableview registerNib:[UINib nibWithNibName:@"PCRejectionsTableViewCell" bundle:nil] forCellReuseIdentifier:reuseIdent];
}

-(IBAction)showSideMenu:(id)sender
{
    if ([_valueTextfield isFirstResponder]) {
        [_valueTextfield resignFirstResponder];
    }
    
    AppDelegate *appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    [appDel.slideViewController showLeftViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)searchRejections:(id)sender
{
    if ([_valueTextfield isFirstResponder]) {
        [_valueTextfield resignFirstResponder];
    }
    
    AppDelegate *appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    NSString *rejectionURL = [NSString stringWithFormat:@"%@/iev/GetRejection?scocd=%@",appDel.baseURL,appDel.selectedCompany.CO_CD];//&Xvalue=%@
    
    ConnectionHandler *handler = [[ConnectionHandler alloc] init];
    handler.delegate = self;
    
    NSDictionary *postDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              appDel.selectedCompany.CO_CD, kScoCodeKey,
                              nil];
    
    [handler fetchDataForURL:[NSString stringWithFormat:@"%@/iev/GetRejection",appDel.baseURL] body:postDict];
}

-(void)connectionHandler:(ConnectionHandler*)conHandler didRecieveData:(NSData*)data
{
    NSError *error = nil;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    
    NSArray *arr = [dict objectForKey:kDataKey];
    
    rejectionsArray = [[NSMutableArray alloc] init];
    
    if (arr.count > 0) {
        
        for (NSDictionary *dict in arr) {
            PCRejectionModel *model = [[PCRejectionModel alloc] init];
            [model setValuesForKeysWithDictionary:dict];
            [rejectionsArray addObject:model];
        }
        lastRefreshTime = [Utility lastRefreshString];
        
        if (!refreshControl) {
            refreshControl = [[UIRefreshControl alloc] init];
            [refreshControl addTarget:self action:@selector(searchRejections:) forControlEvents:UIControlEventValueChanged];
            
//            [_rejectionsTableview setRefreshControl:refreshControl];
        }
    }
    else {
        
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_rejectionsTableview reloadData];
        [refreshControl endRefreshing];
        if (isKeyboardRefresh) {
            [SVProgressHUD dismiss];
            isKeyboardRefresh = NO;
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
        if (isKeyboardRefresh) {
            [SVProgressHUD dismiss];
            isKeyboardRefresh = NO;
        }
        [refreshControl endRefreshing];
    });
}

-(IBAction)displayPieChart:(id)sender
{
    PCRejectionsGraphViewController *graphVC = [kStoryboard instantiateViewControllerWithIdentifier:@"PCRejectionsGraphViewController"];
    
    if (rejectionsArray.count == 0) {
        
        [Utility showAlertWithTitle:@"Data not available" message:@"No sufficient data to present a graph.\nTry refreshing again." buttonTitle:@"OK" inViewController:self];
        
    }
    
    [graphVC setRejectionsData:rejectionsArray];
    
    graphVC.modalPresentationStyle = UIModalPresentationCurrentContext;
    graphVC.modalTransitionStyle   = UIModalTransitionStyleFlipHorizontal;
    
    [self presentViewController:graphVC animated:YES completion:NULL];
}

- (BOOL)cellIsSelected:(NSIndexPath *)indexPath {
    // Return whether the cell at the specified index path is selected or not
    NSNumber *selectedIndex = [selectedIndexes objectForKey:indexPath];
    return selectedIndex == nil ? FALSE : [selectedIndex boolValue];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return rejectionsArray.count>0?rejectionsArray.count:1;
}

static NSString *reuseIdent = @"PCRejectionsTableViewCell";
static NSString *reuseIdent1 = @"CellIdentifier";
static NSString *noitemsCellIdentifier = @"NoItemsCell";

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *returningCell;
    
    if (rejectionsArray.count > 0) {
        
        PCRejectionsTableViewCell *cell1 = (PCRejectionsTableViewCell*)[tableView dequeueReusableCellWithIdentifier:reuseIdent];
        
        PCRejectionModel *model = [rejectionsArray objectAtIndex:indexPath.row];
        
        cell1.itemCodeLabel.text = [NSString stringWithFormat:@"%@",model.IM_CODE];
        cell1.totalQtyLbl.text = [NSString stringWithFormat:@"%@",model.IM_QTY];
        cell1.rateLabel.text = model.DESCRIPTION;
        
//        cell1.totalValueLabel.text = [Utility stringWithCurrencySymbolForValue:[NSString stringWithFormat:@"%@",model.TOTAL_VALUE]];
//        cell1.rateLabel.text = [Utility stringWithCurrencySymbolForValue:[NSString stringWithFormat:@"%@",model.STD_RATE]];
        
        return cell1;
    }
    else {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:noitemsCellIdentifier];

        
//        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdent1];
//        
//        if (cell == nil) {
//            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdent1];
//        }
//        
//        cell.textLabel.textColor = [UIColor darkGrayColor];
//        cell.textLabel.font = [UIFont boldSystemFontOfSize:13];
//        cell.textLabel.textAlignment = NSTextAlignmentCenter;
//        cell.textLabel.text = @"No rejected items found. Refresh again.";
        return cell;
    }
    
    return returningCell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UILabel *footerLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    footerLbl.textAlignment = NSTextAlignmentCenter;
    footerLbl.font = [UIFont systemFontOfSize:13];
    footerLbl.textColor = [UIColor colorNamed:kCustomGray];
    
    if (lastRefreshTime != nil) {
        footerLbl.text = [NSString stringWithFormat:@"Last updated : %@",lastRefreshTime];
    }
    else {
        footerLbl.text = [NSString stringWithFormat:@""];
    }
    
    footerLbl.backgroundColor = [UIColor clearColor];
    
    return footerLbl;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Deselect cell
    [tableView deselectRowAtIndexPath:indexPath animated:TRUE];
    
    // Toggle 'selected' state
    BOOL isSelected = ![self cellIsSelected:indexPath];
    
    // Store cell 'selected' state keyed on indexPath
    NSNumber *selectedIndex = [NSNumber numberWithBool:isSelected];
    [selectedIndexes setObject:selectedIndex forKey:indexPath];
    
    // This is where magic happens...
    [_rejectionsTableview beginUpdates];
    [_rejectionsTableview endUpdates];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // If our cell is selected, return double height
    
    if (rejectionsArray.count > 0) {
        if([self cellIsSelected:indexPath]) {
            return kCellHeight * 2.0;
        }
        
        // Cell isn't selected so return single height
        return kCellHeight;
    }
    else {
        return 200;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    searchText = [NSString stringWithString:textField.text];
    
    searchText = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    isKeyboardRefresh = YES;
    [self searchRejections:textField];
    return YES;
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
