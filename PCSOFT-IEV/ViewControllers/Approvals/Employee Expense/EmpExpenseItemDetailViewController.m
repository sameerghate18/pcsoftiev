//
//  EmpExpenseItemDetailViewController.m
//  PCSOFT-IEV
//
//  Created by Sameer Ghate on 17/12/17.
//  Copyright © 2017 Sameer Ghate. All rights reserved.
//

#import "EmpExpenseItemDetailViewController.h"

@interface EmpExpenseItemDetailViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UITableView *detailTableview;

@end

@interface EmpExpenseKMType1Cell ()

@property (nonatomic, weak) IBOutlet UILabel *travelDateLabel;
@property (nonatomic, weak) IBOutlet UILabel *travelDetailLabel;
@property (nonatomic, weak) IBOutlet UILabel *startKMLabel;
@property (nonatomic, weak) IBOutlet UILabel *endKMLabel;
@property (nonatomic, weak) IBOutlet UILabel *totalKMLabel;
@property (nonatomic, weak) IBOutlet UILabel *rateLabel;
@property (nonatomic, weak) IBOutlet UILabel *amountLabel;
@property (nonatomic, weak) IBOutlet UIButton *updateButton;
@property (nonatomic, weak) IBOutlet UILabel *sanctionAmtLabel;

-(void)fillValuesIntoCell:(EmpExpenseKMModel*)model;

@end

@implementation EmpExpenseKMType1Cell

-(void)fillValuesIntoCell:(EmpExpenseKMModel*)model {
    
    self.travelDateLabel.text = [Utility stringDateFromServerDate:model.trvl_date];
    self.travelDetailLabel.text = model.trvl_parti;
    self.startKMLabel.text = [NSString stringWithFormat:@"%ld",model.km_start];
    self.endKMLabel.text = [NSString stringWithFormat:@"%ld",model.km_end];
    self.totalKMLabel.text = [NSString stringWithFormat:@"%ld",model.km_total];
    self.rateLabel.text = [Utility stringWithCurrencySymbolForValue:[NSString stringWithFormat:@"%ld",(long)model.km_rate] forCurrencyCode:@"INR"];
    self.amountLabel.text = [Utility stringWithCurrencySymbolForValue:[NSString stringWithFormat:@"%ld",(long)model.trvl_amt] forCurrencyCode:@"INR"];
    self.sanctionAmtLabel.text = [Utility stringWithCurrencySymbolForValue:[NSString stringWithFormat:@"%ld",(long)model.sanc_amt] forCurrencyCode:@"INR"];
}
@end

# pragma mark - EmpExpenseKMType2Cell

@interface EmpExpenseKMType2Cell ()

@property (nonatomic, weak) IBOutlet UILabel *travelDateLabel;
@property (nonatomic, weak) IBOutlet UILabel *travelDetailLabel;
@property (nonatomic, weak) IBOutlet UILabel *totalKMLabel;
@property (nonatomic, weak) IBOutlet UILabel *rateLabel;
@property (nonatomic, weak) IBOutlet UILabel *amountLabel;
@property (nonatomic, weak) IBOutlet UIButton *updateButton;
@property (nonatomic, weak) IBOutlet UILabel *sanctionAmtLabel;

-(void)fillValuesIntoCell:(EmpExpenseKMModel*)model;

@end

@implementation EmpExpenseKMType2Cell

-(void)fillValuesIntoCell:(EmpExpenseKMModel*)model {
    self.travelDateLabel.text = [Utility stringDateFromServerDate:model.trvl_date];
    self.travelDetailLabel.text = model.trvl_parti;
    self.totalKMLabel.text = [NSString stringWithFormat:@"%ld",model.km_total];
    self.rateLabel.text = [Utility stringWithCurrencySymbolForValue:[NSString stringWithFormat:@"%ld",(long)model.km_rate] forCurrencyCode:@"INR"];
    self.amountLabel.text = [Utility stringWithCurrencySymbolForValue:[NSString stringWithFormat:@"%ld",(long)model.trvl_amt] forCurrencyCode:@"INR"];
    self.sanctionAmtLabel.text = [Utility stringWithCurrencySymbolForValue:[NSString stringWithFormat:@"%ld",(long)model.sanc_amt] forCurrencyCode:@"INR"];
}
@end

# pragma mark - EmpExpenseItemDetailViewController

@implementation EmpExpenseItemDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setItemDetailsArray:self.selectedExpenseModel.kmModelArray];
    [self.detailTableview reloadData];
    self.title = self.selectedExpenseModel.exp_desc;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegates

static NSString *type1Identifier = @"EmpExpenseKMType1CellIdentifier";
static NSString *type2Identifier = @"EmpExpenseKMType2CellIdentifier";

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section    {
    return self.itemDetailsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath  {
    
    EmpExpenseKMType1Cell *type1cell = [tableView dequeueReusableCellWithIdentifier:type1Identifier];
    EmpExpenseKMType2Cell *type2cell = [tableView dequeueReusableCellWithIdentifier:type2Identifier];
    
    EmpExpenseKMModel *model = [self.itemDetailsArray objectAtIndex:indexPath.row];
    
    if (self.selectedExpenseModel.exp_stat == 2) {
        [type1cell fillValuesIntoCell:model];
        type1cell.updateButton.tag = indexPath.row;
        return type1cell;
    }
    else if (self.selectedExpenseModel.exp_stat == 6)   {
        [type2cell fillValuesIntoCell:model];
        type2cell.updateButton.tag = indexPath.row;
        return type2cell;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
    return 210;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (IBAction)updateButtonAction:(id)sender   {
    NSInteger tag = ((UIButton*)sender).tag;
    EmpExpenseKMModel *model = [self.itemDetailsArray objectAtIndex:tag];
    [self.selectedExpenseModel setKmModel:model];
    [self presentSanctionAmountUpdateSheetForItem:self.selectedExpenseModel completion:^(BOOL valueUpdated, NSError *error) {
        
    }];
}

@end
