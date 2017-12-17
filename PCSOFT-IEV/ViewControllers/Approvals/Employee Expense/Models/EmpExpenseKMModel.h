//
//  EmpExpenseKMModel.h
//  PCSOFT-IEV
//
//  Created by Sameer Ghate on 17/12/17.
//  Copyright © 2017 Sameer Ghate. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EmpExpenseKMModel : NSObject

@property (nonatomic, strong) NSString *ERRORMESSAGE;//": "",
@property (nonatomic, strong) NSString *doc_no;//": "222221617000005",
@property (nonatomic, strong) NSString *doc_type;//": "   EP",
@property (nonatomic) NSInteger exp_amt;//": 0,
@property (nonatomic, strong) NSString *exp_code;//": "11",
@property (nonatomic, strong) NSString *id_key;//": "28",
@property (nonatomic) NSInteger km_end;//": 0,
@property (nonatomic) NSInteger km_rate;//": 27,
@property (nonatomic) NSInteger km_start;//": 0,
@property (nonatomic) NSInteger km_total;//": 20,
@property (nonatomic, strong) NSString *projct_no;//": "10001",
@property (nonatomic) NSInteger sanc_amt;//": 540,
@property (nonatomic) NSInteger trvl_amt;//": 540,
@property (nonatomic, strong) NSString *trvl_date;//": "3/30/2017 12:00:00 AM",
@property (nonatomic, strong) NSString *trvl_parti;//": "TRAVEL KM"
@property (nonatomic) BOOL sancAmountChanged;

@end
