//
//  PCDeviceRegisterCheck.h
//  ERPMobile
//
//  Created by Sameer Ghate on 16/01/15.
//  Copyright (c) 2015 Sameer Ghate. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PCDeviceRegisterCheckModel : NSObject

@property (nonatomic,strong) NSString *IsActive;
@property (nonatomic,strong) NSString *IsDeviceRegistered;
@property (nonatomic,strong) NSString *IsMobileRegistered;
@property (nonatomic,strong) NSString *ERRORMESSAGE;
@end