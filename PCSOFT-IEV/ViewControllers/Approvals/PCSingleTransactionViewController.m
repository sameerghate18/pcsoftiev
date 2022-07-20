//
//  PCSingleTransactionViewController.m
//  ERPMobile
//
//  Created by Sameer Ghate on 04/10/14.
//  Copyright (c) 2014 Sameer Ghate. All rights reserved.
//

#import "PCSingleTransactionViewController.h"
#import "POSOSingleTransactionCell.h"
#import "ConnectionHandler.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"
#import "PCApprovalItemList.h"
#import "MarqueeLabel.h"
#import "PCSendBackViewController.h"

typedef enum {
    ConnectionTypeGetDetails,
    ConnectionTypeAuthorize,
    ConnectionTypeSendBack
}ConnectionType;

@interface PCSingleTransactionViewController () <UITableViewDelegate, UITableViewDataSource, ConnectionHandlerDelegate, UIActionSheetDelegate,PCSendBackViewControllerDelegate>
{
    NSArray *titles_basic, *titles_details;//, *data;
    NSDictionary *tableDataDictionary;
    PCTransactionDetailModel *detailModel;
    ConnectionType connType;
    AppDelegate *appDel;
    NSMutableArray *detailModelsArray;
    PCApprovalItemList *refItemListVC;
    NSArray *purchaseDocTypes;
}

@property (nonatomic, weak) IBOutlet UITableView *detailsTable;
@property (nonatomic, weak) IBOutlet MarqueeLabel *partyNameLabel;
@property (nonatomic, weak) IBOutlet MarqueeLabel *descriptionLabel;
@property (nonatomic, weak) IBOutlet UILabel *valueLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UILabel *docNumberLabel;
@property (nonatomic, weak) IBOutlet UILabel *partyNameTypeLabel;
@property (nonatomic, weak) IBOutlet UILabel *docTaxesLabel;
@property (nonatomic, weak) IBOutlet UIStoryboardSegue *containerSegue;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *doctaxHeightConstraint, *doctaxValueHeightConstraint;

@end

@implementation PCSingleTransactionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  
  purchaseDocTypes = [[NSArray alloc] initWithObjects:@"02",
                 @"05", @"21", @"22", @"23", @"25", @"24",
                 @"33", @"34", @"38", @"47", @"4O", @"37",
                 @"3F", @"64", @"3D", @"30", @"3N", @"69",
                 @"71", @"FP", @"72", @"PM", nil];
    
    self.detailsTable.layer.cornerRadius = 10.0;
    self.detailsTable.layer.masksToBounds = YES;
    self.detailsTable.layer.borderWidth = 1.0;
    self.detailsTable.layer.borderColor = [UIColor blackColor].CGColor;
    
    appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    titles_basic = @[@"Document Description",
                            @"Document number",
                           @"Party name",
                    ];
    
    titles_details = @[@"Description",
                       @"Item",
                       @"Quantity",
                       @"Rate",
                       @"Total",
                       @"Value"];
    
    [self getDetailsForTransaction:_selectedTransaction];
    
}

-(void)viewWillAppear:(BOOL)animated    {
    
    self.doctaxHeightConstraint.constant = 21;
    self.doctaxValueHeightConstraint.constant = 21;
  
  NSString *docType = self.selectedTransaction.doc_type;
  NSString *partyNameLabel = @"Customer:";
  
  if ([docType containsString:@"3E"]) {
    partyNameLabel = @"Employee:";
    self.doctaxHeightConstraint.constant = 0;
    self.doctaxValueHeightConstraint.constant = 0;
  }
  else if ([purchaseDocTypes containsObject:docType]) {
    partyNameLabel = @"Supplier:";
  }
  else if ([docType containsString:@"12"] || [docType containsString:@"16"]) {
    partyNameLabel = @"Bank:";
  }
  else if ([docType containsString:@"11"] || [docType containsString:@"15"]) {
    partyNameLabel= @"Cash:";
  } else {
    partyNameLabel = @"Customer:";
  }
  
  self.partyNameTypeLabel.text = partyNameLabel;
  
}

-(IBAction)pop:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)getDetailsForTransaction:(PCTransactionModel*)model
{
    connType = ConnectionTypeGetDetails;
    
    ConnectionHandler *conn = [[ConnectionHandler alloc] init];
    
    conn.delegate = self;
    
    NSString *url = [NSString stringWithFormat:@"%@/authlistDetail?scocd=%@&userid=%@&doctype=%@&docno=%@",
                     appDel.baseURL,
                     appDel.selectedCompany.CO_CD,
                     appDel.loggedUser.USER_ID,
                     [_selectedTransaction.doc_type stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]],
                     [_selectedTransaction.doc_no stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    
  NSLog(@"\ngetDetailsForTransaction %@\n",url);
  
  [conn fetchDataForURL:url body:nil];
}

-(void)connectionHandler:(ConnectionHandler*)conHandler didRecieveData:(NSData*)data
{
    NSError *error = nil;
    
    if (connType == ConnectionTypeGetDetails) {
        
        detailModelsArray = nil;
        detailModelsArray = [[NSMutableArray alloc] init];
        
        NSNumber *totalValue = @0;
        
        
        NSArray *arr = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        
        if (arr.count > 0) {
            
            for (NSDictionary *dict in arr) {
                PCTransactionDetailModel *detail_Model = [[PCTransactionDetailModel alloc] init];
                [detail_Model setValuesForKeysWithDictionary:dict];
                [detailModelsArray addObject:detail_Model];
                totalValue = [NSNumber numberWithLongLong:([totalValue longLongValue] + [detail_Model.value longLongValue])];
            }
        }
        else {
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if ([self.selectedTransaction.doc_type containsString:@"3E"]) {
              
              self.valueLabel.text = [Utility stringWithCurrencySymbolPrefix:[NSString stringWithFormat:@"%@",self->_selectedTransaction.im_basic] forCurrencySymbol:self->_selectedTransaction.cursymbl];
            }
            else {
              self.valueLabel.text = [Utility stringWithCurrencySymbolPrefix:[NSString stringWithFormat:@"%@",totalValue] forCurrencySymbol:self->_selectedTransaction.cursymbl];
            }
            
          self.dateLabel.text = self->_selectedTransaction.doc_date;
          self.docNumberLabel.text = self->_selectedTransaction.doc_no;
            
            if ([self.selectedTransaction.doc_type containsString:@"3E"]) {
                self.docTaxesLabel.text = @"Not Applicable";
            }
            else {
              self.docTaxesLabel.text = [Utility stringWithCurrencySymbolPrefix:[NSString stringWithFormat:@"%@",self->_selectedTransaction.doc_taxs] forCurrencySymbol:self->_selectedTransaction.cursymbl];
            }
            
            //Marquee Label
            if ([self.selectedTransaction.doc_type containsString:@"3E"]) {
                self.descriptionLabel.text = @"Not Available";
            }
            else {
              self.partyNameLabel.text = self->_selectedTransaction.party_name;
              self.descriptionLabel.text = self->_selectedTransaction.doc_ref;
            }
            
            self.partyNameLabel.marqueeType = MLContinuous;
            self.descriptionLabel.rate = 15.0;
            self.partyNameLabel.animationCurve = UIViewAnimationOptionCurveEaseInOut;
            self.partyNameLabel.fadeLength = 5.0f;
            self.partyNameLabel.leadingBuffer = 0.0f;
            self.partyNameLabel.trailingBuffer = 15.0f;
            
            self.descriptionLabel.marqueeType = MLContinuous;
            self.descriptionLabel.rate = 35.0;
            self.descriptionLabel.animationCurve = UIViewAnimationOptionCurveEaseInOut;
            self.descriptionLabel.fadeLength = 5.0f;
            self.descriptionLabel.leadingBuffer = 0.0f;
            self.descriptionLabel.trailingBuffer = 15.0f;
            
            [refItemListVC setItemsListArray:detailModelsArray];
            [refItemListVC setSelectedDoctype:self.selectedTransaction.doc_type];
            [refItemListVC.tableView reloadData];
            
//            [self pushToListViews];
//            [_detailsTable reloadData];
        });
        
    }
    else if (connType == ConnectionTypeAuthorize) {
        
        NSString *outputString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        outputString = [outputString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        outputString = [outputString substringWithRange:NSMakeRange(1, outputString.length-2)];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [SVProgressHUD showSuccessWithStatus:@"Done"];
            
            UIAlertController *authAlert = [UIAlertController alertControllerWithTitle:@"Authorization" message:outputString preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction * okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

                [self.navigationController popViewControllerAnimated:YES];
            }];
            
            [authAlert addAction:okAction];
            
            [self presentViewController:authAlert animated:YES completion:nil];
            
//
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Authorization" message:outputString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//            alert.delegate = self;
//            alert.tag = 102;
//            [alert show];

        });
        
        
    }
    else if (connType == ConnectionTypeSendBack)    {
        
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
    
    
    if (connType == ConnectionTypeGetDetails) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //        [refreshControl endRefreshing];
        });
        
    }
    else if (connType == ConnectionTypeAuthorize)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showErrorWithStatus:@"Authorization failed"];
        });
    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString * segueName = segue.identifier;
    if ([segueName isEqualToString: @"embedseg"]) {
        UINavigationController * navViewController = (UINavigationController *) [segue destinationViewController];
        
        navViewController.view.layer.cornerRadius = 10.0;
        navViewController.view.layer.masksToBounds = YES;
        navViewController.view.layer.borderWidth = 1.0;
        navViewController.view.layer.borderColor = [UIColor blackColor].CGColor;
        
        refItemListVC = (PCApprovalItemList*)[navViewController viewControllers][0];
    }
    else if ([segueName isEqualToString:@"authToSendBack"]) {
        PCSendBackViewController *sendBackVC = segue.destinationViewController;
        sendBackVC.delegate = self;
        sendBackVC.selectedTransaction = self.selectedTransaction;
    }
}

-(void)pushToListViews
{
    PCApprovalItemList *itemListVC = [kStoryboard instantiateViewControllerWithIdentifier:@"PCApprovalItemList"];
    [itemListVC setItemsListArray:detailModelsArray];
    [self.navigationController pushViewController:itemListVC animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self heightForCellAtIndexPath:indexPath];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger totalRows = 0;
    
    switch (section) {
        case 0:
            totalRows = 3;
            break;
            
        case 1:
            totalRows = 6;
            break;
            
        case 2:
            totalRows = 1;
            break;
            
        default:
            break;
    }
    
    return totalRows;
}

static NSString *cellIdentifier = @"POSOSingleTransactionCell";

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *returnCell;
    
    switch (indexPath.section) {
        case 0:
        {
            POSOSingleTransactionCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            
            [self configureCell:cell forIndexPath:indexPath];
            
            returnCell = cell;
        }
            break;
            
        case 1:
        {
            POSOSingleTransactionCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            
            [self configureCell:cell forIndexPath:indexPath];
            
            returnCell = cell;
        }
            break;
            
        case 2:
        {
            UITableViewCell *actionCell = [tableView dequeueReusableCellWithIdentifier:@"actionCell"];
            if (actionCell == nil) {
                actionCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"actionCell"];
            }
            actionCell.textLabel.textAlignment = NSTextAlignmentCenter;
            actionCell.textLabel.font = [UIFont boldSystemFontOfSize:18];
            actionCell.textLabel.text = @"Take Action";
            actionCell.backgroundColor = [UIColor colorWithRed:0.988 green:0.741 blue:0.192 alpha:1.0];
            
            returnCell = actionCell;
        }
            break;

        default:
            break;
    }
    
    return returnCell;
}

-(void)configureCell:(POSOSingleTransactionCell*)cell forIndexPath:(NSIndexPath*)indexPath
{
    switch (indexPath.section) {
        case 0:
            
            switch (indexPath.row) {
                    
//                case 0:
//                    cell.titleLabel.text = @"Document date";
//                    cell.descriptionLabel.text = _selectedTransaction.doc_date;
//                    break;
                    
                case 0:
                    cell.titleLabel.text = @"Document Description";
                    cell.descriptionLabel.text = _selectedTransaction.doc_desc;
                    break;
                    
                case 1:
                    cell.titleLabel.text = @"Document number";
                    cell.descriptionLabel.text = _selectedTransaction.doc_no;
                    break;
                    
//                case 3:
//                    cell.titleLabel.text = @"Document Type";
//                    cell.descriptionLabel.text = _selectedTransaction.doc_type;
//                    break;
//                    
//                case 4:
//                    cell.titleLabel.text = @"IM Basic";
//                    cell.descriptionLabel.text = [NSString stringWithFormat:@"%@", _selectedTransaction.im_basic];
//                    break;
                    
                case 2:
                    cell.titleLabel.text = @"Party name";
                    cell.descriptionLabel.text = _selectedTransaction.party_name;
                    break;
                    
                default:
                    break;
            }
            
            break;
            
        case 1:
            switch (indexPath.row) {
                    
                case 0:
                    cell.titleLabel.text = @"Description";
                    cell.descriptionLabel.text = detailModel.descr;
                    break;
                    
                case 1:
                    cell.titleLabel.text = @"Item";
                    cell.descriptionLabel.text = detailModel.item;
                    break;
                    
                case 2:
                    cell.titleLabel.text = @"Quantity";
                    cell.descriptionLabel.text = [NSString stringWithFormat:@"%@",detailModel.qty];
                    break;
                    
                case 3:
                    cell.titleLabel.text = @"Rate";
                
                cell.descriptionLabel.text = [Utility stringWithCurrencySymbolPrefix:[NSString stringWithFormat:@"%@",detailModel.rate] forCurrencySymbol:detailModel.cursymbl];
                
                    break;
                    
                case 4:
                    cell.titleLabel.text = @"Total";
                
                cell.descriptionLabel.text = [Utility stringWithCurrencySymbolPrefix:[NSString stringWithFormat:@"%@",detailModel.total] forCurrencySymbol:detailModel.cursymbl];
                
                    break;
                    
                case 5:
                    cell.titleLabel.text = @"Value";
                cell.descriptionLabel.text = [Utility stringWithCurrencySymbolPrefix:[NSString stringWithFormat:@"%@",detailModel.value] forCurrencySymbol:detailModel.cursymbl];
                    break;
                    
                default:
                    break;
            }
            
            break;
            
        default:
            break;
    }
}

-(CGFloat)heightForCellAtIndexPath:(NSIndexPath*)indexPath
{
    static POSOSingleTransactionCell *sizingCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sizingCell = [_detailsTable dequeueReusableCellWithIdentifier:cellIdentifier];
    });
    
    [self configureCell:sizingCell forIndexPath:indexPath];
    
    return [self calculateHeightForConfiguredSizingCell:sizingCell];
}

-(CGFloat)calculateHeightForConfiguredSizingCell:(UITableViewCell*)cell
{
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    
    CGSize size = [cell systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    
    return size.height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2) {
        [self presentActionSheet];
    }
}

-(IBAction)presentActionSheet
{
    //seq_no field having value greater than 1.(Do not allow if seq_no field contain '-1' or '1')
//    UIActionSheet *actionSheet;
    
    UIAlertController *actionSheetControl = [UIAlertController alertControllerWithTitle:@"What do you want to do?" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    int seqno = [self.selectedTransaction.seq_no intValue];
    
    if ( (seqno == -1) || (seqno == 0) ) {
        
        UIAlertAction *approveAction = [UIAlertAction actionWithTitle:@"Approve this request" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    if ([defaults boolForKey:kPaymentAuthPwdEnabled]) {
                        [self askForLogin];
                    }
                    else {
                        [self initiateConfirmation];
                    }
                });
            });
            
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
           }];
        
        [actionSheetControl addAction:approveAction];
        [actionSheetControl addAction:cancelAction];
        
        

//        actionSheet = [[UIActionSheet alloc] initWithTitle:@"What do you want to do?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Approve this request",nil];
//        actionSheet.tag = 101;
    }
    else {
        
        UIAlertAction *approveAction = [UIAlertAction actionWithTitle:@"Approve this request" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                if ([defaults boolForKey:kPaymentAuthPwdEnabled]) {
                    [self askForLogin];
                }
                else {
                    [self initiateConfirmation];
                }
            });
            
        }];
        
        UIAlertAction *sendBackAction = [UIAlertAction actionWithTitle:@"Send Back" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self performSegueWithIdentifier:@"authToSendBack" sender:nil];
            });
            
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
           }];
        
        [actionSheetControl addAction:approveAction];
        [actionSheetControl addAction:sendBackAction];
        [actionSheetControl addAction:cancelAction];
        
//        actionSheet = [[UIActionSheet alloc] initWithTitle:@"What do you want to do?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Send Back" otherButtonTitles:@"Approve this request",nil];
//        actionSheet.tag = 100;
    }
    
    [self presentViewController:actionSheetControl animated:TRUE completion:nil];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSLog(@"buttonIndex - %ld",(long)buttonIndex);
    
    if (actionSheet.tag == 100) {
        
        switch (buttonIndex) {
            case 0:
            {
                [self performSegueWithIdentifier:@"authToSendBack" sender:nil];
            }
                break;
                
            case 1:
            {
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                if ([defaults boolForKey:kPaymentAuthPwdEnabled]) {
                    [self askForLogin];
                }
                else {
                    [self initiateConfirmation];
                }
            }
                break;
                
            default:
                break;
        }
    }
    
    if (actionSheet.tag == 101) {
        
        switch (buttonIndex) {
                
            case 0:
            {
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                if ([defaults boolForKey:kPaymentAuthPwdEnabled]) {
                    [self askForLogin];
                }
                else {
                    [self initiateConfirmation];
                }
            }
                break;
                
            default:
                break;
        }
    }
    
    
}

-(void)initiateSendBackProcess  {
    
}


-(IBAction)askForLogin
{
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Confirmation" message:@"Provide your login credentials to proceed.\nYou can change password preferences in the settings menu." preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//
//        [self.navigationController popViewControllerAnimated:YES];
//    }];
//
//    UIAlertAction *authAction = [UIAlertAction actionWithTitle:@"Authorize" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//
//        [self.navigationController popViewControllerAnimated:YES];
//    }];
//
//    [alert addAction:authAction];
//    [alert addAction:cancelAction];
//
//    [self presentViewController:alert animated:YES completion:nil];
    
    UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Confirmation" message:@"Provide your login credentials to proceed.\nYou can change password preferences in the settings menu." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
    alert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    alert.tag = 100;
    [alert addButtonWithTitle:@"Authorize"];
    [alert show];
}

#pragma mark - Alert view

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case 100:
            if (buttonIndex == 1) {
                UITextField *username = [alertView textFieldAtIndex:0];
                
                UITextField *password = [alertView textFieldAtIndex:1];
                
                [self authorizeWithUsername:username.text password:password.text];
                
            }
            break;
            
        case 101:
            if (buttonIndex == 1) {
                
                [self askForLogin];
            }
            break;
            
        case 102:
            if (buttonIndex == 0) {
                [self.navigationController popViewControllerAnimated:YES];
            }
            break;
            
        default:
            break;
    }
}

-(void)authorizeWithUsername:(NSString*)username password:(NSString*)password
{
    if (([username isEqualToString:appDel.loggedUser.USER_ID])
        && [password isEqualToString:appDel.loggedUser.USER_PSWD]) {
        
        [self initiateConfirmation];
        
    }
    else {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Authorization failed" message:@"Incorrect credentials provided.\nCannot authorize this document." preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            
        }];
        
        UIAlertAction *retryAction = [UIAlertAction actionWithTitle:@"Retry" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [self askForLogin];
            
        }];
        
        [alert addAction:retryAction];
        [alert addAction:cancelAction];
        
        [self presentViewController:alert animated:YES completion:nil];
        
        
//        UIAlertView *incorrectPwd = [[UIAlertView alloc] initWithTitle:@"Authorization failed" message:@"Incorrect credentials provided.\nCannot authorize this document." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:@"Retry", nil];
//        incorrectPwd.tag = 101;
//        [incorrectPwd show];
    }
}

-(void)initiateConfirmation
{
    [SVProgressHUD showWithStatus:@"Authorizing..." maskType:SVProgressHUDMaskTypeBlack];
    
    connType = ConnectionTypeAuthorize;
    
    ConnectionHandler *conn = [[ConnectionHandler alloc] init];
    
    conn.delegate = self;
    
    NSString *url = [NSString stringWithFormat:@"%@/authorised?scocd=%@&userId=%@&doctype=%@&docno=%@",
        appDel.baseURL,appDel.selectedCompany.CO_CD,appDel.loggedUser.USER_ID,[_selectedTransaction.doc_type stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]],[_selectedTransaction.doc_no stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
  
  NSLog(@"\n%@\n",url);
  
    [conn fetchDataForURL:url body:nil];
}

-(void)sendBackDidFinishSendingBackDoc  {
    [self.navigationController popViewControllerAnimated:YES];
}


@end
