//
//  PCCompanyModel.h
//  ERPMobile
//
//  Created by Sameer Ghate on 31/08/14.
//  Copyright (c) 2014 Sameer Ghate. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PCCompanyModel : NSObject

@property (nonatomic, strong) NSString *CDATABASE;
@property (nonatomic, strong) NSString *CO_CD;
@property (nonatomic, strong) NSString *CPWD;
@property (nonatomic, strong) NSString *LONG_CO_NM;
@property (nonatomic, strong) NSString *NAME;
@property (nonatomic, strong) NSString *ERRORMESSAGE;
@property (nonatomic, strong) NSString *FLAG;
@property (nonatomic) BOOL TBGRP;
@property (nonatomic, strong) NSString *binloc;
@property (nonatomic, strong) NSString *qc;
@property (nonatomic) BOOL OILVERTICAL;
@property (nonatomic) BOOL agent;

@end
