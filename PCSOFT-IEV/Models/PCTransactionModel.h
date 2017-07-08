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

@end
