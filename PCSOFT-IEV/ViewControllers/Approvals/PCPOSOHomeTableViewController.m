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
    NSArray *titles, *images, *codes;
    TXType txtype;
    NSUInteger empExpCount;
    NSMutableDictionary *authCountDict, *titleDict;
    NSMutableArray *unreadCounts, *titleArray;
}

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end

@implementation PCPOSOHomeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    titleDict = [[NSMutableDictionary alloc] init];
    empExpCount = 0;
//    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_home.png"]];
    
    UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_home.png"]];
    self.tableView.backgroundView = bg;
    
    [self setTitle:@"Authorizations"];
    
    titles = @[@"Purchase Indents",@"Purchase Order", @"Sale Order", @"Expense Booking", @"Bills Passing", @"Payments", @"Employee Expense"];
    images = @[@"PI-icon",@"PO-icon.png",@"SO-icon.png",@"EB-icon.png",@"BP-icon.png",@"Payment-icon.png", @"Payment-icon.png"];
    codes = @[@"PI", @"PO", @"SO", @"CPURCHASE", @"RBILL", @"PAYMENT", @"EP"];
    
    titleArray = [[NSMutableArray alloc] init];
    
    for (int index = 0; index < titles.count; index++) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setObject:titles[index] forKey:@"title"];
        [dict setObject:images[index] forKey:@"image"];
        [dict setObject:codes[index] forKey:@"code"];
        [dict setObject:@"0" forKey:@"unreadCount"];
        [titleArray addObject:dict];
    }

    [self getExpenseListCount];
    
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
    
//    [self.tableView reloadData];
}

- (void)getExpenseListCount {
    AppDelegate *appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *url = GET_EECount_URL(appDel.baseURL, appDel.selectedCompany.CO_CD, appDel.loggedUser.USER_ID);
    
    ConnectionHandler *conn = [[ConnectionHandler alloc] init];
    
    [conn fetchDataForGETURL:url body:nil completion:^(id responseData, NSError *error) {
        
        NSString *count = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        NSLog(@"getExpenseListCount - %@", count);
        NSArray  *arr = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (arr.count > 0) {
                
                if (!authCountDict) {
                    authCountDict = [[NSMutableDictionary alloc] init];
                }
                [authCountDict removeAllObjects];
                
                for (NSDictionary *dict in arr) {
                    [authCountDict setObject:[NSString stringWithFormat:@"%@",dict[@"seq_no"]] forKey:dict[@"doc_desc"]];
                }
                
                for (int idx = 0; idx < titleArray.count; idx++) {
                    NSMutableDictionary *dictObj = titleArray[idx];
                    [dictObj setValue:authCountDict[dictObj[@"code"]] forKey:@"unreadCount"];
                }

                [self.tableView reloadData];
            }
        });
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
    
    NSDictionary *dict = [titleArray objectAtIndex:indexPath.row];
    cell.textLabel.text = dict[@"title"];
    [cell.imageView setImage:[UIImage imageNamed:dict[@"image"]]];
    NSInteger count = [dict[@"unreadCount"] integerValue];

     CGFloat fontSize = 15;
     UILabel *label = [[UILabel alloc] init];
     label.font = [UIFont boldSystemFontOfSize:fontSize];
     label.textAlignment = NSTextAlignmentCenter;
     label.textColor = [UIColor whiteColor];
     label.backgroundColor = [UIColor redColor];
    
     // Add count to label and size to fit
     label.text = [NSString stringWithFormat:@"%lu", (unsigned long)count];
     [label sizeToFit];
    
     // Adjust frame to be square for single digits or elliptical for numbers > 9
     CGRect frame = label.frame;
     frame.size.height += (int)(0.4*fontSize);
     frame.size.width = (count <= 9) ? frame.size.height : frame.size.width + (int)fontSize;
     label.frame = frame;
    
     // Set radius and clip to bounds
     label.layer.cornerRadius = frame.size.height/2.0;
     label.clipsToBounds = true;
    
     // Show label in accessory view and remove disclosure
    
    if (count > 0) {
        cell.accessoryView = label;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

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
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setSelected:NO];
    
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
