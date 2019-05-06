//
//  PCApprovalListModel.m
//  PCSOFT-IEV
//
//  Created by Sameer Ghate on 07/08/18.
//  Copyright © 2018 Sameer Ghate. All rights reserved.
//

#import "PCApprovalListModel.h"

@implementation PCApprovalListModel

-(id)initWithDictionary:(NSDictionary *)dictionary {
    
    if ([super init]) {
        
        if (dictionary[@"doc_date"]) {
            self.doc_date = dictionary[@"doc_date"];
        }
        
        if (dictionary[@"doc_desc"]) {
            self.doc_desc = dictionary[@"doc_desc"];
        }
        
        if (dictionary[@"doc_no"]) {
            self.doc_no = dictionary[@"doc_no"];
        }
        
        if (dictionary[@"doc_ref"]) {
            self.doc_ref = dictionary[@"doc_ref"];
        }
        
        if (dictionary[@"doc_taxs"]) {
            self.doc_taxs = dictionary[@"doc_taxs"];
        }
        
        if (dictionary[@"doc_type"]) {
            self.doc_type = dictionary[@"doc_type"];
        }
        
        if (dictionary[@"im_basic"]) {
            self.im_basic = dictionary[@"im_basic"];
        }
        
        if (dictionary[@"party_name"]) {
            self.party_name = dictionary[@"party_name"];
        }
        
        if (dictionary[@"seq_no"]) {
            self.seq_no = dictionary[@"seq_no"];
        }
        
        if (dictionary[@"user_name"]) {
            self.user_name = dictionary[@"user_name"];
        }
    }
    
    return self;
}

@end
