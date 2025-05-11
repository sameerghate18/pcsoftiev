//
//  Utility.m
//  ERPMobile
//
//  Created by Sameer Ghate on 07/09/14.
//  Copyright (c) 2014 Sameer Ghate. All rights reserved.
//

#import "Utility.h"

@implementation Utility


+(NSString*)lastRefreshString
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateStyle:NSDateFormatterLongStyle];
    NSString *retStr = [dateFormat stringFromDate:[NSDate date]];
    return retStr;
}

+(NSString*)stringWithCurrencySymbolForValue:(NSString*)valStr
{
    
    NSLocale *lcl = [[NSLocale alloc] initWithLocaleIdentifier:@"en_IN"];
                     
    NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
    [currencyFormatter setLocale:lcl];
    [currencyFormatter setMaximumFractionDigits:2];
    [currencyFormatter setMinimumFractionDigits:2];
    [currencyFormatter setAlwaysShowsDecimalSeparator:YES];
    [currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    NSNumber *someAmount = [NSNumber numberWithFloat:[valStr floatValue]];
    NSString *string = [currencyFormatter stringFromNumber:someAmount];
    
    return string;
}

+(NSString*)stringWithCurrencySymbolForValue:(NSString*)valStr forCurrencyCode:(NSString*)currencyCode
{
    
//    NSLocale *lcl = [[NSLocale alloc] initWithLocaleIdentifier:@"en_IN"];
    
    NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
//    [currencyFormatter setLocale:lcl];
    [currencyFormatter setMaximumFractionDigits:2];
    [currencyFormatter setCurrencyCode:currencyCode];
    [currencyFormatter setMinimumFractionDigits:2];
    [currencyFormatter setAlwaysShowsDecimalSeparator:YES];
    [currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    NSNumber *someAmount = [NSNumber numberWithDouble:[valStr doubleValue]];
    NSString *string = [currencyFormatter stringFromNumber:someAmount];
    
    return string;
}

+(NSString*)stringWithCurrencySymbolPrefix:(NSString*)value forCurrencySymbol:(NSString*)currencySymbol
{
  if (currencySymbol.length == 0) {
    return [Utility stringWithCurrencySymbolForValue:value forCurrencyCode:DEFAULT_CURRENCY_CODE];
  } else {
    return [NSString stringWithFormat:@"%@ %@",currencySymbol,value];
  }
}


+(UIColor *)randomColor
{
    
    CGFloat red = arc4random()% 256 / 256.0;
    CGFloat green = arc4random()% 256 / 256.0;
    CGFloat blue = arc4random()% 256 / 256.0;
    UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
    return color;
}

+(NSString*)stringDateFromServerDate:(NSString*)serverDate  {
    //4/2/2016 12:00:00 AM
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM/dd/yyyy HH:mm:ss a"];
    NSDate *newDate = [dateFormat dateFromString:serverDate];
     [dateFormat setDateFormat:@"dd/MM/yyyy"];
    NSString *finalString = [dateFormat stringFromDate:newDate];
    return finalString;
}

+(NSString*)stringDateFromServerDateYYYYMM:(NSString*)serverDate  {
    //4/2/2016 12:00:00 AM
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyyMM"];
    NSDate *newDate = [dateFormat dateFromString:serverDate];
     [dateFormat setDateFormat:@"MMM yyyy"];
    NSString *finalString = [dateFormat stringFromDate:newDate];
    return finalString;
}

+(void)showAlertWithTitle:(NSString*)title message:(NSString*)message buttonTitle:(NSString*)buttonTitle inViewController:(UIViewController*)viewController {
    
    UIAlertController *deviceSuccessVC = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * okAction = [UIAlertAction actionWithTitle:buttonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [deviceSuccessVC addAction:okAction];
    dispatch_async(dispatch_get_main_queue(), ^{
        [viewController presentViewController:deviceSuccessVC animated:YES completion:nil];
    });
    
}

@end
