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
#import "FormGroup.h"

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
    
    form.title = [formComponents objectAtIndex:0];
    form.driver = [formComponents objectAtIndex:1];
    form.helper = [formComponents objectAtIndex:2];
    form.routeName = [formComponents objectAtIndex:3];
    form.billTo = [formComponents objectAtIndex:9];
    form.payment = [formComponents objectAtIndex:15];
    form.invoice = [formComponents objectAtIndex:5];
    form.reference = [formComponents objectAtIndex:6];
    form.type = [formComponents objectAtIndex:10];
    form.consignee = [formComponents objectAtIndex:7];
    form.shipper = [formComponents objectAtIndex:8];
    form.date = [formComponents objectAtIndex:4];
    form.customer = [formComponents objectAtIndex:16];
    form.value = [formComponents objectAtIndex:17];
    
    return form;
}

- (void)addItemToForm:(Form *)form withFormComponents:(NSArray *)formComponents
{
    Item *item = [[Item alloc] init];
    
    item.quantity = [formComponents objectAtIndex:11];
    item.description = [formComponents objectAtIndex:12];
    item.cube = [formComponents objectAtIndex:13];
    item.charges = [formComponents objectAtIndex:14];
    
    [form addItem:item];
    
    [item release];
}

- (NSArray *)getAllFormGroupsForForms:(NSArray *)forms
{
    NSMutableArray *formGroups = [NSMutableArray array];
    NSInteger formNumber = 1;
    
    for(Form *form in forms) {
        
        form.formNumber = formNumber;
        formNumber++;
        
        if([formGroups count] == 0) {
            
            FormGroup *formGroup = [self createFormGroup:form];
            [formGroup addForm:form];
            [formGroups addObject:formGroup];
            
        } else {
            
            BOOL belongs = NO;
            int i = 0;
            while(i < [formGroups count] && !belongs) {
                FormGroup *formGroup = [formGroups objectAtIndex:i];
                if([formGroup belongsToTheGroup:form]) {
                    [formGroup addForm:form];
                    belongs = YES;
                }
                
                i++;
            }
            
            if(!belongs) {
                FormGroup *formGroup = [self createFormGroup:form];
                [formGroup addForm:form];
                [formGroups addObject:formGroup];
            }
            
        }
        
    }
    
    return formGroups;
}

- (NSArray *)getAllFormGroupsForToday
{
    NSArray *forms = [self getAllForms];
    NSArray *formGroups = [self getAllFormGroupsForForms:forms];
    
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM-dd-yy"];
    NSString *stringFromTodaysDate = [formatter stringFromDate:date];
    [formatter release];
    
    int i = 0, j = 0;
    NSMutableArray *todaysGroups = [NSMutableArray array];
    for(FormGroup *group in formGroups) {
        if([group.date isEqualToString:stringFromTodaysDate]) {
            for(j = i; j < ([group getFormsCount] + i); j++) {
                Form *form = [group getFormAtIndex:j];
                form.formNumber = (j + 1);
            }
            i += [group getFormsCount];
            [todaysGroups addObject:group];
        }
    }
    
    return todaysGroups;
}

- (FormGroup *)createFormGroup:(Form *)form
{
    return [[[FormGroup alloc] initWithForm:form] autorelease];
}

@end
