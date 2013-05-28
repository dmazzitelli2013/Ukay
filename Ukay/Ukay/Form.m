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
    [_title release];
    [_driver release];
    [_helper release];
    [_routeName release];
    [_billToAddress release];
    [_billToCity release];
    [_billToState release];
    [_billToZipCode release];
    [_billToPhone release];
    [_invoice release];
    [_reference release];
    [_type release];
    [_payment release];
    [_consigneeAddress release];
    [_consigneeCity release];
    [_consigneeState release];
    [_consigneeZipCode release];
    [_consigneePhone release];
    [_shipperAddress release];
    [_shipperCity release];
    [_shipperState release];
    [_shipperZipCode release];
    [_shipperPhone release];
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
