//
//  FormViewController.m
//  Ukay
//
//  Created by David Mazzitelli on 4/21/13.
//  Copyright (c) 2013 David Mazzitelli. All rights reserved.
//

#import "FormViewController.h"
#import "DatePickerViewController.h"
#import "AttachedPhotosViewController.h"
#import "PDFGenerator.h"
#import "SignatureView.h"
#import "NICSignatureView.h"
#import "Form.h"
#import "Item.h"
#import "ImageUtils.h"
#include "TargetConditionals.h"

#define DATEPICKER_FRAME    CGSizeMake(343, 216)

@interface FormViewController () {
    NSMutableDictionary *_textBoxesOffsets;
    UITextField *_lastTouchedTextField;
    UITextField *_lastTouchedDateField;
    NSMutableDictionary *_checkButtonImages;
    NSMutableDictionary *_signatureViews;
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
@property (nonatomic, retain) UIPopoverController *imagePopover;
@property (nonatomic, retain) UIPopoverController *manageImagesPopover;

@property (nonatomic, retain) IBOutlet UIButton *optionsButton;

@end

@implementation FormViewController

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
    [_optionsButton release];
    [_signatureViews release];
    
    if(_form) {
        [_form release];
    }
    
    if(_popover) {
        [_popover release];
    }
    
    if(_imagePopover) {
        [_imagePopover release];
    }
    
    if(_manageImagesPopover) {
        [_manageImagesPopover release];
    }
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(!self.form) {
        return;
    }
    
    self.billToTextView.text = self.form.billTo;
    self.invLabel.text = self.form.invoice;
    self.refLabel.text = self.form.reference;
    self.typeLabel.text = self.form.type;
    self.paymentLabel.text = self.form.payment;
    self.consigneeTextView.text = self.form.consignee;
    self.shipperTextView.text = self.form.shipper;
    self.dateLabel.text = self.form.date;
    self.customerLabel.text = self.form.customer;
    self.valueLabel.text = self.form.value;
    
    NSMutableString *quantities = [NSMutableString string];
    NSMutableString *descriptions = [NSMutableString string];
    NSMutableString *cubes = [NSMutableString string];
    NSMutableString *charges = [NSMutableString string];
    
    for(Item *item in self.form.items) {
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
    
    _signatureViews = [[NSMutableDictionary alloc] init];
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
    self.optionsButton = nil;
    
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

- (void)formCompleted
{
    self.form.formState = Completed;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)sendGeneratedPDFFileByEmail
{
    NSData *pdfData = [PDFGenerator dataForPDFFileWithName:@"file.pdf"];
    
    MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
    [mailComposer setMessageBody:@"" isHTML:NO];
    [mailComposer setSubject:@"Email subject"];
    [mailComposer addAttachmentData:pdfData mimeType:@"text/x-pdf" fileName:@"file.pdf"];
    
    mailComposer.mailComposeDelegate = self;
    [self presentModalViewController:mailComposer animated:YES];
    [mailComposer release];
}

- (void)generatePDFFile
{    
    self.optionsButton.hidden = YES;
    [PDFGenerator createPDFfromUIView:self.view andImages:self.form.attachedPhotoNames saveToDocumentsWithFileName:@"file.pdf" showAlert:YES];
    self.optionsButton.hidden = NO;
    
    [self sendGeneratedPDFFileByEmail];
}

- (void)attachPhoto
{    
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.allowsEditing = YES;
    
#if TARGET_IPHONE_SIMULATOR
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
#else
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
#endif
    
    imagePickerController.delegate = self;
    
    UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:imagePickerController];
    [popover presentPopoverFromRect:CGRectMake(0, 0, 1, 1) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    self.imagePopover = popover;
    
    [popover release];
    [imagePickerController release];
}

- (void)manageAttachedPhotos
{
    AttachedPhotosViewController *attachedPhotosViewController = [[AttachedPhotosViewController alloc] initWithNibName:@"AttachedPhotosViewController" bundle:nil];
    attachedPhotosViewController.attachedPhotoNames = self.form.attachedPhotoNames;
    
    UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:attachedPhotosViewController];
    [popover setDelegate:self];
    [popover presentPopoverFromRect:CGRectMake(0, 0, 1, 320) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
    self.manageImagesPopover = popover;
    
    [popover release];
    [attachedPhotosViewController release];
}

#pragma mark - IBActions methods

- (IBAction)optionsButtonPressed:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Options"
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Complete Record", @"Generate PDF", @"Attach Photos", @"Manage Attached Photos", @"Back", nil];
    
    [actionSheet showInView:self.view];
    [actionSheet release];
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

- (IBAction)signatureButtonPressed:(id)sender
{
    SignatureView *signatureView = [_signatureViews objectForKey:[sender description]];

    if(!signatureView) {
        signatureView = [[[NSBundle mainBundle] loadNibNamed:@"SignatureView" owner:self options:nil] objectAtIndex:0];
        signatureView.signatureTargetView = sender;
        [_signatureViews setObject:signatureView forKey:[sender description]];
    }

    [signatureView addSlowInView:self.view];
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
    if(self.popover == popoverController) {

        DatePickerViewController *datePickerViewController = (DatePickerViewController *)[popoverController contentViewController];
        NSString *date = [datePickerViewController getSelectedDate];
        [_lastTouchedDateField setText:date];
        
    } else if(self.manageImagesPopover == popoverController) {
        
        AttachedPhotosViewController *attachedPhotosViewController = (AttachedPhotosViewController *)[popoverController contentViewController];
        [attachedPhotosViewController removeFromParentViewController];
        
    }
    
    return YES;
}

#pragma mark - UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [self formCompleted];
            break;
            
        case 1:
            [self generatePDFFile];
            break;
        
        case 2:
            [self attachPhoto];
            break;
            
        case 3:
            [self manageAttachedPhotos];
            break;
            
        case 4:
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
            
        default:
            break;
    }
}

#pragma mark - UIImagePickerControllerDelegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self.imagePopover dismissPopoverAnimated:YES];
    self.imagePopover = nil;
    
    NSString *imageName = [NSString stringWithFormat:@"%@_%d", self.form.reference, [self.form.attachedPhotoNames count]];
    [self.form.attachedPhotoNames addObject:imageName];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    [ImageUtils saveImageInDocuments:image withName:imageName];
}

#pragma mark - MFMailComposeViewControllerDelegate methods

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissModalViewControllerAnimated:YES];
}

@end
