//
//  Form.h
//  Ukay
//
//  Created by David Mazzitelli on 4/21/13.
//  Copyright (c) 2013 David Mazzitelli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Item.h"

typedef enum {
    New,
    Completed
} FormState;

@interface Form : NSObject

@property (nonatomic, assign) FormState formState;

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *driver;
@property (nonatomic, retain) NSString *helper;
@property (nonatomic, retain) NSString *routeName;

@property (nonatomic, retain) NSString *billToName;
@property (nonatomic, retain) NSString *billToAddress;
@property (nonatomic, retain) NSString *billToCity;
@property (nonatomic, retain) NSString *billToState;
@property (nonatomic, retain) NSString *billToZipCode;
@property (nonatomic, retain) NSString *billToPhone;
@property (nonatomic, retain) NSString *invoice;
@property (nonatomic, retain) NSString *reference;
@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSString *payment;

@property (nonatomic, retain) NSString *consigneeName;
@property (nonatomic, retain) NSString *consigneeAddress;
@property (nonatomic, retain) NSString *consigneeCity;
@property (nonatomic, retain) NSString *consigneeState;
@property (nonatomic, retain) NSString *consigneeZipCode;
@property (nonatomic, retain) NSString *consigneePhone;
@property (nonatomic, retain) NSString *shipperName;
@property (nonatomic, retain) NSString *shipperAddress;
@property (nonatomic, retain) NSString *shipperCity;
@property (nonatomic, retain) NSString *shipperState;
@property (nonatomic, retain) NSString *shipperZipCode;
@property (nonatomic, retain) NSString *shipperPhone;
@property (nonatomic, retain) NSString *date;
@property (nonatomic, retain) NSString *customer;
@property (nonatomic, retain) NSString *value;

@property (nonatomic, retain) NSMutableArray *items;

@property (nonatomic, assign) NSInteger formNumber;

@property (nonatomic, retain) NSMutableArray *attachedPhotoNames;

- (void)addItem:(Item *)item;
- (void)removeItem:(Item *)item;

@end
