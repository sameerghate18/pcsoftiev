//
//  EmpExpenseItemListViewController.m
//  PCSOFT-IEV
//
//  Created by Sameer Ghate on 17/12/17.
//  Copyright © 2017 Sameer Ghate. All rights reserved.
//

#import "EmpExpenseItemListViewController.h"
#import "EmpExpenseItemDetailViewController.h"

typedef enum {
    CellButtonActionTypeUpdate,
    CellButtonActionTypeSeeMore
} CellButtonActionType;

@interface EETableviewCell ()
{
        CellButtonActionType actionType;
}
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
    
    if ((model.exp_stat == 2) || (model.exp_stat == 6)) {
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


@interface EmpExpenseItemListViewController () <UITableViewDelegate, UITableViewDataSource>
@end

@implementation EmpExpenseItemListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"List of Expenses";
    [self.itemsTableview reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegates

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section    {
    return self.detailModelsArray.count;
}

static NSString *cellIdentifier = @"EETableviewCellIdentifier";

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath  {
    
    EETableviewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    EmpExpenseItemModel *model = [self.detailModelsArray objectAtIndex:indexPath.row];
    
    [cell fillValuesIntoCell:model];
    cell.updateButton.tag = indexPath.row;
    cell.seeMoreButton.tag = indexPath.row;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
    return 160;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma  mark -

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
            model.sancAmountChanged = YES;
        }

        [[NSNotificationCenter defaultCenter] postNotificationName:@"EnableSubmitButtonNotification" object:nil];
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

#pragma  mark -

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender    {
    
    if ([segue.identifier isEqualToString:@"itemToDetailSegue"]) {
        EmpExpenseItemModel *model = (EmpExpenseItemModel*)sender;
        EmpExpenseItemDetailViewController *destVC = (EmpExpenseItemDetailViewController*)segue.destinationViewController;
        [destVC  setSelectedExpenseModel:model];
        [destVC setItemDetailsArray:model.kmModelArray];
    }
}

- (IBAction)seeMoreButtonAction:(id)sender    {
    
    NSInteger tag = ((UIButton*)sender).tag;
    
    EmpExpenseItemModel *model = [self.detailModelsArray objectAtIndex:tag];
    [self performSegueWithIdentifier:@"itemToDetailSegue" sender:model];
}

- (IBAction)updateButtonAction:(id)sender    {
    
    NSInteger tag = ((UIButton*)sender).tag;
    
    EmpExpenseItemModel *model = [self.detailModelsArray objectAtIndex:tag];
    [self presentSanctionAmountUpdateSheetForItem:model completion:nil];
}

@end
