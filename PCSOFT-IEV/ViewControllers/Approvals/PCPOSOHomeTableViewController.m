//
//  PCPOSOHomeTableViewController.m
//  ERPMobile
//
//  Created by Sameer Ghate on 11/10/14.
//  Copyright (c) 2014 Sameer Ghate. All rights reserved.
//

#import "PCPOSOHomeTableViewController.h"
#import "PCPOSOTransactionsTableViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ConnectionHandler.h"

@interface PCPOSOHomeTableViewController () <UITableViewDataSource, UITableViewDelegate>

{
    NSArray *titles, *images;
    TXType txtype;
}

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end

@implementation PCPOSOHomeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self getExpenseListCount];
//    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_home.png"]];
    
    UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_home.png"]];
    self.tableView.backgroundView = bg;
    
    [self setTitle:@"Authorizations"];
    
    titles = @[@"Purchase Indents",@"Purchase Order", @"Sale Order", @"Expense Booking", @"Bills Passing", @"Payments", @"Employee Expense"];
    images = @[@"PI-icon",@"PO-icon.png",@"SO-icon.png",@"EB-icon.png",@"BP-icon.png",@"Payment-icon.png", @"Payment-icon.png"];

    self.tableView.layer.cornerRadius = 10.0;
    self.tableView.layer.masksToBounds = YES;
    self.tableView.layer.borderWidth = 1.0;
    self.tableView.layer.borderColor = [UIColor blackColor].CGColor;
    
//    self.tableView.layer.shadowColor = [UIColor blackColor].CGColor;
//    self.tableView.layer.shadowOpacity = 0.8;
//    self.tableView.layer.shadowRadius = 10;
//    self.tableView.layer.shadowOffset = CGSizeMake(20.0f, 22.0f);
    
    UIBarButtonItem *barbtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu_icon.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(showSideMenu)];
    
    self.navigationItem.leftBarButtonItem = barbtn;
    
    [self.tableView reloadData];
}

- (void)getExpenseListCount {
    AppDelegate *appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *url = GET_EECount_URL(appDel.baseURL, appDel.selectedCompany.CO_CD, appDel.loggedUser.USER_ID);
    
    ConnectionHandler *conn = [[ConnectionHandler alloc] init];
    
    [conn fetchDataForGETURL:url body:nil completion:^(id responseData, NSError *error) {
        
        NSString *count = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        NSLog(@"getExpenseListCount - %@", count);
//        NSString  *arr = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&error];
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)showSideMenu
{
    AppDelegate *appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    [appDel.slideViewController showLeftViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return titles.count;
}

static NSString *reuseIdentifier = @"txCell";

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    cell.textLabel.text = titles[indexPath.row];
    [cell.imageView setImage:[UIImage imageNamed:images[indexPath.row]]];
    
    // Configure the cell...
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    switch (indexPath.row) {
            
        case 0:
            txtype = TXTypePI;
            break;
            
        case 1:
            txtype = TXTypePO;
            break;
            
        case 2:
            txtype = TXTypeSO;
            break;
            
        case 3:
            txtype = TXTypePCR;
            break;
            
        case 4:
            txtype = TXTypeRB;
            break;
            
        case 5:
            txtype = TXTypePayments;
            break;
            
        case 6:
            txtype = TXTypeEmployeeExpense;
            break;
            
        default:
            break;
    }
    
    [self performSegueWithIdentifier:@"transactionListSegue" sender:nil];
//    PCPOSOTransactionsTableViewController *txList = (PCPOSOTransactionsTableViewController*)[kStoryboard instantiateViewControllerWithIdentifier:@"PCPOSOTransactionsTableViewController"];
//    [txList setSelectedTXType:txtype];
//    [self.navigationController pushViewController:txList animated:YES];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"transactionListSegue"]) {
        PCPOSOTransactionsTableViewController *txList = (PCPOSOTransactionsTableViewController*)[segue destinationViewController];
        [txList setSelectedTXType:txtype];
    }
}


@end
