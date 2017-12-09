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

//#define kAppBaseURL @"http://www.int-e-view.com:88/Service.svc/"
//#define kAppBaseURL @"http://115.115.180.253/pcsoftiev/service.svc/"
//#define kAppBaseURL @"http://115.115.180.253/getiev/Service.svc/"
// domain name
//#define kAppBaseURL @"http://www.ievmobile.com/getiev/Service.svc/"
#define kAppBaseURL @"https://ievmobile.com/https/Service.svc/"



#define kCompanyBaseURL @"CompanyBaseURL"
#define kSelectedCompanyCode @"selectedCompanyCode"
#define kSelectedCompanyLongname @"selectedCompanyLongName"
#define kSelectedCompanyName @"selectedCompanyName"
#define kAccessCode @"accessCode"
#define kPhoneNumber @"phoneNumber"

//#define kVerifyCodeURL @"http://www.int-e-view.com:88/Service.svc/GetServiceUrl?scocd="
//#define kVerifyCodeURL @"http://115.115.180.253/pcsoftiev/service.svc/GetServiceUrl?scocd="
//#define kVerifyCodeURL @"http://115.115.180.253/getiev/Service.svc/GetServiceUrl?scocd="
//#define kVerifyCodeURL @"http://www.ievmobile.com/getiev/Service.svc/GetServiceUrl?scocd="
#define kVerifyCodeURL @"https://ievmobile.com/https/Service.svc/GetServiceUrl?scocd="

//#define kLicenseAddURL @"http://www.int-e-view.com:88/service.svc/GetUpdateLic?scocd="
//#define kLicenseAddURL @"http://115.115.180.253/pcsoftiev/service.svc/GetUpdateLic?scocd="
//#define kLicenseAddURL @"http://115.115.180.253/getiev/Service.svc/GetUpdateLic?scocd="
//#define kLicenseAddURL @"http://www.ievmobile.com/getiev/Service.svc/GetUpdateLic?scocd="
#define kLicenseAddURL @"https://ievmobile.com/https/Service.svc/GetUpdateLic?scocd="

#define kCheckForDeviceAlreadyRegistered @""

#define kCompanyListService @"GetAllCompany"
#define kUsernamesService @"GetUser?scocd="
#define kCompanySalesService @"gettodayssale?scocd="
#define kUserLogoutService @"logout?scocd="

#define kInvoicesService @"GetInvoice?scocd="

#define kCountListService @"authlstcnt"

#define kRejectionsService(selComp,value) @"GetRejection?scocd=("selComp")&Xvalue=("value")"

#define kAttendanceService @"GetAttendance?scocd=SE&rperson="
#define kCashFlowService @"GetCashFlow?scocd=SE&sDate=2014-04-15"

#define GET_EECount_URL(baseURL, scocd,userId) \
[NSString stringWithFormat:@"%@/authlstcnt?scocd=%@&userId=%@",baseURL,scocd,userId];  \

#define GET_AUTH_LIST_URL(baseURL,scocd,userId) \
[NSString stringWithFormat:@"%@/authlist?scocd=%@&userId=%@&type=EP",baseURL,scocd,userId];  \

#define kGETEECountURL(baseURL,scocd, userId)  \
[NSString stringWithFormat:@"%@\authlstcnt?scocd=%@&userId=%@",baseURL,scocd,userId];  \

#define GET_EE_DETAIL_URL(baseURL,scocd,userId,doctype,docno)    \
[NSString stringWithFormat:@"%@/GetDocDtlEXP?scocd=%@&userId=%@&doctype=%@&docno=%@",baseURL,scocd,userId,doctype,docno];  \

#define GET_EE_Exp_KM_URL(baseURL,scocd,userId,doctype,docno) \
[NSString stringWithFormat:@"%@/GetDocDtlEXPKm?scocd=%@&userId=%@&doctype=%@&docno=%@",baseURL,scocd,userId,doctype,docno];\

#define GET_SUBMIT_EXPENSE_URL(baseURL,scocd,userId,docno,expJson)  \
[NSString stringWithFormat:@"%@/submitexpE?scocd=%@&userid=%@&docno=%@&exptrndt=%@",baseURL,scocd,userId,docno,expJson] ;   \

#define GET_PAGE_SUBMIT_URL(baseURL,scocd,userId,docno,expJson,kmValue) \
[NSString stringWithFormat:@"%@/submitexpE?scocd=%@&userid=%@&docno=?&exptrndt=%@&exptrnkm=%@",baseURL,scocd,userId,expJson,kmValue];  \

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
