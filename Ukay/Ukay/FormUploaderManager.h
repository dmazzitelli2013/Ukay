//
//  FormUploaderManager.h
//  Ukay
//
//  Created by David Mazzitelli on 11/25/13.
//  Copyright (c) 2013 David Mazzitelli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServerConnectionManager.h"

@interface FormUploaderManager : NSObject <ServerConnectionManagerDelegate>

+ (void)start;
+ (void)run;

@end
