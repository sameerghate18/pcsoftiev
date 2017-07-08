//
//  PCDailySalesGraphViewController.h
//  ERPMobile
//
//  Created by Sameer Ghate on 04/10/14.
//  Copyright (c) 2014 Sameer Ghate. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PCDailySalesViewController;

@interface PCDailySalesGraphViewController : UIViewController

@property (nonatomic, strong) NSDictionary *salesData;
@property (nonatomic, strong) NSString *currentMonthString;
@property (nonatomic, strong) NSString *lastMonthString;
@property (nonatomic, strong) NSString *prevToLastMonthString;
@property (nonatomic, strong) NSString *currencyCode;
@property (nonatomic) SalesType selectedSalesType;

@end

@interface PCSalesGraphCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *monthLabel;
@property (nonatomic, strong) IBOutlet UILabel *salesAmountLabel;
@property (nonatomic, strong) IBOutlet UIView *legendView;


@end