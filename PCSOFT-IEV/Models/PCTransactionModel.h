//
//  PCTransactionModel.h
//  ERPMobile
//
//  Created by Sameer Ghate on 04/10/14.
//  Copyright (c) 2014 Sameer Ghate. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PCTransactionModel : NSObject

@property (nonatomic, strong) NSString *doc_date;
@property (nonatomic, strong) NSString *doc_desc;
@property (nonatomic, strong) NSString *doc_no;
@property (nonatomic, strong) NSString *doc_type;
@property (nonatomic, strong) NSNumber *im_basic;
@property (nonatomic, strong) NSString *party_name;
@property (nonatomic, strong) NSString *user_name;
@property (nonatomic, strong) NSString *doc_taxs;
@property (nonatomic, strong) NSNumber *seq_no;
@property (nonatomic, strong) NSString *doc_ref;
@property (nonatomic, strong) NSString *cursymbl;
@property (nonatomic, strong) NSNumber *gst;
@property (nonatomic, strong) NSNumber *outstanding;
@property (nonatomic, strong) NSNumber *balsaudaqty;
@property (nonatomic, strong) NSNumber *saudaqty;
@property (nonatomic, strong) NSString *sr;
@property (nonatomic, strong) NSString *amendtype;
@property (nonatomic, strong) NSString *PAY_CD;
@property (nonatomic, strong) NSString *SHP_CD;
@property (nonatomic, strong) NSString *FRT_CD;
@property (nonatomic, strong) NSString *INS_CD;
@property (nonatomic, strong) NSString *PKG_CD;
@property (nonatomic, strong) NSString *BKG_CD;
@property (nonatomic, strong) NSString *STX_CD;
@property (nonatomic, strong) NSString *EXC_CD;
@property (nonatomic, strong) NSString *TPR_CD;
@property (nonatomic, strong) NSString *agentname;
@end
