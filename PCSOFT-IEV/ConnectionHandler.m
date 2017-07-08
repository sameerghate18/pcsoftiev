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
    NSString *escapedPath = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:escapedPath]];
    [request setHTTPMethod:kHTTP_Method_GET];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    
    if ([reachability currentReachabilityStatus] != NotReachable ) {
        
        [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            
            if (connectionError == nil) {
                if ([_delegate respondsToSelector:@selector(connectionHandler:didRecieveData:)]) {
                    [_delegate connectionHandler:self didRecieveData:data];
                }
            }
            else {
                if ([_delegate respondsToSelector:@selector(connectionHandler:errorRecievingData:)]) {
                    [_delegate connectionHandler:self errorRecievingData:connectionError];
                }
            }
            
        }];
        
    }
    else {
        
        NSError *noInternetError = [NSError errorWithDomain:@"com.ERPMobile.IEV" code:-5000 userInfo:nil];
        
        if ([_delegate respondsToSelector:@selector(connectionHandler:errorRecievingData:)]) {
            [_delegate connectionHandler:self errorRecievingData:noInternetError];
        }
        
    }
    
    
    
}

@end
