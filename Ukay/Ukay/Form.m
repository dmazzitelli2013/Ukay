//
//  Form.m
//  Ukay
//
//  Created by David Mazzitelli on 4/21/13.
//  Copyright (c) 2013 David Mazzitelli. All rights reserved.
//

#import "Form.h"

@implementation Form

- (id)init
{
    self = [super init];
    
    if(self) {
        self.attachedPhotoNames = [NSMutableArray array];
    }
    
    return self;
}

- (void)dealloc
{
    [_driver release];
    [_helper release];
    [_routeName release];
    [_billTo release];
    [_invoice release];
    [_reference release];
    [_type release];
    [_payment release];
    [_consignee release];
    [_shipper release];
    [_date release];
    [_customer release];
    [_value release];
    [_items release];
    
    [_attachedPhotoNames release];
    
    [super dealloc];
}

- (void)addItem:(Item *)item
{
    if(!self.items) {
        self.items = [NSMutableArray array];
    }
    
    [self.items addObject:item];
}

- (void)removeItem:(Item *)item
{
    [self.items removeObject:item];
}

@end
