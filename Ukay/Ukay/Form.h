//
//  Form.h
//  Ukay
//
//  Created by David Mazzitelli on 4/21/13.
//  Copyright (c) 2013 David Mazzitelli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Form : NSObject

@property (nonatomic, retain) NSString *billTo;
@property (nonatomic, retain) NSString *invoice;
@property (nonatomic, retain) NSString *reference;
@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSString *payment;

@property (nonatomic, retain) NSString *consignee;
@property (nonatomic, retain) NSString *shipper;
@property (nonatomic, retain) NSString *date;
@property (nonatomic, retain) NSString *customer;
@property (nonatomic, retain) NSString *value;

@property (nonatomic, retain) NSArray *items;

@end
