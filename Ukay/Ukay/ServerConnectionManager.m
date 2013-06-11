//
//  ServerConnectionManager.m
//  Ukay
//
//  Created by David Mazzitelli on 6/10/13.
//  Copyright (c) 2013 David Mazzitelli. All rights reserved.
//

#import "ServerConnectionManager.h"
#import <CommonCrypto/CommonDigest.h>
#import "JSONKit.h"

#define BASE_URL        @"http://54.215.10.61"
#define WEBSERVICE_URL  @"/index.php"

#define LOGIN_URL       @"/driverlogin/data/user/%@/pass/%@"    //user/[username]/pass/[MD5 password]

@interface ServerConnectionManager () {
    NSMutableData *_data;
}

@property (nonatomic, assign) id<ServerConnectionManagerDelegate> delegate;

@end

@implementation ServerConnectionManager

- (void)dealloc
{
    if(_data) {
        [_data release];
    }
    
    [super dealloc];
}

- (NSString *)md5:(NSString *)input
{
    const char *cStr = [input UTF8String];
    unsigned char digest[16];
    CC_MD5( cStr, strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
}

- (void)loginWithUsername:(NSString *)username andPassword:(NSString *)password withDelegate:(id<ServerConnectionManagerDelegate>)delegate
{
    self.delegate = delegate;
    
    NSString *webserviceUrlStr = [NSString stringWithFormat:@"%@%@", BASE_URL, WEBSERVICE_URL];
    NSString *loginUrlStr = [NSString stringWithFormat:LOGIN_URL, username, [self md5:password]];
    NSString *actualUrlStr = [NSString stringWithFormat:@"%@%@", webserviceUrlStr, loginUrlStr];
    NSURL *loginUrl = [NSURL URLWithString:actualUrlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:loginUrl cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:10];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    
    [connection start];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    int code = [httpResponse statusCode];
    
    if(code != 200 && self.delegate) {
        [self.delegate serverRespondsWithErrorCode:code];
        [connection cancel];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if(!_data) {
        _data = [[NSMutableData alloc] init];
    }
    
    [_data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *dataString = [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding];
    NSDictionary *dictionary = [dataString objectFromJSONString];
    
    if(self.delegate) {
        [self.delegate serverRespondsWithData:dictionary];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    int code = [error code];
    
    if(self.delegate) {
        [self.delegate serverRespondsWithErrorCode:code];
    }
}

@end
