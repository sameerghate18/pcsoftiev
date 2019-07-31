//
//  PCSendBackViewController.h
//  PCSOFT-IEV
//
//  Created by Sameer Ghate on 11/01/16.
//  Copyright © 2016 Sameer Ghate. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PCTransactionModel.h"

@protocol PCSendBackViewControllerDelegate;

@interface PCSendBackViewController : UIViewController

@property (nonatomic, strong) PCTransactionModel *selectedTransaction;

@property (nonatomic, unsafe_unretained) id <PCSendBackViewControllerDelegate> delegate;

@end

@protocol PCSendBackViewControllerDelegate <NSObject>

@optional
-(void)sendBackDidFinishSendingBackDoc;
-(void)sendBackDidFailSendingBackDoc;

@end