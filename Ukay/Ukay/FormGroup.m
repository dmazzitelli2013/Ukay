//
//  FormGroup.m
//  Ukay
//
//  Created by David Mazzitelli on 4/28/13.
//  Copyright (c) 2013 David Mazzitelli. All rights reserved.
//

#import "FormGroup.h"

@interface FormGroup ()

@property (nonatomic, retain) NSMutableArray *forms;

@end

@implementation FormGroup

- (id)initWithForm:(Form *)form
{
    self = [super init];
    
    if(self) {
        self.driver = form.driver;
        self.helper = form.helper;
        self.routeName = form.routeName;
        self.date = form.date;
    }
    
    return self;
}

- (void)dealloc
{
    [_driver release];
    [_helper release];
    [_routeName release];
    [_date release];
    
    if(_forms) {
        [_forms release];
    }
    
    [super dealloc];
}

- (BOOL)belongsToTheGroup:(Form *)form
{
    return ([form.date isEqualToString:self.date] &&
            [form.routeName isEqualToString:self.routeName] &&
            [form.helper isEqualToString:self.helper] &&
            [form.driver isEqualToString:self.driver]);
}

- (void)addForm:(Form *)form
{
    if(!self.forms) {
        self.forms = [NSMutableArray array];
    }
    
    [self.forms addObject:form];
}

- (void)removeForm:(Form *)form
{
    [self.forms removeObject:form];
}

- (Form *)getFormAtIndex:(NSInteger)index
{
    if(index >= [self.forms count]) {
        return nil;
    }
    
    return [self.forms objectAtIndex:index];
}

- (NSInteger)getFormsCount
{
    return [self.forms count];
}

@end
