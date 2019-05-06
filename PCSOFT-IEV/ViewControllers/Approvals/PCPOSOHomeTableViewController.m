//
//  PCPOSOHomeTableViewController.m
//  ERPMobile
//
//  Created by Sameer Ghate on 11/10/14.
//  Copyright (c) 2014 Sameer Ghate. All rights reserved.
//

#import "PCPOSOHomeTableViewController.h"
#import "PCPOSOTransactionsTableViewController.h"
#import "PCApprovalListModel.h"
#import <QuartzCore/QuartzCore.h>
#import "ConnectionHandler.h"

@interface PCPOSOHomeTableViewController () <UITableViewDataSource, UITableViewDelegate>

{
    NSArray *titles, *images, *codes;
    TXType txtype;
    NSMutableDictionary *authCountDict, *titleDict;
    NSMutableArray *unreadCounts, *titleArray;
}

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end

@implementation PCPOSOHomeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    titleDict = [[NSMutableDictionary alloc] init];
    
    UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_home.png"]];
    self.tableView.backgroundView = bg;
    
    [self setTitle:@"Authorizations"];
    
    titleArray = [[NSMutableArray alloc] init];

    [self getExpenseListCount];
    
    self.tableView.layer.cornerRadius = 10.0;
    self.tableView.layer.masksToBounds = YES;
    self.tableView.layer.borderWidth = 1.0;
    self.tableView.layer.borderColor = [UIColor blackColor].CGColor;
    
//    self.tableView.layer.shadowColor = [UIColor blackColor].CGColor;
//    self.tableView.layer.shadowOpacity = 0.8;
//    self.tableView.layer.shadowRadius = 10;
//    self.tableView.layer.shadowOffset = CGSizeMake(20.0f, 22.0f);
    
    UIBarButtonItem *barbtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu_icon.png"]
                                                               style:UIBarButtonItemStylePlain
                                                              target:self
                                                              action:@selector(showSideMenu)];
    
    self.navigationItem.leftBarButtonItem = barbtn;
    
//    [self.tableView reloadData];
}

- (void)getExpenseListCount {
    AppDelegate *appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *url = GET_EECount_URL(appDel.baseURL, appDel.selectedCompany.CO_CD, appDel.loggedUser.USER_ID);
    
    ConnectionHandler *conn = [[ConnectionHandler alloc] init];
    
    [conn fetchDataForGETURL:url body:nil completion:^(id responseData, NSError *error) {
        
        NSArray  *arr = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (arr.count > 0) {
                
                for (NSDictionary *dict in arr) {
                    PCApprovalListModel *model = [[PCApprovalListModel alloc] initWithDictionary:dict];
                    [titleArray addObject:model];
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
    return titleArray.count;
}

static NSString *reuseIdentifier = @"txCell";

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    PCApprovalListModel *listModel = [titleArray objectAtIndex:indexPath.row];
    cell.textLabel.text = listModel.doc_desc;
    NSInteger count = [listModel.seq_no integerValue];

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
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setSelected:NO];
    PCApprovalListModel *selectedModel = [titleArray objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"transactionListSegue" sender:selectedModel];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"transactionListSegue"]) {
        PCApprovalListModel *selectedModel = (PCApprovalListModel*)sender;
        PCPOSOTransactionsTableViewController *txList = (PCPOSOTransactionsTableViewController*)[segue destinationViewController];
        [txList setSelectedApprovalType:selectedModel];
    }
}


@end
