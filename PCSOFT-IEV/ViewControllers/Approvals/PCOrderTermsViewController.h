//
//  PCOrderTermsViewController.h
//  PCSOFT-IEV
//
//  Created by Harsha Jain on 01/05/25.
//  Copyright © 2025 Sameer Ghate. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PCTransactionDetailModel.h"
#import "PCTransactionModel.h"

@interface PCOrderTermsViewController : UIViewController

@property (nonatomic, strong) PCTransactionModel *selectedModel;
@property (nonatomic, strong) NSString *selectedDoctype;
@property (nonatomic, strong) IBOutlet UITableView *orderTermsTableview1;

@end

@interface PCOrderTermsTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *orderNo;
@property (nonatomic, strong) IBOutlet UILabel *termCategory;
@property (nonatomic, strong) IBOutlet UILabel *termValue;
@property (nonatomic, strong) IBOutlet UILabel *termDescription;

@end



