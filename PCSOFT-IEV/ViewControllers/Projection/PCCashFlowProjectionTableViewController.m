//
//  PCCashFlowProjectionTableViewController.m
//  ERPMobile
//
//  Created by Sameer Ghate on 07/09/14.
//  Copyright (c) 2014 Sameer Ghate. All rights reserved.
//

#import "PCCashFlowProjectionTableViewController.h"
#import "PCProjectionModel.h"
#import "ConnectionHandler.h"
#import "PCProjectionTableViewCell.h"
#import "PCProjectionGraphViewController.h"

@implementation CFPInhandCell

@end

@interface PCCashFlowProjectionTableViewController () <ConnectionHandlerDelegate, UITableViewDelegate, UITableViewDataSource>

{
    UIRefreshControl *refreshControl;
    NSMutableArray *projectionArray;
    NSString *lastRefreshTime;
}

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end

@implementation PCCashFlowProjectionTableViewController

//- (id)initWithStyle:(UITableViewStyle)style
//{
//    self = [super initWithStyle:style];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = TRUE;
    
    [self setTitle:@"Cash Flow Projection"];
    self.navigationItem.hidesBackButton = YES;
    
    UIBarButtonItem *barbtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu_icon.png"] style:UIBarButtonItemStylePlain target:self action:@selector(showSideMenu)];
    
    self.navigationItem.leftBarButtonItem = barbtn;
    
    UIBarButtonItem *rightBarbtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"graph.png"] style:UIBarButtonItemStylePlain target:self action:@selector(flipViewToShowGraph)];
    self.navigationItem.rightBarButtonItem = rightBarbtn;
    
    if (!refreshControl) {
        refreshControl = [[UIRefreshControl alloc] init];
        [refreshControl addTarget:self action:@selector(refreshCashFlow) forControlEvents:UIControlEventValueChanged];
        
//        [self setRefreshControl:refreshControl];
    }
    
    [self refreshCashFlow];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSString*)getCurrentMonthInhand
{
    NSArray *sortedArray;
    sortedArray = [projectionArray sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"MMM-yyyy"];
        
        NSDate *first = [dateFormat dateFromString:[(PCProjectionModel*)a MTH]];
        NSDate *second = [dateFormat dateFromString:[(PCProjectionModel*)b MTH]];
        return [first compare:second];
    }];
    
    PCProjectionModel *model = [sortedArray objectAtIndex:0];
    return [Utility stringWithCurrencySymbolForValue:[NSString stringWithFormat:@"%@", model.INHANDAMT] forCurrencyCode:DEFAULT_CURRENCY_CODE];
}

-(IBAction)flipViewToShowGraph
{
    PCProjectionGraphViewController *graphVC = [kStoryboard instantiateViewControllerWithIdentifier:@"PCProjectionGraphViewController"];
    
    if (projectionArray.count == 0) {
        
        [Utility showAlertWithTitle:@"Data not available" message:@"No sufficient data to present a graph.\nTry refreshing again." buttonTitle:@"OK" inViewController:self];
        
        return;
    }
    
    [graphVC setProjectionData:projectionArray];
    
    graphVC.modalPresentationStyle = UIModalPresentationCurrentContext;
    graphVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    [self presentViewController:graphVC animated:YES completion:NULL];
    
}


-(void)refreshCashFlow
{
    AppDelegate *appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    ConnectionHandler *handler = [[ConnectionHandler alloc] init];
    handler.delegate = self;
    
    [refreshControl beginRefreshing];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd"];
    NSString *today = [df stringFromDate:[NSDate date]];
    NSString *url = [NSString stringWithFormat:@"%@GetCashFlow?scocd=%@&sDate=%@",appDel.baseURL,appDel.selectedCompany.CO_CD,today];

    [handler fetchDataForURL:url body:nil];//2014-04-15
}

-(IBAction)showSideMenu
{
    AppDelegate *appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    [appDel.slideViewController showLeftViewControllerAnimated:YES];
}

-(void)connectionHandler:(ConnectionHandler*)conHandler didRecieveData:(NSData*)data
{
    NSError *error = nil;
    NSArray *arr = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    
    projectionArray = [[NSMutableArray alloc] init];
    
    if (arr.count > 0) {
        
        for (NSDictionary *dict in arr) {
            PCProjectionModel *model = [[PCProjectionModel alloc] init];
            [model setValuesForKeysWithDictionary:dict];
            [projectionArray addObject:model];
        }
        
        lastRefreshTime = [Utility lastRefreshString];
    }
    else {
        
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        [refreshControl endRefreshing];
    });
}



-(void)connectionHandler:(ConnectionHandler*)conHandler errorRecievingData:(NSError*)error
{
    if ([error code] == -5000) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [Utility showAlertWithTitle:@"IEV" message:noInternetMessage buttonTitle:@"OK" inViewController:self];
            
        });
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [refreshControl endRefreshing];
    });
}


#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0;
    
    if (projectionArray.count > 0) {
        
        if (indexPath.section == 0) {
            
            height =  145;
        }
        else {
            height = 145;;
        }
    }
    else {
        height = 44;
    }
    
    return height;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    
    if (projectionArray.count > 0) {
        return 2;
    }
    
    return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    if (projectionArray.count > 0) {
        
        if (section == 0) {
            return 1;
        }
        else {
            return projectionArray.count;
        }
    }
    else {
        return 1;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"CellIdentifier";
    static NSString *identifier1 = @"BlankCell";
    static NSString *inhandCellIdentifier = @"CFPInhandCell";
    
    UITableViewCell *returnCell;
    
    
    if (projectionArray.count == 0) {
        UITableViewCell *cell1 = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier1];
        cell1.textLabel.text = @"No cash flow projection data available.";
        cell1.backgroundColor = [UIColor clearColor];
        cell1.textLabel.font = [UIFont boldSystemFontOfSize:12];
        cell1.textLabel.textColor = [UIColor darkGrayColor];
        cell1.textLabel.textAlignment = NSTextAlignmentCenter;
        cell1.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell1;
    }
    
    switch (indexPath.section) {
        case 0:
            
        {
            CFPInhandCell *inhandcell = [tableView dequeueReusableCellWithIdentifier:inhandCellIdentifier];
            
            inhandcell.inhandLabel.text = [self getCurrentMonthInhand];
            
            returnCell = inhandcell;
        }
            
            break;
            
        case 1:
        {
            
            PCProjectionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
            
            PCProjectionModel *model = [projectionArray objectAtIndex:indexPath.row];
            
            cell.monthLabel.text = model.MTH;
            cell.payableLabel.text = [Utility stringWithCurrencySymbolForValue:[NSString stringWithFormat:@"%@", model.PAYABLE] forCurrencyCode:DEFAULT_CURRENCY_CODE];
            cell.recievableLabel.text = [Utility stringWithCurrencySymbolForValue:[NSString stringWithFormat:@"%@",model.RECEIVABLE] forCurrencyCode:DEFAULT_CURRENCY_CODE];
            
            // Configure the cell...
            
            returnCell = cell;
            
        }
            break;
            
            
        default:
            break;
    }
    
    
    return returnCell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *returnView;
    
    if (section == 1) {
        UILabel *footerLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
        footerLbl.textAlignment = NSTextAlignmentCenter;
        footerLbl.font = [UIFont systemFontOfSize:13];
        footerLbl.textColor = [UIColor darkGrayColor];
        if (lastRefreshTime != nil) {
            footerLbl.text = [NSString stringWithFormat:@"Last updated : %@",lastRefreshTime];
        }
        else {
            footerLbl.text = [NSString stringWithFormat:@""];
        }
        footerLbl.backgroundColor = [UIColor clearColor];
        
        returnView =  footerLbl;
    }
    return returnView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 1) {
        return 30.0f;
    }
    return 0.0f;
}

@end
