//
//  PCEmployeeExpenseViewController.h
//  PCSOFT-IEV
//
//  Created by Sameer Ghate on 08/12/17.
//  Copyright © 2017 Sameer Ghate. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PCTransactionModel.h"

@interface EETableviewCell : UITableViewCell

@end

@interface PCEmployeeExpenseViewController : UIViewController

@property (nonatomic, strong) PCTransactionModel *selectedTransaction;

@end
