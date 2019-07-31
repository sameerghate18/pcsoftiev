//
//  PCUpdateMobileNumberViewController.h
//  ERPMobile
//
//  Created by Sameer Ghate on 29/10/15.
//  Copyright © 2015 Sameer Ghate. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PCUpdateMobileNumberViewControllerDelegate;

@interface PCUpdateMobileNumberViewController : UIViewController

@property (nonatomic, strong) NSString *accessCode;
@property (nonatomic, strong) NSString *phoneNumber;

@property (nonatomic, unsafe_unretained) id<PCUpdateMobileNumberViewControllerDelegate> delegate;

@end

@protocol PCUpdateMobileNumberViewControllerDelegate <NSObject>

@optional
-(void)didUpdateMobileNumber:(NSString*)newNumber;
-(void)didCancelUpdatingNumber;
-(void)mobileNumberRemainUnchanged;

@end
