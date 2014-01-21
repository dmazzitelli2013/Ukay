//
//  ServerConnectionManager.h
//  Ukay
//
//  Created by David Mazzitelli on 6/10/13.
//  Copyright (c) 2013 David Mazzitelli. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ServerConnectionManagerDelegate <NSObject>

@required
- (void)serverRespondsWithErrorCode:(NSInteger)code;
- (void)serverRespondsWithData:(NSDictionary *)data;

@end

@interface ServerConnectionManager : NSObject

@property (nonatomic, assign) id<ServerConnectionManagerDelegate> delegate;

- (void)loginWithUsername:(NSString *)username andPassword:(NSString *)password andPushToken:(NSString *)pushToken withDelegate:(id<ServerConnectionManagerDelegate>)delegate;
- (void)fetchCSVForDriverId:(NSString *)driverId andDate:(NSDate *)date withDelegate:(id<ServerConnectionManagerDelegate>)delegate;
- (void)uploadBase64File:(NSString *)base64File withFilename:(NSString *)filename withDelegate:(id<ServerConnectionManagerDelegate>)delegate;

@end
