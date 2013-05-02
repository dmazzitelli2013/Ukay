//
//  FormRepository.h
//  Ukay
//
//  Created by David Mazzitelli on 4/27/13.
//  Copyright (c) 2013 David Mazzitelli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FormRepository : NSObject

- (NSArray *)getAllForms;
- (NSArray *)getAllFormGroupsForForms:(NSArray *)forms;

@end