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
#import "DatePickerViewController.h"

#define DATEPICKER_FRAME    CGSizeMake(343, 216)

@interface FormViewController () {
    NSMutableDictionary *_textBoxesOffsets;
    UITextField *_lastTouchedTextField;
    UITextField *_lastTouchedDateField;
    NSMutableDictionary *_checkButtonImages;
    BOOL _keyboardShowing;
}

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
@property (nonatomic, retain) IBOutlet UITextView *additionalNotesTextView;
@property (nonatomic, retain) IBOutlet UITextField *printName;
@property (nonatomic, retain) IBOutlet UITextField *dateOne;
@property (nonatomic, retain) IBOutlet UITextField *dateTwo;
@property (nonatomic, retain) IBOutlet UIButton *checkButtonOne;
@property (nonatomic, retain) IBOutlet UIButton *checkButtonTwo;
@property (nonatomic, retain) IBOutlet UIButton *checkButtonThree;
@property (nonatomic, retain) IBOutlet UIButton *checkButtonFour;
@property (nonatomic, retain) IBOutlet UIButton *checkButtonFive;
@property (nonatomic, retain) IBOutlet UIButton *checkButtonSix;

@property (nonatomic, retain) UIPopoverController *popover;

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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
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
    [_additionalNotesTextView release];
    [_printName release];
    [_dateOne release];
    [_dateTwo release];
    [_checkButtonOne release];
    [_checkButtonTwo release];
    [_checkButtonThree release];
    [_checkButtonFour release];
    [_checkButtonFive release];
    [_checkButtonSix release];
    
    [_textBoxesOffsets release];
    [_checkButtonImages release];
    
    if(_popover) {
        [_popover release];
    }
    
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
    
    [self.additionalNotesTextView setDelegate:self];
    [self.printName setDelegate:self];
    [self.dateOne setDelegate:self];
    [self.dateTwo setDelegate:self];
    
    _textBoxesOffsets = [[NSMutableDictionary alloc] init];
    [_textBoxesOffsets setObject:[NSNumber numberWithInteger:280] forKey:[self.additionalNotesTextView description]];
    [_textBoxesOffsets setObject:[NSNumber numberWithInteger:310] forKey:[self.printName description]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    
    _keyboardShowing = NO;
    
    _checkButtonImages = [[NSMutableDictionary alloc] init];
    [_checkButtonImages setObject:[UIImage imageNamed:@"check-icon.png"] forKey:@"check"];
    [_checkButtonImages setObject:[UIImage imageNamed:@"unckeck-icon.png"] forKey:@"uncheck"];
    
    [self.checkButtonOne    setImage:[_checkButtonImages objectForKey:@"uncheck"] forState:UIControlStateNormal];
    [self.checkButtonTwo    setImage:[_checkButtonImages objectForKey:@"uncheck"] forState:UIControlStateNormal];
    [self.checkButtonThree  setImage:[_checkButtonImages objectForKey:@"uncheck"] forState:UIControlStateNormal];
    [self.checkButtonFour   setImage:[_checkButtonImages objectForKey:@"uncheck"] forState:UIControlStateNormal];
    [self.checkButtonFive   setImage:[_checkButtonImages objectForKey:@"uncheck"] forState:UIControlStateNormal];
    [self.checkButtonSix    setImage:[_checkButtonImages objectForKey:@"uncheck"] forState:UIControlStateNormal];
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
    self.additionalNotesTextView = nil;
    self.printName = nil;
    self.dateOne = nil;
    self.dateTwo = nil;
    self.checkButtonOne = nil;
    self.checkButtonTwo = nil;
    self.checkButtonThree = nil;
    self.checkButtonFour = nil;
    self.checkButtonFive = nil;
    self.checkButtonSix = nil;
    self.popover = nil;
    
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)adjustViewPositionForSelectedObject:(NSObject *)object
{
    NSNumber *offset = [_textBoxesOffsets objectForKey:[object description]];
    
    if(!offset) {
        return NO;
    }
    
    UIInterfaceOrientation currentOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    CGRect frame = self.view.frame;
    
    if(currentOrientation == UIInterfaceOrientationLandscapeRight) {
        frame.origin.x += [offset integerValue];
    } else {
        frame.origin.x -= [offset integerValue];
    }
    
    [UIView beginAnimations:nil context:nil];
    
    [self.view setFrame:frame];
    
    [UIView commitAnimations];
    
    return YES;
}

- (void)restoreViewPosition
{
    UIInterfaceOrientation currentOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    CGRect frame = self.view.frame;
    
    if(currentOrientation == UIInterfaceOrientationLandscapeRight) {
        frame.origin.x = 0;
    } else {
        frame.origin.x = 20;
    }
    
    [UIView beginAnimations:nil context:nil];
    
    [self.view setFrame:frame];
    
    [UIView commitAnimations];
}

#pragma mark - IBActions methods

- (IBAction)back:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)checkButtonPressed:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    if([button imageForState:UIControlStateNormal] == [_checkButtonImages objectForKey:@"check"]) {
        [button setImage:[_checkButtonImages objectForKey:@"uncheck"] forState:UIControlStateNormal];
    } else {
        [button setImage:[_checkButtonImages objectForKey:@"check"] forState:UIControlStateNormal];
    }
}

#pragma mark - UITextViewDelegate methods

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [self adjustViewPositionForSelectedObject:textView];
    
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    [self restoreViewPosition];
    
    return YES;
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if([self adjustViewPositionForSelectedObject:textField]) {
        _lastTouchedTextField = textField;
        return YES;
    }
    
    if(_keyboardShowing) {
        [_lastTouchedTextField resignFirstResponder];
        return NO;
    }
    
    DatePickerViewController *datePickerViewController = [[DatePickerViewController alloc] initWithNibName:@"DatePickerViewController" bundle:nil];
    self.popover = [[[UIPopoverController alloc] initWithContentViewController:datePickerViewController] autorelease];
    [self.popover setDelegate:self];
    [datePickerViewController release];
    
    CGSize datePickerSize = DATEPICKER_FRAME;
    CGRect frame = textField.frame;
    [self.popover setPopoverContentSize:datePickerSize];
    [self.popover presentPopoverFromRect:CGRectMake(frame.origin.x - datePickerSize.width / 2, frame.origin.y, datePickerSize.width, datePickerSize.height) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
    
    _lastTouchedDateField = textField;
    
    return NO;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [self restoreViewPosition];
    
    return YES;
}

#pragma mark - Keyboard Events methods

- (void)keyboardDidShow:(NSNotification *)notification
{
    _keyboardShowing = YES;
}

- (void)keyboardDidHide:(NSNotification *)notification
{
    _keyboardShowing = NO;
}

#pragma mark - UIPopoverControllerDelegate methods

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
{
    DatePickerViewController *datePickerViewController = (DatePickerViewController *)[popoverController contentViewController];
    NSString *date = [datePickerViewController getSelectedDate];
    [_lastTouchedDateField setText:date];
    
    return YES;
}

@end
