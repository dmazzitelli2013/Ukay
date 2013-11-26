//
//  FormUploaderManager.m
//  Ukay
//
//  Created by David Mazzitelli on 11/25/13.
//  Copyright (c) 2013 David Mazzitelli. All rights reserved.
//

#import "FormUploaderManager.h"
#import "NSData+Base64.h"

#define TIMER_INTERVAL  60 // 1 minute

@interface FormUploaderManager ()

@property (nonatomic, strong) NSMutableArray *filesToUpload;
@property (nonatomic, strong) ServerConnectionManager *connectionManager;

@end

@implementation FormUploaderManager

static BOOL _ran = NO;
static NSTimer *_timer = nil;
static FormUploaderManager *_uploader = nil;

+ (void)start
{
    if(_timer) {
        [_timer invalidate];
        [_timer release];
        _timer = nil;
    }
    
    _timer = [[NSTimer scheduledTimerWithTimeInterval:TIMER_INTERVAL target:self selector:@selector(run) userInfo:nil repeats:YES] retain];
    [_timer fire];
}

+ (void)run
{
    if(_ran) {
        return;
    }
    
    _ran = YES;
    
    if(_uploader) {
        [_uploader release];
        _uploader = nil;
    }
    
    _uploader = [[FormUploaderManager alloc] init];
    [_uploader uploadFiles];
}

- (void)dealloc
{
    [_filesToUpload release];
    _filesToUpload = nil;
    
    if(_connectionManager) {
        [_connectionManager release];
        _connectionManager = nil;
    }
    
    [super dealloc];
}

- (void)uploadFiles
{
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSArray *items = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:nil];
    
    self.filesToUpload = [NSMutableArray array];
    for(NSString *item in items) {
        if([[item pathExtension] isEqualToString:@"zip"]) {
            NSString *path = [documentsDirectory stringByAppendingPathComponent:item];
            [self.filesToUpload addObject:path];
        }
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    self.connectionManager = [[[ServerConnectionManager alloc] init] autorelease];
    
    [self startUploadingFiles];
}

- (void)startUploadingFiles
{
    if([self.filesToUpload count] == 0) {
        _ran = NO;
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        return;
    }
    
    NSString *filePath = [self.filesToUpload objectAtIndex:0];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSString *fileContents = [data base64EncodingWithLineLength:0];
    
    [self.connectionManager uploadBase64File:fileContents withFilename:[filePath lastPathComponent] withDelegate:self];
    [self.filesToUpload removeObject:filePath];
}

#pragma mark - ServerConnectionManagerDelegate methods

- (void)serverRespondsWithErrorCode:(NSInteger)code
{
    [self performSelector:@selector(startUploadingFiles) withObject:nil afterDelay:0.1f];
}

- (void)serverRespondsWithData:(NSDictionary *)data
{
    if([[data objectForKey:@"success"] boolValue]) {
        NSString *filename = [data objectForKey:@"file"];
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *path = [documentsDirectory stringByAppendingPathComponent:filename];
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        
        NSArray *components = [[[filename componentsSeparatedByString:@"."] objectAtIndex:0] componentsSeparatedByString:@"_"];
        NSString *reference = @"unknown";
        if([components count] > 1) {
            reference = [components objectAtIndex:1];
        }
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Success!"
                                                            message:[NSString stringWithFormat:@"The form with reference %@ was sent successfully", reference]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        [alertView release];
    }
    
    [self performSelector:@selector(startUploadingFiles) withObject:nil afterDelay:0.1f];
}

@end
