//
//  PCAttendanceTableViewCell.h
//  ERPMobile
//
//  Created by Sameer Ghate on 16/09/14.
//  Copyright (c) 2014 Sameer Ghate. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PCAttendanceTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *employeeName, *empNumber, *reportingTo, *ofcTimeIn, *shiftDate, *fromDate, *toDate, *reason;

@property (nonatomic, assign) BOOL withDetails;

@end
