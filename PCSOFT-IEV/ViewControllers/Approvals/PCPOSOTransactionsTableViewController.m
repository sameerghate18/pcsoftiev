//
//  PCPOSOTransactionsTableViewController.m
//  ERPMobile
//
//  Created by Sameer Ghate on 09/09/14.
//  Copyright (c) 2014 Sameer Ghate. All rights reserved.
//

#import "PCPOSOTransactionsTableViewController.h"
#import "ConnectionHandler.h"
#import "PCTransactionModel.h"
#import "SVProgressHUD.h"
#import "PCSingleTransactionViewController.h"
#import "PCPOSOHomeTableViewController.h"
#import "PCEmployeeExpenseViewController.h"

@interface PCPOSOTransactionsTableViewController () <ConnectionHandlerDelegate, UITableViewDelegate, UITableViewDataSource>
{
    UIRefreshControl *refreshControl;
    NSMutableArray *transactionsList;
    AppDelegate *appDel;
    TXType txtype;
}

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UILabel *typeLabel;
@property (nonatomic, weak) IBOutlet UIImageView *typeImageview;


@end

@implementation PCPOSOTransactionsTableViewController

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
    
    self.tableView.layer.cornerRadius = 10.0;
    self.tableView.layer.masksToBounds = YES;
    self.tableView.layer.borderWidth = 1.0;
    self.tableView.layer.borderColor = [UIColor blackColor].CGColor;
    
//    self.tableView.layer.shadowColor = [UIColor blackColor].CGColor;
//    self.tableView.layer.shadowOpacity = 0.8;
//    self.tableView.layer.shadowRadius = 10;
//    self.tableView.layer.shadowOffset = CGSizeMake(20.0f, 22.0f);
    
    appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    switch (self.selectedTXType) {
            
        case TXTypePO:
            [self setTitle:@"Purchase Order"];
            self.typeLabel.text = @"PURCHASE ORDER";
            self.typeImageview.image = [UIImage imageNamed:@"PO-icon.png"];
            txtype = TXTypePO;
            break;
            
        case TXTypeSO:
            [self setTitle:@"SALE ORDER"];
            self.typeLabel.text = @"SALE ORDER";
            self.typeImageview.image = [UIImage imageNamed:@"SO-icon.png"];
            txtype = TXTypeSO;
            break;
            
        case TXTypePayments:
            [self setTitle:@"Payments"];
            self.typeLabel.text = @"PAYMENTS";
            self.typeImageview.image = [UIImage imageNamed:@"Payment-icon.png"];
            txtype = TXTypePayments;
            break;
            
        case TXTypePI:
            [self setTitle:@"Purchase Indents"];
            self.typeLabel.text = @"PURCHASE INDENTS";
            self.typeImageview.image = [UIImage imageNamed:@"PI-icon"];
            txtype = TXTypePI;
            break;
            
        case TXTypeRB:
            [self setTitle:@"Bills Passing"];
            self.typeLabel.text = @"BILL PASSING";
            self.typeImageview.image = [UIImage imageNamed:@"BP-icon"];
            txtype = TXTypeRB;
            break;
            
        case TXTypePCR:
            [self setTitle:@"Expense Booking"];
            self.typeLabel.text = @"EXPENSE BOOKING";
            self.typeImageview.image = [UIImage imageNamed:@"EB-icon"];
            txtype = TXTypePCR;
            break;
            
        case TXTypeEmployeeExpense:
            [self setTitle:@"Employee Expense"];
            self.typeLabel.text = @"EMPLOYEE EXPENSE";
            self.typeImageview.image = [UIImage imageNamed:@"EB-icon"];
            txtype = TXTypeEmployeeExpense;
            break;
            
        default:
            break;
    }
    
    self.navigationItem.hidesBackButton = YES;
    
    UIBarButtonItem *barbtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu_icon.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(showSideMenu)];
    
    self.navigationItem.leftBarButtonItem = barbtn;
    
    
    
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshPOSO) forControlEvents:UIControlEventValueChanged];
    
//    [self setRefreshControl:refreshControl];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self refreshPOSO];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)refreshPOSO
{
    [SVProgressHUD showWithStatus:@"Getting transactions"];
    
    ConnectionHandler *handler = [[ConnectionHandler alloc] init];
    handler.delegate = self;
    
    NSString *url;

    NSString *txtypeString;
    
    switch (self.selectedTXType) {
            
        case TXTypePO:
            
            txtypeString = @"PO";
            break;
            
        case TXTypeSO:
            txtypeString = @"SO";
            break;
            
        case TXTypePCR:
            txtypeString = @"cpurchase";
            break;
            
        case TXTypeRB:
            txtypeString = @"rbill";
            break;
            
        case TXTypePayments:
            txtypeString = @"PAYMENT";
            break;
            
        case TXTypePI:
            txtypeString = @"PI";
            break;
            
        case TXTypeEmployeeExpense:
            txtypeString = @"EP";
            break;
            
        default:
            break;
    }
    
    url = [NSString stringWithFormat:@"%@/authlist?scocd=%@&userid=%@&type=%@",
           appDel.baseURL,
           appDel.selectedCompany.CO_CD,
           appDel.loggedUser.USER_ID,
           txtypeString];
    
    [handler fetchDataForURL:url body:nil];
}

-(void)connectionHandler:(ConnectionHandler*)conHandler didRecieveData:(NSData*)data
{
    if (!transactionsList) {
        transactionsList = [[NSMutableArray alloc] init];
    }
    
    [transactionsList removeAllObjects];
    
    NSError *error = nil;
    NSArray *arr = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    
    for (NSDictionary *dict in arr) {
        
        PCTransactionModel *cMod = [[PCTransactionModel alloc] init];
        [cMod setValuesForKeysWithDictionary:dict];
        [transactionsList addObject:cMod];
    }

    
    if (transactionsList.count == 0) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showErrorWithStatus:@"No Authorizations"];
            UIAlertView *noCompList = [[UIAlertView alloc] initWithTitle:@"No authorizations" message:@"No authorizations available at the moment." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Retry",nil];
            noCompList.tag = 100;
            [noCompList show];
        });
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [refreshControl endRefreshing];
        [SVProgressHUD showSuccessWithStatus:@"Done"];
        [self.tableView reloadData];
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
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [refreshControl endRefreshing];
    });
}

-(IBAction)showSideMenu
{
    appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    [appDel.slideViewController showLeftViewControllerAnimated:YES];
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
    return transactionsList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"TransactionIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    PCTransactionModel *model = [transactionsList objectAtIndex:indexPath.row];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
        cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:11];
        [cell.detailTextLabel setTextColor:[UIColor darkGrayColor]];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.textLabel.text = model.doc_desc;
    
    if (txtype == TXTypeEmployeeExpense) {
        cell.detailTextLabel.text = model.doc_no;
    }
    else {
        cell.detailTextLabel.text = model.party_name;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PCTransactionModel *model = [transactionsList objectAtIndex:indexPath.row];
    
    if (txtype == TXTypeEmployeeExpense) {
        [self performSegueWithIdentifier:@"listToExpenseSegue" sender:model];
    }
    else {
        [self performSegueWithIdentifier:@"listToDetailSegue" sender:model];
    }
}

#pragma mark - Alertview Delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case 100:
            if (buttonIndex == 1) {
                [self refreshPOSO];
            }
            else if (buttonIndex == 0) {
                NSArray *vcArr = self.navigationController.viewControllers;
                
                if ([[vcArr objectAtIndex:vcArr.count-2] isKindOfClass:[PCPOSOHomeTableViewController class]]) {
                    
                    [self.navigationController popViewControllerAnimated:YES];
                }
                else {
                    [self showSideMenu];
                }
            }
            break;
            
        default:
            break;
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    PCTransactionModel *model = (PCTransactionModel*)sender;
    if ([segue.identifier isEqualToString:@"listToExpenseSegue"]) {
        PCEmployeeExpenseViewController *empExpVC = segue.destinationViewController;
        [empExpVC setSelectedTransaction:model];
    }
    else if ([segue.identifier isEqualToString:@"listToExpenseSegue"])  {
        PCSingleTransactionViewController *detailVC = segue.destinationViewController;
        [detailVC setSelectedTransaction:model];
        detailVC.txType = txtype;
    }
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
