//
//  PCDailySalesViewController.m
//  ERPMobile
//
//  Created by Sameer Ghate on 07/09/14.
//  Copyright (c) 2014 Sameer Ghate. All rights reserved.
//

#import "PCDailySalesViewController.h"
#import "SVProgressHUD.h"
#import "ConnectionHandler.h"
#import <QuartzCore/QuartzCore.h>
#import "PCDailySalesTableViewCell.h"
#import "PCDailySalesGraphViewController.h"
#import "PCTblGroupModel.h"

@interface PCDailySalesViewController () <ConnectionHandlerDelegate, UITableViewDataSource, UITableViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource>
{
    NSMutableArray *dailySales;
    PCTblGroupModel *grpMenuItems;
    PCTblGroupModelElement *selectedGroup;
    NSInteger currentIndexOnRoll, userSelectedIndex;
    NSString *currentMonth, *lastMonth, *previousToLastMonth;
    SalesType salesType;
    NSString *selectedSalesTypeCurrencyCode;
    NSString *lastRefreshTime;
}

@property (nonatomic, strong) IBOutlet UILabel *todaysSales, *totalSales, *lastUpdateLabel;
@property (nonatomic, weak) IBOutlet UIImageView *boxImgView1, *boxImgView2;

@property (nonatomic, weak) IBOutlet UIButton *refreshBtn;
@property (nonatomic, weak) IBOutlet UITextField *groupLabelTextbox;

@property (nonatomic, weak) IBOutlet UITableView *salesTable;
@property (nonatomic, strong) UIPickerView *grpMenuPicker;

@property (nonatomic, strong) NSDictionary *salesData, *exportSalesData, *tableSourceData;

@end

@implementation PCDailySalesViewController

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
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = TRUE;
    
    self.navigationItem.hidesBackButton = YES;
    
    [self setTitle:@"Daily Sales"];
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setImage:[UIImage imageNamed:@"menu-icon.png"] forState:UIControlStateNormal];
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setImage:[UIImage imageNamed:@"dailysales-side-icon.png"] forState:UIControlStateNormal];
    
    UIBarButtonItem *barbtn = [[UIBarButtonItem alloc]  initWithImage:[UIImage imageNamed:@"menu_icon.png"] style:UIBarButtonItemStylePlain target:self action:@selector(showSideMenu)];
    
//    UIBarButtonItem *barbtn = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    
    self.navigationItem.leftBarButtonItem = barbtn;
    
    UIBarButtonItem *rightBarbtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"graph.png"] style:UIBarButtonItemStylePlain target:self action:@selector(displaySalesPieChart:)];
    
//    UIBarButtonItem *rightBarbtn = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    
    self.navigationItem.rightBarButtonItem = rightBarbtn;
    
    salesType = SalesTypeDomestic;
    selectedSalesTypeCurrencyCode = [[NSString alloc] init];
    
    [self fetchTableGroups];
    // Do any additional setup after loading the view.
}

-(void)getDates
{
    NSDate *currentDate = [NSDate date];
    
    NSDate *lastMonthDate, *previousToLastMonthDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [NSDateComponents new];
    
    comps.month = -1;
    comps.day   = -1;
    
    lastMonthDate = [calendar dateByAddingComponents:comps toDate:[NSDate date] options:0];
    
    previousToLastMonthDate = [calendar dateByAddingComponents:comps toDate:lastMonthDate options:0];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:@"MMM yyyy"];
    
    currentMonth = [formatter stringFromDate:currentDate];
    lastMonth = [formatter stringFromDate:lastMonthDate];
    previousToLastMonth = [formatter stringFromDate:previousToLastMonthDate];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)showSideMenu
{
    AppDelegate *appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    [appDel.slideViewController showLeftViewControllerAnimated:YES];
}

-(IBAction)displaySalesPieChart:(id)sender
{
    if (!_tableSourceData ) {
        [Utility showAlertWithTitle:@"Data not available" message:@"No sufficient data to present a graph.\nTry refreshing again." buttonTitle:@"OK" inViewController:self];
        return;
    }
    
    PCDailySalesGraphViewController *graphVC = [kStoryboard instantiateViewControllerWithIdentifier:@"PCDailySalesGraphViewController"];
    
    [graphVC setCurrencyCode:selectedSalesTypeCurrencyCode];
    [graphVC setSelectedSalesType:salesType];
    [graphVC setSalesData:_tableSourceData];
    [graphVC setCurrentMonthString:currentMonth];
    [graphVC setLastMonthString:lastMonth];
    [graphVC setPrevToLastMonthString:previousToLastMonth];
    
    graphVC.modalPresentationStyle = UIModalPresentationCurrentContext;
    graphVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    [self presentViewController:graphVC animated:YES completion:NULL];
}

-(IBAction)toggleSalesType:(id)sender
{
    UISegmentedControl *segment = (UISegmentedControl*)sender;
    
    switch (segment.selectedSegmentIndex) {
        case 0:
            selectedSalesTypeCurrencyCode = [_salesData valueForKey:@"CUR_DESC"];
            _tableSourceData = _salesData;
            salesType = SalesTypeDomestic;
            break;
            
        case 1:
            selectedSalesTypeCurrencyCode = [_exportSalesData valueForKey:@"CUR_DESC"];
            _tableSourceData = _exportSalesData;
            salesType = SalesTypeExport;
            break;
            
        default:
            break;
    }
    
    [_salesTable reloadData];
}

-(void)fetchTableGroups {
    
    AppDelegate *appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    [SVProgressHUD showWithStatus:@"Loading data..." maskType:SVProgressHUDMaskTypeBlack];
    ConnectionHandler *handler = [[ConnectionHandler alloc] init];
    handler.delegate = self;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *companyCode = [defaults valueForKey:kSelectedCompanyCode];
    
    NSString *url = [NSString stringWithFormat:@"%@/%@%@",appDel.baseURL,kTblGrpService,companyCode];
    [handler fetchDataForGETURL:url body:nil completion:^(id responseData, NSError *error) {
        
        if (error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSString *msg = @"Error details not available.";
                
                if ([error code] == -5000) {
                    msg = noInternetMessage;
                } else {
                    msg = [error localizedDescription];
                }
                
                [SVProgressHUD dismiss];
                [Utility showAlertWithTitle:@"IEV" message:msg buttonTitle:@"OK" inViewController:self];
            });
            return;
        }
        
        self->grpMenuItems = PCTblGroupModelFromData((NSData*)responseData, &error);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (self->grpMenuItems.count > 0) {
                // Populate menu
                [self createGrpMenu];
            } else {
                [Utility showAlertWithTitle:@"Daily Sales" message:@"No groups found." buttonTitle:@"Ok" inViewController:self];
            }
            
        });
        
    }];
    
}

-(void)createGrpMenu {
    
    UIToolbar *menuToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(menuBarCancelPressed)];
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(menuBarDonePressed)];
    
    menuToolbar.items = @[cancel,space,done];
    
    self.grpMenuPicker = [[UIPickerView alloc] init];
    self.grpMenuPicker.dataSource = self;
    self.grpMenuPicker.delegate = self;
    self.grpMenuPicker.showsSelectionIndicator = true;
    
    self.groupLabelTextbox.inputAccessoryView = menuToolbar;
    self.groupLabelTextbox.inputView = self.grpMenuPicker;
    
    currentIndexOnRoll = userSelectedIndex = 0;
    selectedGroup = [self->grpMenuItems objectAtIndex:userSelectedIndex];
    self.groupLabelTextbox.text = selectedGroup.descr;
    [self fetchDailySalesData:nil];
    
}

-(void)menuBarCancelPressed {
    
    [self.groupLabelTextbox resignFirstResponder];
}

-(void)menuBarDonePressed {
     
    // fetch sales data for selected group code
    selectedGroup = [self->grpMenuItems objectAtIndex:currentIndexOnRoll];
    self.groupLabelTextbox.text = selectedGroup.descr;
    [self.groupLabelTextbox resignFirstResponder];
    [self fetchDailySalesData:nil];
}

-(IBAction)fetchDailySalesData:(id)sender
{
    AppDelegate *appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    [SVProgressHUD showWithStatus:@"Loading data..." maskType:SVProgressHUDMaskTypeBlack];
    ConnectionHandler *handler = [[ConnectionHandler alloc] init];
    handler.delegate = self;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *companyCode = [defaults valueForKey:kSelectedCompanyCode];
    
    NSString *params = kGetSalesForGroup(companyCode, selectedGroup.code);
    NSString *url = [NSString stringWithFormat:@"%@/%@",appDel.baseURL,params];
    
    [handler fetchDataForURL:url body:nil];
}

-(void)connectionHandler:(ConnectionHandler*)conHandler didRecieveData:(NSData*)data
{
    NSError *error = nil;
    NSArray *arr = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    
    dailySales = [[NSMutableArray alloc] initWithArray:arr copyItems:YES];
    
    if (dailySales.count > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showSuccessWithStatus:@"Done"];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[self->dailySales objectAtIndex:0]];
            if ([[dict valueForKey:@"CUR_DESC"] rangeOfString:@"RUPEE"].location != NSNotFound) {
                [dict setValue:@"INR" forKey:@"CUR_DESC"];
            }
            
            if (self->dailySales.count > 1) {
                
                NSMutableDictionary *exportDict = [NSMutableDictionary dictionaryWithDictionary:[self->dailySales objectAtIndex:1]];
                
                if ([[exportDict valueForKey:@"CUR_DESC"] rangeOfString:@"RUPEE"].location != NSNotFound) {
                    [exportDict setValue:@"INR" forKey:@"CUR_DESC"];
                }
                
                self->_exportSalesData = [[NSDictionary alloc] initWithDictionary:exportDict copyItems:YES];
            }
            
            self->_salesData = [[NSDictionary alloc] initWithDictionary:dict copyItems:YES];
            
            self->_lastUpdateLabel.text = [NSString stringWithFormat:@"Last updated : %@",[Utility lastRefreshString]];
            
            [self getDates];
            
            if (self->salesType == SalesTypeDomestic) {
                self->selectedSalesTypeCurrencyCode = [self->_salesData valueForKey:@"CUR_DESC"];
                self->_tableSourceData = self->_salesData;
            }
            else {
                self->selectedSalesTypeCurrencyCode = [self->_exportSalesData valueForKey:@"CUR_DESC"];
                self->_tableSourceData = self->_exportSalesData;
            }
            
            self->lastRefreshTime = [Utility lastRefreshString];
            
            [self->_salesTable reloadData];
            self->userSelectedIndex = self->currentIndexOnRoll;
        });
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            self->selectedGroup = [self->grpMenuItems objectAtIndex:self->userSelectedIndex];
            self.groupLabelTextbox.text = self->selectedGroup.descr;
            
            [SVProgressHUD showErrorWithStatus:@"Failed"];
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
        [SVProgressHUD showErrorWithStatus:@"Failed"];
    });
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self->selectedGroup = [self->grpMenuItems objectAtIndex:self->userSelectedIndex];
        self.groupLabelTextbox.text = self->selectedGroup.descr;
    });
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==1) {
        return 40.0f;
    }
    
    return 135.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView   {
    
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 1) {
        return 1;
    }
    
    if (_tableSourceData.count > 0) {
        
        return 5;
    }
    else
        return 1;
}

static NSString *cellIdentifier = @"PCDailySalesTableViewCell";
static NSString *noitemsCellIdentifier = @"NoItemsCell";
static NSString *lastUpdateCellIdentifier = @"lastUpdateCellIdentifier";

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        
        UITableViewCell *lastUpdateCell = [tableView dequeueReusableCellWithIdentifier:lastUpdateCellIdentifier];
        
        if (lastUpdateCell==nil) {
            lastUpdateCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:lastUpdateCellIdentifier];
            lastUpdateCell.textLabel.font = [UIFont systemFontOfSize:13];
            lastUpdateCell.textLabel.textColor = [UIColor darkGrayColor];
            //            lastUpdateCell.textLabel.backgroundColor = [UIColor clearColor];
            lastUpdateCell.textLabel.textAlignment = NSTextAlignmentCenter;
            //            lastUpdateCell.contentView.backgroundColor = [UIColor clearColor];
            lastUpdateCell.backgroundColor = [UIColor clearColor];
            lastUpdateCell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        lastUpdateCell.textLabel.text = [NSString stringWithFormat:@"Last updated : %@",lastRefreshTime];
        
        return lastUpdateCell;
    }
    
    
    if (_tableSourceData.count > 0) {
        
        PCDailySalesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        
        switch (indexPath.row) {
            case 0:
                
                cell.headerLabel.text = @"Today's Sales";
                cell.subtitleLabel.text = [Utility stringWithCurrencySymbolForValue:[_tableSourceData valueForKey:@"CURR_AMT"] forCurrencyCode:selectedSalesTypeCurrencyCode];
                
                break;
                
            case 1:
                
                cell.headerLabel.text = currentMonth;
                cell.subtitleLabel.text = [Utility stringWithCurrencySymbolForValue:[_tableSourceData valueForKey:@"CURRMTH"] forCurrencyCode:selectedSalesTypeCurrencyCode];
                
                break;
                
            case 2:
                
                cell.headerLabel.text = lastMonth;
                cell.subtitleLabel.text = [Utility stringWithCurrencySymbolForValue:[_tableSourceData valueForKey:@"LASTMTH"] forCurrencyCode:selectedSalesTypeCurrencyCode];
                
                break;
                
            case 3:
                
                cell.headerLabel.text = previousToLastMonth;
                cell.subtitleLabel.text = [Utility stringWithCurrencySymbolForValue:[_tableSourceData valueForKey:@"PREVMTH"] forCurrencyCode:selectedSalesTypeCurrencyCode];
                
                break;
                
            case 4:
                
                cell.headerLabel.text = @"Total yearly";
                cell.subtitleLabel.text = [Utility stringWithCurrencySymbolForValue:[_tableSourceData valueForKey:@"CURRYR"] forCurrencyCode:selectedSalesTypeCurrencyCode];
                
                break;
                
            default:
                break;
        }
        
        return cell;
    }
    else {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:noitemsCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
        
    }
}

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    PCTblGroupModelElement *item = [grpMenuItems objectAtIndex:row];
    return item.descr;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return grpMenuItems.count;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self->currentIndexOnRoll = row;
}

@end
