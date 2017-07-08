//
//  BookCell.h
//  AnimationDemo
//
//  Created by Rachel Bobbins on 1/31/15.
//  Copyright (c) 2015 Rachel Bobbins. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AttendanceDetailCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *employeeName, *empNumber, *reportingTo, *ofcTimeIn, *shiftDate, *fromDate, *toDate, *reason;
@property (weak, nonatomic) IBOutlet UIView *detailContainerView;

@property (nonatomic, assign) BOOL withDetails;

- (void)animateOpen;
- (void)animateClosed;

@end
