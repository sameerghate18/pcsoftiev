//
//  PCSingleTransactionViewController.h
//  ERPMobile
//
//  Created by Sameer Ghate on 04/10/14.
//  Copyright (c) 2014 Sameer Ghate. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PCTransactionModel.h"
#import "PCTransactionDetailModel.h"

@interface PCSingleTransactionViewController : UIViewController

@property (nonatomic, strong) PCTransactionModel *selectedTransaction;

//@property (nonatomic) TXType txType;

@end


