//
//  PCRejectionsTableViewCell.h
//  ERPMobile
//
//  Created by Sameer Ghate on 11/10/14.
//  Copyright (c) 2014 Sameer Ghate. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PCRejectionsTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *itemCodeLabel;
@property (nonatomic, strong) IBOutlet UILabel *totalQtyLbl;
@property (nonatomic, strong) IBOutlet UILabel *totalValueLabel;
@property (nonatomic, strong) IBOutlet UILabel *rateLabel;

@end
