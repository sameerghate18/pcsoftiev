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

@interface PCDailySalesViewController () <ConnectionHandlerDelegate, UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *dailySales;
    NSString *currentMonth, *lastMonth, *previousToLastMonth;
    SalesType salesType;
    NSString *selectedSalesTypeCurrencyCode;
    NSString *lastRefreshTime;
}

@property (nonatomic, strong) IBOutlet UILabel *todaysSales, *totalSales, *lastUpdateLabel;
@property (nonatomic, weak) IBOutlet UIImageView *boxImgView1, *boxImgView2;

@property (nonatomic, weak) IBOutlet UIButton *refreshBtn;

@property (nonatomic, weak) IBOutlet UITableView *salesTable;

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
    
    [self fetchDailySalesData:nil];
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

-(IBAction)fetchDailySalesData:(id)sender
{
    AppDelegate *appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    [SVProgressHUD showWithStatus:@"Loading data..." maskType:SVProgressHUDMaskTypeBlack];
    ConnectionHandler *handler = [[ConnectionHandler alloc] init];
    handler.delegate = self;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *companyCode = [defaults valueForKey:kSelectedCompanyCode];
    
    NSString *url = [NSString stringWithFormat:@"%@/%@%@",appDel.baseURL,kCompanySalesService,companyCode];
    
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
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[dailySales objectAtIndex:0]];
            if ([[dict valueForKey:@"CUR_DESC"] rangeOfString:@"RUPEE"].location != NSNotFound) {
                [dict setValue:@"INR" forKey:@"CUR_DESC"];
            }
            
            if (dailySales.count > 1) {
                
                NSMutableDictionary *exportDict = [NSMutableDictionary dictionaryWithDictionary:[dailySales objectAtIndex:1]];
                
                if ([[exportDict valueForKey:@"CUR_DESC"] rangeOfString:@"RUPEE"].location != NSNotFound) {
                    [exportDict setValue:@"INR" forKey:@"CUR_DESC"];
                }
                
                _exportSalesData = [[NSDictionary alloc] initWithDictionary:exportDict copyItems:YES];
            }
            
            _salesData = [[NSDictionary alloc] initWithDictionary:dict copyItems:YES];
            
            _lastUpdateLabel.text = [NSString stringWithFormat:@"Last updated : %@",[Utility lastRefreshString]];
            
            [self getDates];
            
            if (salesType == SalesTypeDomestic) {
                selectedSalesTypeCurrencyCode = [_salesData valueForKey:@"CUR_DESC"];
                _tableSourceData = _salesData;
            }
            else {
                selectedSalesTypeCurrencyCode = [_exportSalesData valueForKey:@"CUR_DESC"];
                _tableSourceData = _exportSalesData;
            }
            
            lastRefreshTime = [Utility lastRefreshString];
            
            [_salesTable reloadData];
        });
    }
    else {
    [SVProgressHUD showErrorWithStatus:@"Failed"];
    }
}

-(void)connectionHandler:(ConnectionHandler*)conHandler errorRecievingData:(NSError*)error
{
    if ([error code] == -5000) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [SVProgressHUD dismiss];
            
            [Utility showAlertWithTitle:@"IEV" message:@"Internet connection appears to be unavailable.\nPlease check your connection and try again." buttonTitle:@"OK" inViewController:self];
            
        });
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD showErrorWithStatus:@"Failed"];
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

@end
