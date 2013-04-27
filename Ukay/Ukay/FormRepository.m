//
//  FormRepository.m
//  Ukay
//
//  Created by David Mazzitelli on 4/27/13.
//  Copyright (c) 2013 David Mazzitelli. All rights reserved.
//

#import "FormRepository.h"
#import "CHCSVParser.h"
#import "Form.h"
#import "Item.h"

@implementation FormRepository

- (NSArray *)getAllForms
{
    // TODO: change file for webservice
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"example" ofType:@"csv"];
    NSString *CSVString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];

    NSArray *components = [CSVString CSVComponents];
    NSMutableDictionary *componentsByReferenceNumber = [NSMutableDictionary dictionary];
    
    for(NSArray *formComponents in components) {
        formComponents = [self clearComponents:formComponents];
        
        NSString *referenceNumber = [formComponents objectAtIndex:5];
        Form *form = [componentsByReferenceNumber objectForKey:referenceNumber];
        
        if(!form) {
            form = [self createFormWithFormComponents:formComponents];
            [componentsByReferenceNumber setObject:form forKey:referenceNumber];
        }
        
        [self addItemToForm:form withFormComponents:formComponents];
    }    
    
    return [self sortFormsByReferenceNumber:componentsByReferenceNumber];
}

- (NSArray *)sortFormsByReferenceNumber:(NSDictionary *)components
{
    NSMutableArray *forms = [NSMutableArray array];
    NSArray *sortedKeys = [[components allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    for(NSString *key in sortedKeys) {
        [forms addObject:[components objectForKey:key]];
    }
    
    return forms;
}

- (NSArray *)clearComponents:(NSArray *)formComponents
{
    NSMutableArray *cleanComponents = [NSMutableArray array];
    
    for(NSString *component in formComponents) {
        [cleanComponents addObject:[component stringByReplacingOccurrencesOfString:@"\"" withString:@""]];
    }
    
    return cleanComponents;
}

- (Form *)createFormWithFormComponents:(NSArray *)formComponents
{
    Form *form = [[[Form alloc] init] autorelease];
    
    form.billTo = [formComponents objectAtIndex:8];
    form.payment = [formComponents objectAtIndex:14];
    form.invoice = [formComponents objectAtIndex:4];
    form.reference = [formComponents objectAtIndex:5];
    form.type = [formComponents objectAtIndex:9];
    form.consignee = [formComponents objectAtIndex:6];
    form.shipper = [formComponents objectAtIndex:7];
    form.date = [formComponents objectAtIndex:3];
    form.customer = [formComponents objectAtIndex:15];
    form.value = [formComponents objectAtIndex:16];
    
    return form;
}

- (void)addItemToForm:(Form *)form withFormComponents:(NSArray *)formComponents
{
    Item *item = [[Item alloc] init];
    
    item.quantity = [formComponents objectAtIndex:10];
    item.description = [formComponents objectAtIndex:11];
    item.cube = [formComponents objectAtIndex:12];
    item.charges = [formComponents objectAtIndex:13];
    
    [form addItem:item];
    
    [item release];
}

@end
