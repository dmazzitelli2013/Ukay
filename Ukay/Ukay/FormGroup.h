//
//  FormGroup.h
//  Ukay
//
//  Created by David Mazzitelli on 4/28/13.
//  Copyright (c) 2013 David Mazzitelli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Form.h"

@interface FormGroup : NSObject

@property (nonatomic, retain) NSString *driver;
@property (nonatomic, retain) NSString *helper;
@property (nonatomic, retain) NSString *routeName;
@property (nonatomic, retain) NSString *date;

- (id)initWithForm:(Form *)form;
- (BOOL)belongsToTheGroup:(Form *)form;
- (void)addForm:(Form *)form;
- (void)removeForm:(Form *)form;
- (Form *)getFormAtIndex:(NSInteger)index;
- (NSInteger)getFormsCount;

@end
