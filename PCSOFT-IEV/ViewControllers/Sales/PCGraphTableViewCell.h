//
//  PCGraphTableViewCell.h
//  ERPMobile
//
//  Created by Sameer Ghate on 06/10/14.
//  Copyright (c) 2014 Sameer Ghate. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PCGraphTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *monthLabel;
@property (nonatomic, strong) IBOutlet UILabel *payableLabel;
@property (nonatomic, strong) IBOutlet UILabel *recievableLabel;

@end
