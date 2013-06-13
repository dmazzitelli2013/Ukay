//
//  FormRepository.h
//  Ukay
//
//  Created by David Mazzitelli on 4/27/13.
//  Copyright (c) 2013 David Mazzitelli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServerConnectionManager.h"

@interface FormRepository : NSObject <ServerConnectionManagerDelegate>

+ (void)setDriverId:(NSString *)driverId;
- (NSArray *)getAllForms;
- (NSArray *)getAllFormGroupsForForms:(NSArray *)forms;
- (NSArray *)getAllFormGroupsForToday;
- (void)fetchCSVFromServerWithCallback:(id)target selector:(SEL)selector;

@end
