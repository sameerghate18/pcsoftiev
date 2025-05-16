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

@implementation PCPOSOTransactionsTableViewCell
@end

@interface PCPOSOTransactionsTableViewController () <ConnectionHandlerDelegate, UITableViewDelegate, UITableViewDataSource>
{
  UIRefreshControl *refreshControl;
  NSMutableArray *transactionsList;
  AppDelegate *appDel;
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
  self.tableView.layer.borderColor = [UIColor colorNamed:kCustomBlack].CGColor;
  
  appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
  
  [self setTitle:self.selectedApprovalType.doc_desc];
  self.typeLabel.text =self.selectedApprovalType.doc_desc;
  
  self.navigationItem.hidesBackButton = YES;
  
  UIBarButtonItem *barbtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu_icon.png"]
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(showSideMenu)];
  
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
  [SVProgressHUD showWithStatus:@"Getting authorization list..."];
  
  ConnectionHandler *handler = [[ConnectionHandler alloc] init];
  handler.delegate = self;
  
  NSString *url = GET_Auths_List_URL(appDel.baseURL,
                                     appDel.selectedCompany.CO_CD,
                                     appDel.loggedUser.USER_ID,
                                     self.selectedApprovalType.doc_type);
  
  NSLog(@"\ngetAllTransactions - %@\n", url);
    
    NSDictionary *postDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              appDel.selectedCompany.CO_CD, kScoCodeKey,
                              appDel.loggedUser.USER_ID,@"USERID",
                              self.selectedApprovalType.doc_type,@"type",
                              nil];
  
  [handler fetchDataForURL:[NSString stringWithFormat:@"%@/iev/authlist",appDel.baseURL] body:postDict];
}

-(void)connectionHandler:(ConnectionHandler*)conHandler didRecieveData:(NSData*)data
{
    if (!transactionsList) {
        transactionsList = [[NSMutableArray alloc] init];
    }
    
    [transactionsList removeAllObjects];
    
    NSError *error = nil;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    
    NSArray *arr = [dict objectForKey:kDataKey];
    
    for (NSDictionary *dict in arr) {
        
        PCTransactionModel *cMod = [[PCTransactionModel alloc] init];
        [cMod setValuesForKeysWithDictionary:dict];
        cMod.doc_type = [cMod.doc_type stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        cMod.user_name = [cMod.user_name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [transactionsList addObject:cMod];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->refreshControl endRefreshing];
        [SVProgressHUD showSuccessWithStatus:@"Done"];
        [self.tableView reloadData];
    });
    
    
    if (transactionsList.count == 0) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showErrorWithStatus:@"No Authorizations"];
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No authorizations" message:@"No authorizations available at the moment." preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction * okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                NSArray *vcArr = self.navigationController.viewControllers;
                
                if ([[vcArr objectAtIndex:vcArr.count-2] isKindOfClass:[PCPOSOHomeTableViewController class]]) {
                    
                    [self.navigationController popViewControllerAnimated:YES];
                }
                else {
                    [self showSideMenu];
                }
            }];
            
            UIAlertAction * retryAction = [UIAlertAction actionWithTitle:@"Retry" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                [self refreshPOSO];
                
            }];
            
            [alert addAction:okAction];
            [alert addAction:retryAction];
            
            [self presentViewController:alert animated:YES completion:nil];
        });
        return;
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
  return 100;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *identifier = @"TransactionIdentifier";
  
  PCPOSOTransactionsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
  
  PCTransactionModel *model = [transactionsList objectAtIndex:indexPath.row];
  
  cell.selectionStyle = UITableViewCellSelectionStyleDefault;
  cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  
    if (model.party_name.length > 0) {
        cell.titleLabel.text = model.party_name;
    } else {
        cell.titleLabel.text = model.doc_desc;
    }
    
//  if (cell == nil) {
//    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
//    cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
//    cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:11];
//    [cell.detailTextLabel setTextColor:[UIColor darkGrayColor]];
//    cell.backgroundColor = [UIColor clearColor];
//    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
//    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//  }
//
//  cell.textLabel.text = model.doc_desc;
  
  if ([self.selectedApprovalType.doc_type isEqualToString:@"EP"]) {
    if (model.doc_no.length > 0) {
      cell.docNumberLabel.text = model.doc_no;
    } else {
      cell.docNumberLabel.text = model.party_name;
    }
    
  } else {
    if (model.party_name.length > 0) {
      cell.titleLabel.text = model.party_name;
//      cell.docNumberLabel.text = model.party_name;
      cell.docNumberLabel.text = model.doc_no;
    } else {
      cell.docNumberLabel.text = model.doc_no;
    }
  }
    
    cell.docUsernameLabel.text = [model.UserName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  
  NSString *dateStr = [Utility stringDateFromServerDate:model.doc_date];
  cell.dateLabel.text = dateStr;//model.doc_date;
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  PCTransactionModel *model = [transactionsList objectAtIndex:indexPath.row];
  
  if ([self.selectedApprovalType.doc_type isEqualToString:@"EP"]) {
    [self performSegueWithIdentifier:@"listToExpenseSegue" sender:model];
  }
  else {
    [self performSegueWithIdentifier:@"listToDetailSegue" sender:model];
  }
}

#pragma mark - Alertview Delegate

//- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
//{
//  switch (alertView.tag) {
//    case 100:
//      if (buttonIndex == 1) {
//        [self refreshPOSO];
//      }
//      else if (buttonIndex == 0) {
//        NSArray *vcArr = self.navigationController.viewControllers;
//        
//        if ([[vcArr objectAtIndex:vcArr.count-2] isKindOfClass:[PCPOSOHomeTableViewController class]]) {
//          
//          [self.navigationController popViewControllerAnimated:YES];
//        }
//        else {
//          [self showSideMenu];
//        }
//      }
//      break;
//      
//    default:
//      break;
//  }
//}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  
  PCTransactionModel *model = (PCTransactionModel*)sender;
  if ([segue.identifier isEqualToString:@"listToExpenseSegue"]) {
    PCEmployeeExpenseViewController *empExpVC = segue.destinationViewController;
    [empExpVC setSelectedTransaction:model];
  }
  else if ([segue.identifier isEqualToString:@"listToDetailSegue"])  {
    PCSingleTransactionViewController *detailVC = segue.destinationViewController;
    [detailVC setSelectedTransaction:model];
  }
}

@end
