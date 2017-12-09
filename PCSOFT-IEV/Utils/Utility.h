//
//  Utility.h
//  ERPMobile
//
//  Created by Sameer Ghate on 07/09/14.
//  Copyright (c) 2014 Sameer Ghate. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utility : NSObject

+(NSString*)lastRefreshString;
+(NSString*)stringWithCurrencySymbolForValue:(NSString*)valStr forCurrencyCode:(NSString*)currencyCode;
+(UIColor *)randomColor;
+(NSString*)stringDateFromServerDate:(NSString*)serverDate;

@end
