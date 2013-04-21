//
//  Form.m
//  Ukay
//
//  Created by David Mazzitelli on 4/21/13.
//  Copyright (c) 2013 David Mazzitelli. All rights reserved.
//

#import "Form.h"

@implementation Form

- (void)dealloc
{
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
    
    [super dealloc];
}

@end
