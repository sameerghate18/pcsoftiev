//
//  Constants.h
//  ERPMobile
//
//  Created by Sameer Ghate on 30/08/14.
//  Copyright (c) 2014 Sameer Ghate. All rights reserved.
//

#ifndef ERPMobile_Constants_h
#define ERPMobile_Constants_h

#import "AppDelegate.h"
#import "PCCompanyModel.h"
#import "PCUserModel.h"

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)

typedef enum{
    TXTypePO,
    TXTypeSO,
    TXTypePayments,
    TXTypeEmployeeExpense,
    TXTypePI,
    TXTypeRB,
    TXTypePCR
}TXType;

typedef enum
{
    SalesTypeDomestic,
    SalesTypeExport
}SalesType;

#define DEFAULT_CURRENCY_CODE @"INR"

#define kStoryboard [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]]
#define kAppDelegate (AppDelegate*)[[UIApplication sharedApplication] delegate]

#define TimeStamp [NSString stringWithFormat:@"%f",[[NSDate new] timeIntervalSince1970] * 1000]

#define IS_REGISTRATION_COMPLETE_KEY @"isRegistrationCompleted"

// https://app.ieverp.com/barcode/sahyadri/
//  https://app.ieverp.com/ievsrv/
// Below URLs are not to be used.
//#define kAppBaseURL @"https://ievmobile.com/https/Service.svc/"
//#define kVerifyCodeURL @"https://ievmobile.com/https/Service.svc/GetServiceUrl?scocd="
//#define kLicenseAddURL @"https://ievmobile.com/https/Service.svc/GetUpdateLic?scocd="

#define kCompanyBaseURL @"CompanyBaseURL"
#define kSelectedCompanyCode @"selectedCompanyCode"
#define kSelectedCompanyLongname @"selectedCompanyLongName"
#define kSelectedCompanyName @"selectedCompanyName"
#define kAccessCode @"accessCode"
#define kPhoneNumber @"phoneNumber"
#define kScoCodeKey @"scocd"
#define kDeviceIDKey @"DeviceID"
#define kMobNoKey @"MobNo"
#define kTokenKey @"token"
#define kTokenTypeKey @"tokentype"
#define kDataKey @"data"

#define kCheckForDeviceAlreadyRegistered @""

#define kCompanyListService @"/iev/GetAllCompany"
#define kUsernamesService @"/iev/GetUser?scocd="
#define kTblGrpService @"/iev/tbgrplst"
#define kCompanySalesService @"gettodayssale?scocd="
#define kGetSalesForGroup(selComp,grpCode) \
[NSString stringWithFormat:@"GetTodaysSaleTB?scocd=%@&tbgrp=%@",selComp,grpCode];  \

#define kUserLogoutService @"logout?scocd="

#define kInvoicesService @"GetInvoice?scocd="

#define kCountListService @"authlstcnt"

#define kRejectionsService(selComp,value) @"GetRejection?scocd=("selComp")&Xvalue=("value")"

#define kAttendanceService @"GetAttendance?scocd=SE&rperson="
#define kCashFlowService @"GetCashFlow?scocd=SE&sDate=2014-04-15"

#define GET_EECount_URL(baseURL, scocd,userId) \
[NSString stringWithFormat:@"%@/iev/authlstcnt?scocd=%@&userId=%@",baseURL,scocd,userId];  \

// Get the list of pending authorizations for the user
#define GET_Pending_Auths_URL(baseURL, scocd,userId) \
[NSString stringWithFormat:@"%@/iev/authlstcnt?SCOCD=%@&USERID=%@",baseURL,scocd,userId];  \

// Get details of pending authorization for the selected doctype
#define GET_Auths_List_URL(baseURL,scocd,userId,doctype) \
[NSString stringWithFormat:@"%@/iev/authlist?SCOCD=%@&USERID=%@&type=%@",baseURL,scocd,userId,doctype];  \

#define GET_EE_DETAIL_URL(baseURL,scocd,userId,doctype,docno)    \
[NSString stringWithFormat:@"%@/GetDocDtlEXP?scocd=%@&userId=%@&doctype=%@&docno=%@",baseURL,scocd,userId,doctype,docno];  \

#define GET_EE_Exp_KM_URL(baseURL,scocd,userId,doctype,docno) \
[NSString stringWithFormat:@"%@/GetDocDtlEXPKm?scocd=%@&userId=%@&doctype=%@&docno=%@",baseURL,scocd,userId,doctype,docno];\

#define GET_SUBMIT_EXPENSE_URL(baseURL,scocd,userId,docno,expJson)  \
[NSString stringWithFormat:@"%@/submitexpE?scocd=%@&userid=%@&docno=%@&exptrndt=%@",baseURL,scocd,userId,docno,expJson] ;   \

#define GET_PAGE_SUBMIT_URL(baseURL,scocd,userId,docno,expJson,kmValue) \
[NSString stringWithFormat:@"%@/submitexpE?scocd=%@&userid=%@&docno=%@&exptrndt=%@&exptrnkm=%@",baseURL,scocd,userId,docno,expJson,kmValue];  \

#define kHTTP_Method_POST @"POST"
#define kHTTP_Method_GET @"GET"
#define kHTTP_Method_PUT @"PUT"
#define kHTTP_Method_DELETE @"DELETE"
#endif

// Error Domains

#define kErrorDomainUnwantedOutput @"unwanted_output"
#define kErrorDomainDeviceErrors @"device_error_domain"
#define kErrorDomainBlankOutput @"blank_output"

// Connection Handlers Tag

#define kCheckDeviceRegisteredTag       100
#define kUpdateLicenseTag                    101
#define kRegisterDeviceTag                   102
#define kGetServiceURLTag                   103
#define kGetUserNamesListTag              104
#define kUpdateMobileNumberTag          105
#define kUpdateDeviceRegisterTag         106

#define kUserLoginTag 201

// Settings

#define kPaymentAuthPwdEnabled @"AuthPwdEnabled"

#define noInternetMessage @"Internet connection appears to be unavailable.\nPlease check your connection and try again."

#define kCustomGray @"custom gray"
#define kCustomBlack @"custom black"
#define kCustomWhite @"custom white"
#define kCustomYellow @"custom yellow"
#define kCustomBlue @"custom blue"

