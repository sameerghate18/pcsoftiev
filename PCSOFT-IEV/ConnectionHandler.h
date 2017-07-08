//
//  ConnectionHandler.h
//  ERPMobile
//
//  Created by Sameer Ghate on 31/08/14.
//  Copyright (c) 2014 Sameer Ghate. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol ConnectionHandlerDelegate;

@interface ConnectionHandler : NSObject

@property (nonatomic, unsafe_unretained) id<ConnectionHandlerDelegate>delegate;
@property (nonatomic) int tag;

-(void)fetchDataForURL:(NSString*)urlString body:(NSDictionary*)bodyParams;

@end

@protocol ConnectionHandlerDelegate <NSObject>

-(void)connectionHandler:(ConnectionHandler*)conHandler didRecieveData:(NSData*)data;
-(void)connectionHandler:(ConnectionHandler*)conHandler errorRecievingData:(NSError*)error;

@end