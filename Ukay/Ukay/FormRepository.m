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

@interface FormRepository () {
    ServerConnectionManager *_serverConnectionManager;
    NSString *_csv;
    id _target;
    SEL _selector;
}

@end

@implementation FormRepository

NSString *_driverId = nil;

+ (void)setDriverId:(NSString *)driverId
{
    if(_driverId) {
        [_driverId release];
    }
    
    _driverId = [driverId retain];
}

- (void)dealloc
{
    if(_serverConnectionManager) {
        [_serverConnectionManager release];
    }
    
    if(_csv) {
        [_csv release];
    }
    
    [super dealloc];
}

- (void)fetchCSVFromServerWithCallback:(id)target selector:(SEL)selector
{
    if(_serverConnectionManager) {
        [_serverConnectionManager release];
    }
    
    _target = target;
    _selector = selector;
    
    _serverConnectionManager = [[ServerConnectionManager alloc] init];
    [_serverConnectionManager fetchCSVForDriverId:_driverId andDate:[NSDate date] withDelegate:self];
}

- (void)serverRespondsWithData:(NSDictionary *)data
{
    _csv = [[data objectForKey:@"csv"] retain];
    
    if(_target && _selector) {
        [_target performSelector:_selector withObject:nil];
    }
}

- (void)serverRespondsWithErrorCode:(NSInteger)code
{
    _csv = nil;
    
    if(_target && _selector) {
        [_target performSelector:_selector withObject:nil];
    }
}

- (NSArray *)getAllForms
{
    if(!_csv) {
        return nil;
    }
    
    NSArray *components = [_csv CSVComponents];
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
    form.billToName = [formComponents objectAtIndex:19];
    form.billToAddress = [formComponents objectAtIndex:20];
    form.billToCity = [formComponents objectAtIndex:21];
    form.billToState = [formComponents objectAtIndex:22];
    form.billToZipCode = [formComponents objectAtIndex:23];
    form.billToPhone = [formComponents objectAtIndex:24];
    form.payment = [formComponents objectAtIndex:30];
    form.invoice = [formComponents objectAtIndex:5];
    form.reference = [formComponents objectAtIndex:6];
    form.type = [formComponents objectAtIndex:25];
    form.consigneeName = [formComponents objectAtIndex:7];
    form.consigneeAddress = [formComponents objectAtIndex:8];
    form.consigneeCity = [formComponents objectAtIndex:9];
    form.consigneeState = [formComponents objectAtIndex:10];
    form.consigneeZipCode = [formComponents objectAtIndex:11];
    form.consigneePhone = [formComponents objectAtIndex:12];
    form.shipperName = [formComponents objectAtIndex:13];
    form.shipperAddress = [formComponents objectAtIndex:14];
    form.shipperCity = [formComponents objectAtIndex:15];
    form.shipperState = [formComponents objectAtIndex:16];
    form.shipperZipCode = [formComponents objectAtIndex:17];
    form.shipperPhone = [formComponents objectAtIndex:18];
    form.date = [formComponents objectAtIndex:4];
    form.customer = [formComponents objectAtIndex:31];
    form.value = [formComponents objectAtIndex:32];
    
    return form;
}

- (void)addItemToForm:(Form *)form withFormComponents:(NSArray *)formComponents
{
    Item *item = [[Item alloc] init];
    
    item.quantity = [formComponents objectAtIndex:26];
    item.description = [formComponents objectAtIndex:27];
    item.cube = [formComponents objectAtIndex:28];
    item.charges = [formComponents objectAtIndex:29];
    
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
