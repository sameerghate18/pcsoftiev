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
#import "EmpExpenseItemListViewController.h"


@interface PCEmployeeExpenseViewController () <PCSendBackViewControllerDelegate>
{
    NSMutableArray *detailModelsArray, *updateExpenseModelsArray;
}
@property (nonatomic, weak) IBOutlet UILabel *documentNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UILabel *amountLabel;
@property (nonatomic, weak) IBOutlet UILabel *taxLabel;
@property (nonatomic, weak) IBOutlet UIButton *submitButton;
@property (nonatomic, weak) IBOutlet UIButton *cancelButton;
@property (nonatomic) BOOL enableSubmitButton;

@property (nonatomic, weak) EmpExpenseItemListViewController *itemListViewController;
@end

@implementation PCEmployeeExpenseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.enableSubmitButton = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enableSubmitButtonAction) name:@"EnableSubmitButtonNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateItemsArray:) name:@"ExpenseItemUpdatedNotification" object:nil];
    [self.submitButton setEnabled:FALSE];
    [self.submitButton setBackgroundColor:[UIColor grayColor]];
    [self populateFields];
    [self getDetailsForTransaction:self.selectedTransaction];
}

- (void)enableSubmitButtonAction  {
    [self.submitButton setEnabled:TRUE];
    [self.submitButton setBackgroundColor:[UIColor colorWithRed:0 green:0.51 blue:0 alpha:1.0]];
}

- (void)disableSubmitButton {
    [self.submitButton setEnabled:FALSE];
    [self.submitButton setBackgroundColor:[UIColor grayColor]];
}

- (void)updateItemsArray:(NSNotification*)notification    {
    //exp_code
    
    EmpExpenseItemModel *model = (EmpExpenseItemModel*)notification.object;
    
    if (!updateExpenseModelsArray) {
        updateExpenseModelsArray = [[NSMutableArray alloc] initWithObjects:model, nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.itemListViewController setDetailModelsArray:updateExpenseModelsArray];
            [self.itemListViewController.itemsTableview reloadData];
        });
        return;
    }
    
    for (int index = 0; index < updateExpenseModelsArray.count; index++) {
        EmpExpenseItemModel *model1 = updateExpenseModelsArray[index];
        if ([model1.exp_code isEqualToString:model.exp_code]) {
            [updateExpenseModelsArray replaceObjectAtIndex:index withObject:model];
            break;
        }
        else {
            [updateExpenseModelsArray addObject:model];
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.itemListViewController setDetailModelsArray:updateExpenseModelsArray];
        [self.itemListViewController.itemsTableview reloadData];
    });
}

-(void)populateFields   {
    
    self.documentNameLabel.text = self.selectedTransaction.doc_no;
    self.dateLabel.text = [Utility stringDateFromServerDate:self.selectedTransaction.doc_date];
    self.amountLabel.text = [Utility stringWithCurrencySymbolForValue:[NSString stringWithFormat:@"%@",self.selectedTransaction.im_basic] forCurrencyCode:@"INR"];
    self.taxLabel.text = [Utility stringWithCurrencySymbolForValue:[NSString stringWithFormat:@"%@",self.selectedTransaction.doc_taxs] forCurrencyCode:@"INR"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pop:(id)sender  {
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)getDetailsForTransaction:(PCTransactionModel*)model
{
    [SVProgressHUD showWithStatus:@"Getting expense items"];
    
    AppDelegate *appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    ConnectionHandler *conn = [[ConnectionHandler alloc] init];
    
    NSString *docType = [_selectedTransaction.doc_type stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *docNo = [_selectedTransaction.doc_no stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSString *url1 = GET_EE_DETAIL_URL(appDel.baseURL, appDel.selectedCompany.CO_CD, appDel.loggedUser.USER_ID, docType, docNo);
    [conn fetchDataForGETURL:url1 body:nil completion:^(id responseData, NSError *error) {
        
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
            });
            return;
        }
        
        NSArray *arr = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&error];
        if (arr.count > 0) {
            if (!detailModelsArray) {
                detailModelsArray = [[NSMutableArray alloc] init];
            }
            [detailModelsArray removeAllObjects];
            
            for (NSDictionary *dict in arr) {
                EmpExpenseItemModel *expenseModel = [[EmpExpenseItemModel alloc] init];
                [expenseModel setValuesForKeysWithDictionary:dict];
                [detailModelsArray addObject:expenseModel];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                [self getKMDetailsForTransaction:model];
            });
            
        }
        else {
        }
    }];
}

- (void)getKMDetailsForTransaction:(PCTransactionModel*)model {
    
    [SVProgressHUD showWithStatus:@"Getting details"];
    AppDelegate *appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *doctypeStr = [model.doc_type stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *url = GET_EE_Exp_KM_URL(appDel.baseURL,  appDel.selectedCompany.CO_CD, appDel.loggedUser.USER_ID, doctypeStr, model.doc_no)
    
    ConnectionHandler *conn = [[ConnectionHandler alloc] init];
    [conn fetchDataForGETURL:url body:nil completion:^(id responseData, NSError *error) {
        
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
            });
            return;
        }
        
        NSArray *arr = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&error];
        
        NSMutableArray *kmObjectsArray = [[NSMutableArray alloc] init];
        for (NSDictionary *dict in arr) {
            EmpExpenseKMModel *kmModelObj = [[EmpExpenseKMModel alloc] init];
            [kmModelObj setValuesForKeysWithDictionary:dict];
            [kmObjectsArray addObject:kmModelObj];
        }
        
        NSMutableArray *kmModels = [[NSMutableArray alloc] init];
        for (int index = 0; index < detailModelsArray.count; index++) {
            EmpExpenseItemModel *expenseModel = [detailModelsArray objectAtIndex:index];
           
            for (EmpExpenseKMModel *kmObj in kmObjectsArray) {
                if ([kmObj.exp_code isEqualToString:expenseModel.exp_code]) {
                    [kmModels addObject:kmObj];
                }
            }
            expenseModel.kmModelArray = [[NSArray alloc] initWithArray:kmModels];
            [kmModels removeAllObjects];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
//            updateExpenseModelsArray = [[NSMutableArray alloc] initWithArray:detailModelsArray];
            [self.itemListViewController setDetailModelsArray:detailModelsArray];
            [self.itemListViewController.itemsTableview reloadData];
        });
        
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
    });
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSKeyValueChangeKey, id> *)change context:(nullable void *)context   {
    
    if ([keyPath isEqualToString:@"enableSubmitButton"]) {
        
        unsigned int newValue = [change[@"new"] intValue];
        if (newValue == 1) {
            [self.submitButton setEnabled:TRUE];
            [self.submitButton setBackgroundColor:[UIColor colorWithRed:0 green:0.51 blue:0 alpha:1.0]];
        }
        else {
            [self.submitButton setEnabled:FALSE];
            [self.submitButton setBackgroundColor:[UIColor grayColor]];
        }
    }
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
        
        UIAlertController *incorrectPwdAlert = [UIAlertController alertControllerWithTitle:@"Authorization failed" message:@"Incorrect credentials provided.\nCannot authorize this document." preferredStyle:UIAlertControllerStyleAlert];
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
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Authorization" message:outputString preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self.navigationController popViewControllerAnimated:YES];
            }]];
            [self presentViewController:alert animated:YES completion:nil];
        });
        
    }];
}

-(void)getKMDetails:(EmpExpenseItemModel*)model {
    AppDelegate *appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *doctypeStr = [model.doc_type stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *url = GET_EE_Exp_KM_URL(appDel.baseURL,  appDel.selectedCompany.CO_CD, appDel.loggedUser.USER_ID, doctypeStr, model.doc_no)
    
    ConnectionHandler *conn = [[ConnectionHandler alloc] init];
    [conn fetchDataForGETURL:url body:nil completion:^(id responseData, NSError *error) {
        
        NSArray *arr = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&error];
        
        NSMutableArray *kmArray = [[NSMutableArray alloc] init];
        for (NSDictionary *dict in arr) {
            EmpExpenseKMModel *kmModel = [[EmpExpenseKMModel alloc] init];
            [kmModel setValuesForKeysWithDictionary:dict];
            [kmArray addObject:kmModel];
        }
    }];
}

-(IBAction)updateSanctionAmount:(id)sender  {

}

-(void)initiateSanctionAmount:(EmpExpenseItemModel*)model   {
    
    AppDelegate *appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    ConnectionHandler *conn = [[ConnectionHandler alloc] init];

    NSString *sancAmountStr = [NSString stringWithFormat:@"[{\"sanc_amt\":%ld,\"id_key\":\"%@\"}]", (long)model.sanc_amt, model.id_key];
    NSString *encodedStr = [sancAmountStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *docNo = [_selectedTransaction.doc_no stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *url = GET_SUBMIT_EXPENSE_URL(appDel.baseURL, appDel.selectedCompany.CO_CD, appDel.loggedUser.USER_ID, docNo, encodedStr);
    //[{%22sanc_amt%22:253.00,%22id_key%22:%2201%22}]
    
    [conn fetchDataForGETURL:url body:nil completion:^(id responseData, NSError *error) {
        
        NSString *outputString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        outputString = [outputString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        outputString = [outputString substringWithRange:NSMakeRange(1, outputString.length-2)];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Sanction amount" message:outputString preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
            }]];
            [self presentViewController:alert animated:YES completion:nil];
        });
        
    }];
}

-(IBAction)pageSubmitAction:(id)sender  {
    
    [SVProgressHUD showWithStatus:@"Submitting expense"];
    AppDelegate *appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    ConnectionHandler *conn = [[ConnectionHandler alloc] init];
    
    NSMutableArray *itemJSONArray = [[NSMutableArray alloc] init];
    NSMutableArray *kmJSONArray = [[NSMutableArray alloc] init];
    NSMutableString *itemJSON = [[NSMutableString alloc] init];
    NSMutableString *KMjson = [[NSMutableString alloc] init];
    
    NSInteger modelsCount = updateExpenseModelsArray.count;
    for (int index = 0; index < modelsCount; index++) {
        
        EmpExpenseItemModel *model = updateExpenseModelsArray[index];
        index==0?[itemJSON appendString:@"["]:nil;
        
        if (model.sancAmountChanged == YES) {
            NSString *str = [NSString stringWithFormat:@"{\"sanc_amt\":%ld,\"id_key\":\"%@\"}",(long)model.sanc_amt,model.id_key];
            [itemJSON appendString:str];
        }
        else if ((model.exp_stat == 2) ||  (model.exp_stat == 6)) {
           
            NSInteger totalAmount = 0;
            NSInteger kmModelsCount = model.kmModelArray.count;
            for (int kmIndex = 0; kmIndex < kmModelsCount; kmIndex++) {
                EmpExpenseKMModel *kmModel = [model.kmModelArray objectAtIndex:kmIndex];
                if (kmModel.sancAmountChanged == YES)    {
                    [kmJSONArray addObject:kmModel];
                    totalAmount += kmModel.sanc_amt;
                }
            }
            NSString *str = [NSString stringWithFormat:@"{\"sanc_amt\":%ld,\"id_key\":\"%@\"}",(long)totalAmount,model.id_key];
            [itemJSON appendString:str];
        }
        index<modelsCount-1?[itemJSON appendString:@","]:[KMjson appendString:@""];
        index==modelsCount-1?[itemJSON appendString:@"]"]:nil;
    }

//    NSInteger itemJSONArrayCount = itemJSONArray.count;
    NSInteger kmJSONArrayCount = kmJSONArray.count;
    
//    for (int index = 0; index < itemJSONArrayCount; index++) {
//            EmpExpenseItemModel *model = itemJSONArray[index];
//            index==0?[itemJSON appendString:@"["]:nil;
//            NSString *str = [NSString stringWithFormat:@"{\"sanc_amt\":%ld,\"id_key\":\"%@\"}",(long)model.sanc_amt,model.id_key];
//            [itemJSON appendString:str];
//            index<itemJSONArrayCount-1?[itemJSON appendString:@","]:[itemJSON appendString:@""];
//            index==itemJSONArrayCount-1?[itemJSON appendString:@"]"]:nil;
//    }
    
    for (int index = 0; index < kmJSONArrayCount; index++) {
        EmpExpenseKMModel *kmModel = kmJSONArray[index];
        index==0?[KMjson appendString:@"["]:nil;
        NSString *kmStr = [NSString stringWithFormat:@"{\"sanc_amt\":%ld,\"id_key\":\"%@\"}",(long)kmModel.sanc_amt,kmModel.id_key];
        [KMjson appendString:kmStr];
        index<kmJSONArrayCount-1?[KMjson appendString:@","]:[KMjson appendString:@""];
        index==kmJSONArrayCount-1?[KMjson appendString:@"]"]:nil;
    }
    
    NSString *encodedItemJSON = [itemJSON stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *encodedkmJSON = [KMjson stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *docNo = [_selectedTransaction.doc_no stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *url = GET_PAGE_SUBMIT_URL(appDel.baseURL, appDel.selectedCompany.CO_CD, appDel.loggedUser.USER_ID, docNo , encodedItemJSON,encodedkmJSON);

    [conn fetchDataForGETURL:url body:nil completion:^(id responseData, NSError *error) {
        
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
            });
        }
        
        NSString *outputString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        outputString = [outputString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        outputString = [outputString substringWithRange:NSMakeRange(1, outputString.length-2)];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Submit Expenses" message:outputString preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.enableSubmitButton = FALSE;
                    [self disableSubmitButton];
                });
                
//                [self.navigationController popViewControllerAnimated:true];
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
    else if ([segue.identifier isEqualToString:@"itemsContainerSegue"])   {
        
        UINavigationController *navController = (UINavigationController*)[segue destinationViewController];
        self.itemListViewController = [[navController viewControllers] objectAtIndex:0];
        [self.itemListViewController setDetailModelsArray:detailModelsArray];
    }
}

@end
