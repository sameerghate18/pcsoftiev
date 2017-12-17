//
//  EmpExpenseItemListViewController.h
//  PCSOFT-IEV
//
//  Created by Sameer Ghate on 17/12/17.
//  Copyright © 2017 Sameer Ghate. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EmpExpenseKMModel.h"
#import "EmpExpenseItemModel.h"

@interface EmpExpenseItemListViewController : UIViewController

@property (nonatomic, strong) NSArray *detailModelsArray;
@property (nonatomic, strong) IBOutlet UITableView *itemsTableview;

- (void)presentSanctionAmountUpdateSheetForItem:(EmpExpenseItemModel*)model completion:(void(^)(BOOL valueUpdated, NSError *error))completionBlock;

@end

@interface EETableviewCell : UITableViewCell

@end
