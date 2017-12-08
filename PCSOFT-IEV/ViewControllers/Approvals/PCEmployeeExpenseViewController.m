//
//  PCEmployeeExpenseViewController.m
//  PCSOFT-IEV
//
//  Created by Sameer Ghate on 08/12/17.
//  Copyright © 2017 Sameer Ghate. All rights reserved.
//

#import "PCEmployeeExpenseViewController.h"
#import "PCTransactionModel.h"
#import "ConnectionHandler.h"
#import "PCSendBackViewController.h"

@interface EETableviewCell ()

@property (nonatomic, weak) IBOutlet UILabel *expenseTypeLabel;
@property (nonatomic, weak) IBOutlet UILabel *expenseAmountLabel;
@property (nonatomic, weak) IBOutlet UILabel *projectNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *particularsLabel;
@property (nonatomic, weak) IBOutlet UILabel *sanctionAmountLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;

@end

@interface PCEmployeeExpenseViewController () <UITableViewDataSource, UITableViewDelegate, PCSendBackViewControllerDelegate>
{
    NSMutableArray *detailModelsArray;
}
@property (nonatomic, weak) IBOutlet UILabel *documentNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UILabel *amountLabel;
@property (nonatomic, weak) IBOutlet UILabel *taxLabel;


@end

@implementation PCEmployeeExpenseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self getDetailsForTransaction:self.selectedTransaction];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pop:(id)sender  {
    
}

-(void)getDetailsForTransaction:(PCTransactionModel*)model
{
    AppDelegate *appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    ConnectionHandler *conn = [[ConnectionHandler alloc] init];
    
    NSString *docType = [_selectedTransaction.doc_type stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *docNo = [_selectedTransaction.doc_no stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSString *url1 = GET_EE_DETAIL_URL(appDel.baseURL, appDel.selectedCompany.CO_CD, appDel.loggedUser.USER_ID, docType, docNo);
    
    NSString *url = [NSString stringWithFormat:@"%@/authlistDetail?scocd=%@&userid=%@&doctype=%@&docno=%@",
                     appDel.baseURL,
                     appDel.selectedCompany.CO_CD,
                     appDel.loggedUser.USER_ID,
                     [_selectedTransaction.doc_type stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]],
                     [_selectedTransaction.doc_no stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    
    
    [conn fetchDataForGETURL:url1 body:nil completion:^(id responseData, NSError *error) {
        
        NSArray *arr = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&error];
        
        if (arr.count > 0) {
            
            if (!detailModelsArray) {
                detailModelsArray = [[NSMutableArray alloc] init];
            }
            [detailModelsArray removeAllObjects];
            
            for (NSDictionary *dict in arr) {
//                PCTransactionDetailModel *detail_Model = [[PCTransactionDetailModel alloc] init];
//                [detail_Model setValuesForKeysWithDictionary:dict];
//                [detailModelsArray addObject:detail_Model];
//                totalValue = [NSNumber numberWithLongLong:([totalValue longLongValue] + [detail_Model.value longLongValue])];
            }
        }
        else {
        }
        
    }];
}

#pragma mark - UITableViewDelegates

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section    {
    return detailModelsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath  {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
    return 160;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - Action sheets

-(IBAction)presentActionSheet
{
    //seq_no field having value greater than 1.(Do not allow if seq_no field contain '-1' or '1')

    UIAlertController *actionSheet2;
    //
    
    int seqno = [self.selectedTransaction.seq_no intValue];
    
    if ( (seqno == -1) || (seqno == 0) ) {
        
        actionSheet2 = [UIAlertController alertControllerWithTitle:@"What do you want to do?" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        [actionSheet2 addAction:[UIAlertAction actionWithTitle:@"Approve this request" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            if ([defaults boolForKey:kPaymentAuthPwdEnabled]) {
                [self askForLogin];
            }
            else {
                [self initiateConfirmation];
            }
        }]];
        
        [actionSheet2 addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        
        [self presentViewController:actionSheet2 animated:YES completion:nil];
    }
    else {
        actionSheet2 = [UIAlertController alertControllerWithTitle:@"What do you want to do?" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        [actionSheet2 addAction:[UIAlertAction actionWithTitle:@"Send Back" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self performSegueWithIdentifier:@"expToSendBack" sender:self.selectedTransaction];
        }]];
        
        [actionSheet2 addAction:[UIAlertAction actionWithTitle:@"Approve this request" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            if ([defaults boolForKey:kPaymentAuthPwdEnabled]) {
                [self askForLogin];
            }
            else {
                [self initiateConfirmation];
            }
        }]];
        
        [actionSheet2 addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }]];
        
        [self presentViewController:actionSheet2 animated:YES completion:nil];
    }
}

-(IBAction)askForLogin
{
    
    UIAlertController *loginAlert = [UIAlertController alertControllerWithTitle:@"Confirmation" message:@"Provide your login credentials to proceed.\nYou can change password preferences in the settings menu." preferredStyle:UIAlertControllerStyleAlert];
    
    __block UITextField *usernameTF, *passwordTF;
    
    [loginAlert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"User name";
        usernameTF  = textField;
    }];
    
    [loginAlert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Password";
        passwordTF  = textField;
    }];
    
    [loginAlert addAction:[UIAlertAction actionWithTitle:@"Authorize" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self authorizeWithUsername:usernameTF.text password:passwordTF.text];
        
    }]];
    
    [loginAlert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    [self presentViewController:loginAlert animated:YES completion:nil];
}

-(void)authorizeWithUsername:(NSString*)username password:(NSString*)password
{
    AppDelegate *appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    if (([username isEqualToString:appDel.loggedUser.USER_ID])
        && [password isEqualToString:appDel.loggedUser.USER_PSWD]) {
        
        [self initiateConfirmation];
        
    }
    else {
        
        UIAlertController *incorrectPwdAlert = [UIAlertController alertControllerWithTitle:@"Authorization failed" message:@"Incorrect credentials provided.\nCannot authorize this document." preferredStyle:UIAlertControllerStyleActionSheet];
        [incorrectPwdAlert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }]];
        [incorrectPwdAlert addAction:[UIAlertAction actionWithTitle:@"Retry" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self askForLogin];
        }]];
        
        [self presentViewController:incorrectPwdAlert animated:YES completion:nil];
    }
}

#pragma mark - Connection

-(void)initiateConfirmation
{
    [SVProgressHUD showWithStatus:@"Authorizing..." maskType:SVProgressHUDMaskTypeBlack];
    
    AppDelegate *appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    ConnectionHandler *conn = [[ConnectionHandler alloc] init];
    
    NSString *url = [NSString stringWithFormat:@"%@/authorised?scocd=%@&userId=%@&doctype=%@&docno=%@",
                     appDel.baseURL,appDel.selectedCompany.CO_CD,appDel.loggedUser.USER_ID,[_selectedTransaction.doc_type stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]],[_selectedTransaction.doc_no stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    
    [conn fetchDataForGETURL:url body:nil completion:^(id responseData, NSError *error) {
        
        NSString *outputString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        outputString = [outputString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        outputString = [outputString substringWithRange:NSMakeRange(1, outputString.length-2)];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [SVProgressHUD showSuccessWithStatus:@"Done"];
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Authorization" message:outputString preferredStyle:UIAlertControllerStyleActionSheet];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self.navigationController popViewControllerAnimated:YES];
            }]];
            [self presentViewController:alert animated:YES completion:nil];
        });
        
    }];
}

-(IBAction)updateSanctionAmount:(id)sender  {
    
    UIAlertController *sanctionAlert = [UIAlertController alertControllerWithTitle:@"Sanction Amount" message:[NSString stringWithFormat:@"Please provide new amount.\nSanction amount should be less than Rs. 2500"] preferredStyle:UIAlertControllerStyleAlert];
    
    __block UITextField *amountTF;
    
    [sanctionAlert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Amount";
        amountTF  = textField;
    }];
    
    [sanctionAlert addAction:[UIAlertAction actionWithTitle:@"Sanction" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self initiateSanctionAmount];
    }]];
    
    [sanctionAlert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    [self presentViewController:sanctionAlert animated:YES completion:nil];
    
}

-(void)initiateSanctionAmount   {
    
    AppDelegate *appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    ConnectionHandler *conn = [[ConnectionHandler alloc] init];
    
    NSString *url = GET_SUBMIT_EXPENSE_URL(appDel.baseURL, appDel.selectedCompany.CO_CD, appDel.loggedUser.USER_ID, [_selectedTransaction.doc_no stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]], @"[{%22sanc_amt%22:253.00,%22id_key%22:%2201%22}]");
    //[{%22sanc_amt%22:253.00,%22id_key%22:%2201%22}]
    
    [conn fetchDataForGETURL:url body:nil completion:^(id responseData, NSError *error) {
        
        NSString *outputString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        outputString = [outputString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        outputString = [outputString substringWithRange:NSMakeRange(1, outputString.length-2)];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Sanction amount" message:outputString preferredStyle:UIAlertControllerStyleActionSheet];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
            }]];
            [self presentViewController:alert animated:YES completion:nil];
        });
        
    }];
}

-(IBAction)pageSubmitAction:(id)sender  {
    
    AppDelegate *appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    ConnectionHandler *conn = [[ConnectionHandler alloc] init];
    
    NSString *url = GET_PAGE_SUBMIT_URL(appDel.baseURL, appDel.selectedCompany.CO_CD, appDel.loggedUser.USER_ID, [_selectedTransaction.doc_no stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]], @"[{%22sanc_amt%22:253.00,%22id_key%22:%2201%22}]", @"[{%22sanc_amt%22:900.00,%22id_key%22:%22865%22}]" );
    //
    
    [conn fetchDataForGETURL:url body:nil completion:^(id responseData, NSError *error) {
        
        NSString *outputString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        outputString = [outputString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        outputString = [outputString substringWithRange:NSMakeRange(1, outputString.length-2)];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Submit" message:outputString preferredStyle:UIAlertControllerStyleActionSheet];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
            }]];
            [self presentViewController:alert animated:YES completion:nil];
        });
        
    }];
    
}

-(void)sendBackDidFinishSendingBackDoc  {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"expToSendBack"]) {
        PCSendBackViewController *sendBackVC = (PCSendBackViewController*)segue.destinationViewController;
        sendBackVC.delegate = self;
        sendBackVC.selectedTransaction = self.selectedTransaction;
    }
}

@end
