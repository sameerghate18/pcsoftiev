//
//  EmpExpenseItemModel.h
//  PCSOFT-IEV
//
//  Created by Sameer Ghate on 17/12/17.
//  Copyright © 2017 Sameer Ghate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EmpExpenseKMModel.h"

typedef enum{
    NewValueLesser,
    NewValueEqual,
    NewValueMore
} NewValueChange;

@interface EmpExpenseItemModel : NSObject

@property (nonatomic, strong) NSString *ERRORMESSAGE;
@property (nonatomic) BOOL deleteAll;
@property (nonatomic, strong) NSString *doc_date;//": "3/30/2017 12:00:00 AM",
@property (nonatomic, strong) NSString *doc_no;//": "111111617000003",
@property (nonatomic, strong) NSString *doc_type;//": "   EP",
@property (nonatomic) BOOL editAll;//": false,
@property (nonatomic, strong) NSString *emp_no;//": "E0403",
@property (nonatomic) NSInteger exp_amt;//": 5000,
@property (nonatomic, strong) NSString *exp_code;//": "01",
@property (nonatomic, strong) NSString *exp_date;//": "3/30/2017 12:00:00 AM",
@property (nonatomic, strong) NSString *exp_desc;//": "D.A. AND FOOD",
@property (nonatomic, strong) NSString *exp_parti;//": "aaaaaa",
@property (nonatomic) NSInteger exp_stat;//": 1,
@property (nonatomic, strong) NSString *id_key;//": "128",
@property (nonatomic, strong) NSString *party_name;//": "ENRICH SPACES LLP",
@property (nonatomic, strong) NSString *projct_no;//": "10014",
@property (nonatomic) NSInteger sanc_amt;//": 2500
@property (nonatomic) BOOL sancAmountChanged;
@property (nonatomic) NewValueChange valueChange;
@property (nonatomic, strong) NSArray *kmModelArray;
@property (nonatomic, strong) EmpExpenseKMModel *kmModel;

@end
