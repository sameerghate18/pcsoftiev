//
//  PCInvoicesTableViewController.m
//  ERPMobile
//
//  Created by Sameer Ghate on 07/09/14.
//  Copyright (c) 2014 Sameer Ghate. All rights reserved.
//

#import "PCInvoicesTableViewController.h"
#import "PCProjectionTableViewCell.h"
#import "ConnectionHandler.h"

@interface PCInvoicesTableViewController () <ConnectionHandlerDelegate>
{
    UIRefreshControl *refreshControl;
    NSMutableArray *invoicesArray;
    NSString *lastRefreshTime;
}
@end

@implementation PCInvoicesTableViewController

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
    
    [self setTitle:@"Invoices"];
    
    self.navigationItem.hidesBackButton = YES;
    
    UIBarButtonItem *barbtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu_icon.png"] style:UIBarButtonItemStylePlain target:self action:@selector(showSideMenu)];
    
    self.navigationItem.leftBarButtonItem = barbtn;
    
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshInvoices) forControlEvents:UIControlEventValueChanged];
    
    [self setRefreshControl:refreshControl];
    
    [self refreshInvoices];
}


-(void)showSideMenu
{
    AppDelegate *appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    [appDel.slideViewController showLeftViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)refreshInvoices
{
    AppDelegate *appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    ConnectionHandler *handler = [[ConnectionHandler alloc] init];
    handler.delegate = self;
    
    [refreshControl beginRefreshing];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"YYYY-MM-dd"];
    
    NSString *url = [NSString stringWithFormat:@"%@/%@%@",appDel.baseURL,kInvoicesService,appDel.selectedCompany.CO_CD];
    
    NSDictionary *postDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              appDel.selectedCompany.CO_CD, kScoCodeKey,
                              nil];
    
    [handler fetchDataForURL:[NSString stringWithFormat:@"%@/iev/GetInvoice",appDel.baseURL] body:postDict];//2014-04-15
}

-(void)connectionHandler:(ConnectionHandler*)conHandler didRecieveData:(NSData*)data
{
    NSError *error = nil;
    NSArray *arr = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    
    if (arr.count > 0) {
        
//        for (NSDictionary *dict in arr) {
//            PCProjectionModel *model = [[PCProjectionModel alloc] init];
//            [model setValuesForKeysWithDictionary:dict];
//            [projectionArray addObject:model];
//        }
        
        invoicesArray = [[NSMutableArray alloc] initWithArray:arr copyItems:YES];
        
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 260.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"CellIdentifier";
    static NSString *identifier1 = @"BlankCell";
    
    if (invoicesArray.count == 0) {
        UITableViewCell *cell1 = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier1];
        cell1.textLabel.text = @"No invoices available.";
        cell1.backgroundColor = [UIColor clearColor];
        cell1.textLabel.font = [UIFont boldSystemFontOfSize:12];
        cell1.textLabel.textColor = [UIColor colorNamed:kCustomGray];
        cell1.textLabel.textAlignment = NSTextAlignmentCenter;
        return cell1;
    }
    else{
        
        
        PCProjectionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
        
        NSDictionary *model = [invoicesArray objectAtIndex:indexPath.row];
        
//        cell.monthLabel.text = [model valueForKey:@""];
        cell.payableLabel.text = [Utility stringWithCurrencySymbolForValue:[model valueForKey:@"PREV_AMT"] forCurrencyCode:DEFAULT_CURRENCY_CODE];
        cell.recievableLabel.text = [Utility stringWithCurrencySymbolForValue:[model valueForKey:@"CURR_AMT"] forCurrencyCode:DEFAULT_CURRENCY_CODE];
        
        // Configure the cell...
        
        return cell;
    }
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
