//
//  PCRejectionsGraphViewController.h
//  ERPMobile
//
//  Created by Sameer Ghate on 30/09/14.
//  Copyright (c) 2014 Sameer Ghate. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PCRejectionsGraphViewController : UIViewController

@property (nonatomic, strong) NSArray *rejectionsData;

@end

@interface PCRejectionsGraphCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *itemCode;
@property (nonatomic, strong) IBOutlet UILabel *itemQty;
@property (nonatomic, strong) IBOutlet UIView *colorBox;

@end