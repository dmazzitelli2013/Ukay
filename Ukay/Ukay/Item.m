//
//  Item.m
//  Ukay
//
//  Created by David Mazzitelli on 4/21/13.
//  Copyright (c) 2013 David Mazzitelli. All rights reserved.
//

#import "Item.h"

@implementation Item

- (void)dealloc
{
    [_quantity release];
    [_description release];
    [_cube release];
    [_charges release];
    
    [super dealloc];
}

@end
