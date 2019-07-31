//
//  PCPOSOTransactionsTableViewController.h
//  ERPMobile
//
//  Created by Sameer Ghate on 09/09/14.
//  Copyright (c) 2014 Sameer Ghate. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PCApprovalListModel.h"

@interface PCPOSOTransactionsTableViewController : UIViewController

@property (nonatomic, strong) PCApprovalListModel *selectedApprovalType;

@end

@interface PCPOSOTransactionsTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *docNumberLabel;

@end
