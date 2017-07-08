//
//  PCTransactionDetailModel.h
//  ERPMobile
//
//  Created by Sameer Ghate on 30/10/14.
//  Copyright (c) 2014 Sameer Ghate. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PCTransactionDetailModel : NSObject

@property (nonatomic, strong) NSString *descr;
@property (nonatomic, strong) NSString *item;
@property (nonatomic, strong) NSString *code;
@property (nonatomic, strong) NSString *dborcr;
@property (nonatomic, strong) NSString *doc_ref;
@property (nonatomic, strong) NSString *im_lot;
@property (nonatomic, strong) NSString *party_name;
@property (nonatomic, strong) NSString *rdoc_no;
@property (nonatomic, strong) NSString *rdoc_type;
@property (nonatomic, strong) NSString *doc_taxs;
@property (nonatomic, strong) NSString *subdesc;
@property (nonatomic) NSNumber *line_taxes;
@property (nonatomic) NSNumber *qty;
@property (nonatomic) NSNumber *rate;
@property (nonatomic) NSNumber *total;
@property (nonatomic) NSNumber *value;


@end
