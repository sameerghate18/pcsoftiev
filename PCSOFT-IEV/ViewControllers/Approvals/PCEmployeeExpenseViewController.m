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

typedef enum {
    CellButtonActionTypeUpdate,
    CellButtonActionTypeSeeMore
} CellButtonActionType;

@interface EETableviewCell ()

@property (nonatomic, weak) IBOutlet UILabel *expenseTypeLabel;
@property (nonatomic, weak) IBOutlet UILabel *expenseAmountLabel;
@property (nonatomic, weak) IBOutlet UILabel *projectNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *particularsLabel;
@property (nonatomic, weak) IBOutlet UILabel *sanctionAmountLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UILabel *sanctionTextLabel;
@property (nonatomic, weak) IBOutlet UIButton *updateButton;
@property (nonatomic, weak) IBOutlet UIButton *seeMoreButton;

-(void)fillValuesIntoCell:(EmpExpenseItemModel*)model;

@end

@implementation EETableviewCell

-(void)fillValuesIntoCell:(EmpExpenseItemModel*)model   {
    
    self.expenseTypeLabel.text = model.exp_desc;
    self.expenseAmountLabel.text = [Utility stringWithCurrencySymbolForValue:[NSString stringWithFormat:@"%ld",(long)model.exp_amt] forCurrencyCode:@"INR"];
    self.projectNameLabel.text = model.party_name;
    self.particularsLabel.text = model.exp_parti;
    self.sanctionAmountLabel.text = [Utility stringWithCurrencySymbolForValue:[NSString stringWithFormat:@"%ld",(long)model.sanc_amt] forCurrencyCode:@"INR"];
    self.dateLabel.text = [Utility stringDateFromServerDate:model.exp_date];
    
    [model addObserver:self forKeyPath:@"sanc_amt" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    
    if (model.exp_stat == 2 || model.exp_stat == 6) {
        self.seeMoreButton.hidden = NO;
        self.updateButton.hidden = YES;
        self.sanctionAmountLabel.hidden = YES;
        self.sanctionTextLabel.hidden = YES;
    }
    else {
        self.seeMoreButton.hidden = YES;
        self.updateButton.hidden = NO;
        self.sanctionAmountLabel.hidden = NO;
        self.sanctionTextLabel.hidden = NO;
    }
    
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSKeyValueChangeKey, id> *)change context:(nullable void *)context   {
    
    EmpExpenseItemModel *itemModel;
    if ([object isKindOfClass:[EmpExpenseItemModel class]]) {
        itemModel = (EmpExpenseItemModel*)object;
        if ([keyPath isEqualToString:@"sanc_amt"]) {
            
            unsigned int newValue = [change[@"new"] intValue];
            unsigned int oldValue = [change[@"old"] intValue];
            
            if (newValue == oldValue) {
                itemModel.sancAmountChanged = NO;
                itemModel.valueChange = NewValueEqual;
            }
            else if (newValue < oldValue){
                itemModel.sancAmountChanged = YES;
                itemModel.valueChange = NewValueLesser;
            }
            else {
                itemModel.valueChange = NewValueMore;
            }
        }
    }
}

@end

@implementation EmpExpenseItemModel
@end

@implementation EmpExpenseKMModel
@end

@interface PCEmployeeExpenseViewController () <UITableViewDataSource, UITableViewDelegate, PCSendBackViewControllerDelegate>
{
    NSMutableArray *detailModelsArray;
    CellButtonActionType actionType;
}
@property (nonatomic, weak) IBOutlet UILabel *documentNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UILabel *amountLabel;
@property (nonatomic, weak) IBOutlet UILabel *taxLabel;

@property (nonatomic, strong) IBOutlet UITableView *itemsTableview;

@end

@implementation PCEmployeeExpenseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self populateFields];
    [self getDetailsForTransaction:self.selectedTransaction];
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
        
        dispatch_async(dispatch_get_main_queue(), ^{
                [self.itemsTableview reloadData];
        });
    }];
}

- (void)getKMDetailsForTransaction:(PCTransactionModel*)model   {
    
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
        for (int index = 0; index < arr.count; index++) {
            NSDictionary *dict = [arr objectAtIndex:index];
            EmpExpenseKMModel *kmModelObj = [[EmpExpenseKMModel alloc] init];
            [kmModelObj setValuesForKeysWithDictionary:dict];
            EmpExpenseItemModel *expenseModel = [detailModelsArray objectAtIndex:index];
            if (kmModelObj.exp_code == expenseModel.exp_code) {
                expenseModel.kmModel = kmModelObj;
            }
        }
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
    });
    
}

#pragma mark - UITableViewDelegates

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section    {
    return detailModelsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath  {
    
    EETableviewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    EmpExpenseItemModel *model = [detailModelsArray objectAtIndex:indexPath.row];
    [cell fillValuesIntoCell:model];
    cell.updateButton.tag = indexPath.row;
    cell.seeMoreButton.tag = indexPath.row;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
    return 160;
}

static NSString *cellIdentifier = @"EETableviewCellIdentifier";

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

- (void)presentSanctionAmountUpdateSheetForItem:(EmpExpenseItemModel*)model completion:(void(^)(BOOL valueUpdated, NSError *error))completionBlock  {
    
    NSInteger sancAmt;
    if ((model.exp_stat == 2) || (model.exp_stat == 6)) {
        sancAmt = model.kmModel.sanc_amt;
    }
    else { sancAmt = model.sanc_amt;}
    
    NSString *sanctAmount = [Utility stringWithCurrencySymbolForValue:[NSString stringWithFormat:@"%ld",(long)sancAmt] forCurrencyCode:@"INR"];
    UIAlertController *sanctionAlert = [UIAlertController alertControllerWithTitle:@"Sanction Amount" message:[NSString stringWithFormat:@"Please provide new sanction amount.\nThis amount should be less than %@",sanctAmount] preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *updateAction = [UIAlertAction actionWithTitle:@"Update" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        UITextField *amtTf = (UITextField*)sanctionAlert.textFields[0];
        if ((model.exp_stat == 2) || (model.exp_stat == 6)) {
            model.kmModel.sanc_amt = [amtTf.text integerValue];
            model.kmModel.sancAmountChanged = YES;
        }
        else {
            model.sanc_amt = [amtTf.text integerValue];
        }
    }];
    
    updateAction.enabled = false;
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:true completion:nil];
    }];
    
    [sanctionAlert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"New amount";
        textField.keyboardType = UIKeyboardTypeDecimalPad;
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UITextFieldTextDidChangeNotification object:[sanctionAlert.textFields objectAtIndex:0] queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
        
        UITextField *amtTf = (UITextField*)sanctionAlert.textFields[0];
        
        if (amtTf.text.length > 0) {
            if (sancAmt > [amtTf.text integerValue])  {
                updateAction.enabled = true;
            }
            else {  updateAction.enabled = false;   }
        }
        else { updateAction.enabled = false;    }
    }];
    
    [sanctionAlert addAction:updateAction];
    [sanctionAlert addAction:cancelAction];
    
    [self presentViewController:sanctionAlert animated:YES completion:nil];
    
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

-(IBAction)seeMoreAction:(id)sender  {
    NSInteger btnTag = ((UIButton*)sender).tag;
    EmpExpenseItemModel *model = [detailModelsArray objectAtIndex:btnTag];
    EmpExpenseKMModel *kmModel = model.kmModel;
    
    NSString *date = [Utility stringDateFromServerDate:kmModel.trvl_date];
    NSString *amt = [Utility stringWithCurrencySymbolForValue:[NSString stringWithFormat:@"%ld",(long)kmModel.trvl_amt] forCurrencyCode:@"INR"];
    NSString *sancAmt = [Utility stringWithCurrencySymbolForValue:[NSString stringWithFormat:@"%ld",(long)kmModel.sanc_amt] forCurrencyCode:@"INR"];
    
    NSString *message;
    
    if (model.exp_stat == 2) {
        message = [NSString stringWithFormat:@"\nDoc no. : %@\n\nTravel Date : %@\nTravel Party : %@\nStart KM : %ld\nEnd KM : %ld\nTotal KM : %ld\nRate : %ld\nAmount : %@\n\nSanction Amount : %@", kmModel.doc_no,date,kmModel.trvl_parti,(long)kmModel.km_start,(long)kmModel.km_end,(long)kmModel.km_total,(long)kmModel.km_rate, amt,sancAmt ];
    }
    else if (model.exp_stat == 6) {
        message = [NSString stringWithFormat:@"\nDoc no. : %@\n\nTravel Date : %@\nTravel Party : %@\nTotal KM : %ld\nRate : %ld\nAmount : %@\n\nSanction Amount : %@", kmModel.doc_no,date,kmModel.trvl_parti,(long)kmModel.km_total,(long)kmModel.km_rate, amt,sancAmt ];
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"KM Details" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Update Sanction Amount" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self presentSanctionAmountUpdateSheetForItem:model completion:nil];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:true completion:nil];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
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
    
    NSInteger btnTag = ((UIButton*)sender).tag;
    EmpExpenseItemModel *model = [detailModelsArray objectAtIndex:btnTag];
    
    
    [self presentSanctionAmountUpdateSheetForItem:model completion:^(BOOL valueUpdated, NSError *error) {
        
        if (valueUpdated == YES) {
            
        }
    }];
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
    
    NSMutableString *itemJSON = [[NSMutableString alloc] initWithString:@"["];
    NSMutableString *KMjson = [[NSMutableString alloc] initWithString:@"["];
    
    NSInteger modelsCount = detailModelsArray.count;
    for (int index = 0; index < modelsCount; index++) {
        EmpExpenseItemModel *model = detailModelsArray[index];
        
        if (model.sancAmountChanged == YES) {
            NSString *str = [NSString stringWithFormat:@"{\"sanc_amt\":%ld,\"id_key\":\"%@\"}",(long)model.sanc_amt,model.id_key];
            [itemJSON appendString:str];
            index<modelsCount-1?[itemJSON appendString:@","]:[itemJSON appendString:@""];
        }
        
        if ((model.exp_stat == 2) ||  (model.exp_stat == 6)) {
            if (model.kmModel.sancAmountChanged == YES)    {
                NSString *str1 = [NSString stringWithFormat:@"{\"sanc_amt\":%ld,\"id_key\":\"%@\"}",(long)model.kmModel.sanc_amt,model.kmModel.id_key];
                [KMjson appendString:str1];
                 index<modelsCount-1?[KMjson appendString:@","]:[itemJSON appendString:@""];
            }
        }
    }
    [itemJSON appendString:@"]"];
    [KMjson appendString:@"]"];
    NSString *encodedItemJSON = [itemJSON stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *encodedkmJSON = [KMjson stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *docNo = [_selectedTransaction.doc_no stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *url = GET_PAGE_SUBMIT_URL(appDel.baseURL, appDel.selectedCompany.CO_CD, appDel.loggedUser.USER_ID, docNo , encodedItemJSON,encodedkmJSON);
    
    //@"[{%22sanc_amt%22:900.00,%22id_key%22:%22865%22}]");
    
    //submitexpE?scocd=w1&userid=EPENT&docno=?&exptrndt=[{%22sanc_amt%22:253.00,%22id_key%22:%2201%22}]&exptrnkm=        [{"sanc_amt":900.00,"id_key":"865"}]
    
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
                [self.navigationController popViewControllerAnimated:true];
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
