//
//  PCProjectionTableViewCell.h
//  ERPMobile
//
//  Created by Sameer Ghate on 08/09/14.
//  Copyright (c) 2014 Sameer Ghate. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PCProjectionTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *payableLabel, *recievableLabel, *monthLabel;
@property (nonatomic, strong) IBOutlet UIImageView *bgImgView;

@end
