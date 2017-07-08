//
//  PCApprovalItemDetailTableViewController.h
//  ERPMobile
//
//  Created by Sameer Ghate on 30/10/14.
//  Copyright (c) 2014 Sameer Ghate. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PCTransactionDetailModel.h"

@interface PCApprovalItemDetailTableViewController : UITableViewController

@property (nonatomic, strong) PCTransactionDetailModel *selectedModel;
@property (nonatomic, strong) NSString *selectedDoctype;
@property (nonatomic) TXType txtype;

@end
