//
//  FormViewController.m
//  Ukay
//
//  Created by David Mazzitelli on 4/21/13.
//  Copyright (c) 2013 David Mazzitelli. All rights reserved.
//

#import "FormViewController.h"
#import "Form.h"
#import "Item.h"

@interface FormViewController ()

@property (nonatomic, retain) IBOutlet UITextView *billToTextView;
@property (nonatomic, retain) IBOutlet UITextView *consigneeTextView;
@property (nonatomic, retain) IBOutlet UITextView *shipperTextView;
@property (nonatomic, retain) IBOutlet UILabel *invLabel;
@property (nonatomic, retain) IBOutlet UILabel *refLabel;
@property (nonatomic, retain) IBOutlet UILabel *typeLabel;
@property (nonatomic, retain) IBOutlet UILabel *paymentLabel;
@property (nonatomic, retain) IBOutlet UILabel *dateLabel;
@property (nonatomic, retain) IBOutlet UILabel *customerLabel;
@property (nonatomic, retain) IBOutlet UILabel *valueLabel;
@property (nonatomic, retain) IBOutlet UITextView *quantityTextView;
@property (nonatomic, retain) IBOutlet UITextView *descriptionTextView;
@property (nonatomic, retain) IBOutlet UITextView *cubeTextView;
@property (nonatomic, retain) IBOutlet UITextView *chargesTextView;

@end

@implementation FormViewController

- (Form *)createFakeForm
{
    Form *form = [[[Form alloc] init] autorelease];
    
    form.billTo = @"DIVA FURNITURE 8801 BEVERLY BLVD LOS ANGELES, CA 90048";
    
    form.payment = @"BILL";
    form.invoice = @"324174";
    form.reference = @"SMPRH0062231";
    form.type = @"DELIVERY";
    
    form.consignee = @"DIVA FURNITURE 8801 BEVERLY BLVD LOS ANGELES, CA 90048 (310) 278-3191 (310) 278-3292";
    form.shipper = @"DIVA NEW WAREHOUSE 13625 GRAMERY PL EL SEGUNDO, CA 90245";
    
    form.date = @"02-19-13";
    form.customer = @"";
    form.value = @"";
    
    Item *item1 = [[Item alloc] init];
    item1.quantity = @"1";
    item1.description = @"POSTED BED";
    item1.cube = @"10.34";
    item1.charges = @"";
    
    Item *item2 = [[Item alloc] init];
    item2.quantity = @"2";
    item2.description = @"PRODUCT A";
    item2.cube = @"25.55";
    item2.charges = @"39.99";
    
    Item *item3 = [[Item alloc] init];
    item3.quantity = @"1";
    item3.description = @"PRODUCT B";
    item3.cube = @"100.00";
    item3.charges = @"50.00";
    
    form.items = [NSArray arrayWithObjects:item1, item2, item3, nil];
    
    [item1 release];
    [item2 release];
    [item3 release];
    
    return form;
}

- (void)dealloc
{
    [_billToTextView release];
    [_invLabel release];
    [_refLabel release];
    [_typeLabel release];
    [_paymentLabel release];
    [_consigneeTextView release];
    [_shipperTextView release];
    [_dateLabel release];
    [_customerLabel release];
    [_valueLabel release];
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    Form *form = [self createFakeForm];
    
    self.billToTextView.text = form.billTo;
    self.invLabel.text = form.invoice;
    self.refLabel.text = form.reference;
    self.typeLabel.text = form.type;
    self.paymentLabel.text = form.payment;
    self.consigneeTextView.text = form.consignee;
    self.shipperTextView.text = form.shipper;
    self.dateLabel.text = form.date;
    self.customerLabel.text = form.customer;
    self.valueLabel.text = form.value;
    
    NSMutableString *quantities = [NSMutableString string];
    NSMutableString *descriptions = [NSMutableString string];
    NSMutableString *cubes = [NSMutableString string];
    NSMutableString *charges = [NSMutableString string];
    
    for(Item *item in form.items) {
        [quantities appendFormat:@"%@\n", item.quantity];
        [descriptions appendFormat:@"%@\n", item.description];
        [cubes appendFormat:@"%@\n", item.cube];
        [charges appendFormat:@"%@\n", item.charges];
    }
    
    self.quantityTextView.text = quantities;
    self.descriptionTextView.text = descriptions;
    self.cubeTextView.text = cubes;
    self.chargesTextView.text = charges;
}

- (void)viewDidUnload
{
    self.billToTextView = nil;
    self.invLabel = nil;
    self.refLabel = nil;
    self.typeLabel = nil;
    self.paymentLabel = nil;
    self.consigneeTextView = nil;
    self.shipperTextView = nil;
    self.dateLabel = nil;
    self.customerLabel = nil;
    self.valueLabel = nil;
    
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions methods

- (IBAction)back:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
