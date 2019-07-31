//
//  EmpExpenseItemDetailViewController.h
//  PCSOFT-IEV
//
//  Created by Sameer Ghate on 17/12/17.
//  Copyright © 2017 Sameer Ghate. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EmpExpenseItemListViewController.h"
#import "EmpExpenseKMModel.h"
#import "EmpExpenseItemModel.h"

@interface EmpExpenseItemDetailViewController : EmpExpenseItemListViewController

@property (nonatomic, strong) EmpExpenseItemModel *selectedExpenseModel;
@property (nonatomic, strong) NSArray *itemDetailsArray;
@end

@interface EmpExpenseKMType2Cell : UITableViewCell

@end

@interface EmpExpenseKMType1Cell : UITableViewCell

@end
