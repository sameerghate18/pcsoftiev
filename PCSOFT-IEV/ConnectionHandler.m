//
//  ConnectionHandler.m
//  ERPMobile
//
//  Created by Sameer Ghate on 31/08/14.
//  Copyright (c) 2014 Sameer Ghate. All rights reserved.
//

#import "ConnectionHandler.h"
#import "Reachability.h"

@implementation ConnectionHandler

-(void)fetchDataForURL:(NSString*)urlString body:(NSDictionary*)bodyParams
{
  
  NSLog(@"\n \nfetchDataForURL - %@\n\n",urlString);
  
  NSString *escapedPath = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
  
  NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:escapedPath]];
  [request setHTTPMethod:kHTTP_Method_GET];
  
  Reachability *reachability = [Reachability reachabilityForInternetConnection];
  
  if ([reachability currentReachabilityStatus] != NotReachable ) {
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration] ;
    [configuration setRequestCachePolicy:NSURLRequestUseProtocolCachePolicy];
      if (@available(iOS 13.0, *)) {
          [configuration setTLSMinimumSupportedProtocolVersion:tls_protocol_version_TLSv10];
      } else {
          // Fallback on earlier versions
          [configuration setTLSMinimumSupportedProtocol:kTLSProtocol1];
      }
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
      
      if (error == nil) {
        if ([self->_delegate respondsToSelector:@selector(connectionHandler:didRecieveData:)]) {
          [self->_delegate connectionHandler:self didRecieveData:data];
        }
      }
      else {
        if ([self->_delegate respondsToSelector:@selector(connectionHandler:errorRecievingData:)]) {
          [self->_delegate connectionHandler:self errorRecievingData:error];
        }
      }
      
    }];
    
    [dataTask resume];
  }
  else {
    NSError *noInternetError = [NSError errorWithDomain:@"com.ERPMobile.IEV" code:-5000 userInfo:nil];
    
    if ([self->_delegate respondsToSelector:@selector(connectionHandler:errorRecievingData:)]) {
      [self->_delegate connectionHandler:self errorRecievingData:noInternetError];
    }
    
  }
}

- (void)fetchDataForGETURL:(NSString*)urlString body:(NSDictionary*)bodyParams completion:(void(^)(id responseData, NSError *error))completionBlock   {
  
  NSLog(@"\n \nfetchDataForGETURL - %@\n\n",urlString);
  
  Reachability *reachability = [Reachability reachabilityForInternetConnection];
  
  if ([reachability currentReachabilityStatus] != NotReachable ) {
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:1800];
    request.HTTPMethod = kHTTP_Method_GET;
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration] ;
    [configuration setRequestCachePolicy:NSURLRequestUseProtocolCachePolicy];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
      
      completionBlock(data,error);
      
    }];
    [dataTask resume];
  } else {
      NSError *noInternetError = [NSError errorWithDomain:@"com.ERPMobile.IEV" code:-5000 userInfo:nil];
      completionBlock(nil, noInternetError);
  }
}

@end
