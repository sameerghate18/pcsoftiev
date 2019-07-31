//
//  PCDeviceLicenseModel.h
//  ERPMobile
//
//  Created by Sameer Ghate on 19/11/14.
//  Copyright (c) 2014 Sameer Ghate. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PCDeviceLicenseModel : NSObject

@property (nonatomic, strong) NSString *CO_NAME;
@property (nonatomic, strong) NSString *ERRORMESSAGE;
@property (nonatomic, strong) NSString *LIC_NOS;
@property (nonatomic, strong) NSString *LIC_USED;
@property (nonatomic, strong) NSString *URL_CD;
@property (nonatomic, strong) NSString *WEB_URL;

@end
