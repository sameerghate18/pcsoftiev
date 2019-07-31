//
//  PCApprovalListModel.h
//  PCSOFT-IEV
//
//  Created by Sameer Ghate on 07/08/18.
//  Copyright © 2018 Sameer Ghate. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PCApprovalListModel : NSObject

@property (nonatomic, strong) NSString *doc_date;
@property (nonatomic, strong) NSString *doc_desc;
@property (nonatomic, strong) NSString *doc_no;
@property (nonatomic, strong) NSString *doc_ref;
@property (nonatomic, strong) NSString *doc_taxs;
@property (nonatomic, strong) NSString *doc_type;
@property (nonatomic, strong) NSString *im_basic;
@property (nonatomic, strong) NSString *party_name;
@property (nonatomic, strong) NSString *seq_no;
@property (nonatomic, strong) NSString *user_name;

-(id)initWithDictionary:(NSDictionary *)dictionary;

@end
