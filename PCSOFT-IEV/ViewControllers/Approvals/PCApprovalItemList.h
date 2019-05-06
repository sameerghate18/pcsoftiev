//
//  PCApprovalItemList.h
//  ERPMobile
//
//  Created by Sameer Ghate on 30/10/14.
//  Copyright (c) 2014 Sameer Ghate. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PCSingleTransactionViewController;

@interface PCApprovalItemList : UITableViewController

@property (nonatomic, strong) NSArray *itemsListArray;
//@property (nonatomic, strong) PCSingleTransactionViewController *parentViewController;
@property (nonatomic, strong) NSString *selectedDoctype;

@end
