//
//  PCEmployeeExpenseViewController.h
//  PCSOFT-IEV
//
//  Created by Sameer Ghate on 08/12/17.
//  Copyright © 2017 Sameer Ghate. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PCTransactionModel.h"

@interface EETableviewCell : UITableViewCell

@end

@interface PCEmployeeExpenseViewController : UIViewController

@property (nonatomic, strong) PCTransactionModel *selectedTransaction;

@end

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

@end

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

    @property (nonatomic, strong) EmpExpenseKMModel *kmModel;

@end
