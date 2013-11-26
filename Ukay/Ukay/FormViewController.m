//
//  FormViewController.m
//  Ukay
//
//  Created by David Mazzitelli on 4/21/13.
//  Copyright (c) 2013 David Mazzitelli. All rights reserved.
//

#import "FormViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "DatePickerViewController.h"
#import "AttachedPhotosViewController.h"
#import "PDFGenerator.h"
#import "SignatureView.h"
#import "NICSignatureView.h"
#import "Form.h"
#import "Item.h"
#import "ImageUtils.h"
#import "JSONKit.h"
#import "MapViewController.h"
#import "MBProgressHUD.h"
#import "ZipArchive.h"
#import "FormRepository.h"
#import "FormUploaderManager.h"
#include "TargetConditionals.h"

#define DATEPICKER_FRAME    CGSizeMake(343, 216)
#define GOOGLE_GEOCODE_URL @"http://maps.googleapis.com/maps/api/geocode/json?address=%@&sensor=false"

@interface FormViewController () {
    NSMutableDictionary *_textBoxesOffsets;
    UITextField *_lastTouchedTextField;
    UITextField *_lastTouchedDateField;
    NSMutableDictionary *_checkButtonImages;
    NSMutableDictionary *_signatureViews;
    NSMutableDictionary *_itemsDischargedButtonImages;
    NSMutableArray *_itemsPickedUp;
    NSMutableArray *_itemsDischarged;
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
@property (nonatomic, retain) IBOutlet UIView *pickedupView;
@property (nonatomic, retain) IBOutlet UIView *dischargedView;
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
@property (nonatomic, retain) IBOutlet UILabel *formTitleLabel;

@property (nonatomic, retain) UIPopoverController *popover;
@property (nonatomic, retain) UIPopoverController *imagePopover;
@property (nonatomic, retain) UIPopoverController *manageImagesPopover;

@property (nonatomic, retain) IBOutlet UIButton *optionsButton;

@property (nonatomic, retain) NSString *mapAnnotationAddress;
@property (nonatomic, retain) NSString *mapAnnotationName;

@end

@implementation FormViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_billToTextView release];
    [_consigneeTextView release];
    [_shipperTextView release];
    [_invLabel release];
    [_refLabel release];
    [_typeLabel release];
    [_paymentLabel release];
    [_dateLabel release];
    [_customerLabel release];
    [_valueLabel release];
    [_quantityTextView release];
    [_descriptionTextView release];
    [_cubeTextView release];
    [_chargesTextView release];
    [_pickedupView release];
    [_dischargedView release];
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
    [_formTitleLabel release];
    
    [_textBoxesOffsets release];
    [_checkButtonImages release];
    [_optionsButton release];
    [_signatureViews release];
    [_itemsDischargedButtonImages release];
    [_itemsPickedUp release];
    [_itemsDischarged release];
    
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
    
    if(_mapAnnotationAddress) {
        [_mapAnnotationAddress release];
    }
    
    if(_mapAnnotationName) {
        [_mapAnnotationName release];
    }
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(!self.form) {
        return;
    }
    
    [self initializeFormBody];
    [self initializeDischargedAndPickedUpItems];
    [self initializeFormFooter];    
}

- (void)viewDidUnload
{
    self.billToTextView = nil;
    self.consigneeTextView = nil;
    self.shipperTextView = nil;
    self.invLabel = nil;
    self.refLabel = nil;
    self.typeLabel = nil;
    self.paymentLabel = nil;
    self.dateLabel = nil;
    self.customerLabel = nil;
    self.valueLabel = nil;
    self.quantityTextView = nil;
    self.descriptionTextView = nil;
    self.pickedupView = nil;
    self.dischargedView = nil;
    self.cubeTextView = nil;
    self.chargesTextView = nil;
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
    self.formTitleLabel = nil;
    self.popover = nil;
    self.imagePopover = nil;
    self.manageImagesPopover = nil;
    self.optionsButton = nil;
    
    [super viewDidUnload];
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

- (void)generatePDFFile
{    
    self.optionsButton.hidden = YES;
    
    [PDFGenerator createPDFfromUIView:self.view andImages:nil saveToDocumentsWithFileName:@"form.pdf" showAlert:NO];
    [ImageUtils saveFormImages:self.form.attachedPhotoNames];
    [self createZip];
    [ImageUtils deleteFormImages];
    [FormUploaderManager run];
    
    self.optionsButton.hidden = NO;
}

- (void)createZip
{
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *zipFileName = [NSString stringWithFormat:@"%@_%@.zip", [FormRepository getDriverId], self.form.reference];
    zipFileName = [documentsDirectory stringByAppendingPathComponent:zipFileName];
    
    ZipArchive *zip = [[ZipArchive alloc] init];
    [zip CreateZipFile2:zipFileName];
    
    NSArray *files = [ImageUtils getFormImagesPaths];
    for(NSString *path in files) {
        [zip addFileToZip:path newname:[path lastPathComponent]];
    }
    
    NSString *pdfPath = [documentsDirectory stringByAppendingPathComponent:@"form.pdf"];
    [zip addFileToZip:pdfPath newname:@"form.pdf"];
    
    BOOL success = [zip CloseZipFile2];
    NSLog(@"Zipped file with result %d", success);
}
     
- (void)attachPhoto
{    
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.allowsEditing = YES;
    
#if TARGET_IPHONE_SIMULATOR
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
#else
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePickerController.modalPresentationStyle = UIModalPresentationFullScreen;
    
    CGFloat scaleFactor = 1.0f;
    
    switch ([UIApplication sharedApplication].statusBarOrientation) {
        case UIInterfaceOrientationLandscapeLeft:
            imagePickerController.cameraViewTransform = CGAffineTransformScale(CGAffineTransformMakeRotation(M_PI * 90 / 180.0), scaleFactor, scaleFactor);
            break;
            
        case UIInterfaceOrientationLandscapeRight:
            imagePickerController.cameraViewTransform = CGAffineTransformScale(CGAffineTransformMakeRotation(M_PI * -90 / 180.0), scaleFactor, scaleFactor);
            break;
            
        case UIInterfaceOrientationPortraitUpsideDown:
            imagePickerController.cameraViewTransform = CGAffineTransformMakeRotation(M_PI * 180 / 180.0);
            break;
            
        default:
            break;
    }
#endif
    
    imagePickerController.delegate = self;
    
    UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:imagePickerController];
    [popover presentPopoverFromRect:CGRectMake(0, 0, 1, 1) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
#if !TARGET_IPHONE_SIMULATOR
    [popover setPopoverContentSize:CGSizeMake(720.0f, 710.0f)];
#endif

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

#pragma mark - Form Initialization methods

- (void)initializeFormBody
{
    self.formTitleLabel.text = self.form.title;
    self.billToTextView.text = [NSString stringWithFormat:@"%@,\n%@, %@, %@ %@,\n%@", self.form.billToName, self.form.billToAddress, self.form.billToCity, self.form.billToState, self.form.billToZipCode, self.form.billToPhone];
    self.invLabel.text = self.form.invoice;
    self.refLabel.text = self.form.reference;
    self.typeLabel.text = self.form.type;
    self.paymentLabel.text = self.form.payment;
    self.consigneeTextView.text = [NSString stringWithFormat:@"%@,\n%@, %@, %@ %@,\n%@", self.form.consigneeName, self.form.consigneeAddress, self.form.consigneeCity, self.form.consigneeState, self.form.consigneeZipCode, self.form.consigneePhone];
    self.shipperTextView.text = [NSString stringWithFormat:@"%@,\n%@, %@, %@ %@,\n%@", self.form.shipperName, self.form.shipperAddress, self.form.shipperCity, self.form.shipperState, self.form.shipperZipCode, self.form.shipperPhone];
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
}

- (void)initializeDischargedAndPickedUpItems
{
    _itemsDischargedButtonImages = [[NSMutableDictionary alloc] initWithCapacity:2];
    [_itemsDischargedButtonImages setObject:[UIImage imageNamed:@"box-checked.png"] forKey:@"checked"];
    [_itemsDischargedButtonImages setObject:[UIImage imageNamed:@"box-unchecked.png"] forKey:@"unchecked"];
    
    _itemsPickedUp = [[NSMutableArray alloc] init];
    _itemsDischarged = [[NSMutableArray alloc] init];
    CGRect buttonFrame = CGRectMake((self.dischargedView.frame.size.width / 2.0f) - 7, 6, 19, 19);
    
    for(int i = 0; i < [self.form.items count]; i++) {
        [_itemsPickedUp addObject:[NSNumber numberWithBool:YES]];
        [_itemsDischarged addObject:[NSNumber numberWithBool:YES]];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:buttonFrame];
        [button setImage:[_itemsDischargedButtonImages objectForKey:@"checked"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(pickedUpButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [button setTag:i];
        
        [self.pickedupView addSubview:button];
        
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:buttonFrame];
        [button setImage:[_itemsDischargedButtonImages objectForKey:@"checked"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(dischargedButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [button setTag:i];
        
        [self.dischargedView addSubview:button];
        
        buttonFrame.origin.y += 20;
    }
}

- (void)initializeFormFooter
{
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
    
    _checkButtonImages = [[NSMutableDictionary alloc] initWithCapacity:2];
    [_checkButtonImages setObject:[UIImage imageNamed:@"check-icon.png"] forKey:@"check"];
    [_checkButtonImages setObject:[UIImage imageNamed:@"uncheck-icon.png"] forKey:@"uncheck"];
    
    [self.checkButtonOne    setImage:[_checkButtonImages objectForKey:@"uncheck"] forState:UIControlStateNormal];
    [self.checkButtonTwo    setImage:[_checkButtonImages objectForKey:@"uncheck"] forState:UIControlStateNormal];
    [self.checkButtonThree  setImage:[_checkButtonImages objectForKey:@"uncheck"] forState:UIControlStateNormal];
    [self.checkButtonFour   setImage:[_checkButtonImages objectForKey:@"uncheck"] forState:UIControlStateNormal];
    [self.checkButtonFive   setImage:[_checkButtonImages objectForKey:@"uncheck"] forState:UIControlStateNormal];
    [self.checkButtonSix    setImage:[_checkButtonImages objectForKey:@"uncheck"] forState:UIControlStateNormal];
    
    _signatureViews = [[NSMutableDictionary alloc] init];
}

- (void)showMapError
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Map Error" message:@"There were problems to show the map" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}

- (NSDictionary *)retrieveLocationDictionaryFromData:(NSDictionary *)data
{
    if(!data) {
        return nil;
    }
    
    @try {
        NSString *status = [data objectForKey:@"status"];
        
        if(![status isEqualToString:@"OK"]) {
            return nil;
        }
        
        NSArray *results = [data objectForKey:@"results"];
        
        if(!results || ![results count]) {
            return nil;
        }
        
        NSDictionary *geometry = [[results objectAtIndex:0] objectForKey:@"geometry"];
        
        if(!geometry) {
            return nil;
        }
        
        NSDictionary *location = [geometry objectForKey:@"location"];
        
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:location];
        
        [dictionary setObject:[[results objectAtIndex:0] objectForKey:@"formatted_address"] forKey:@"address"];
        
        return dictionary;
    }
    @catch (NSException *exception) {
        return nil;
    }
}

- (void)openMapForIOS5WithAddress:(NSString *)address andName:(NSString *)name
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    self.mapAnnotationAddress = address;
    self.mapAnnotationName = name;
    
    NSArray *chunks = [[address stringByReplacingOccurrencesOfString:@"," withString:@""] componentsSeparatedByString:@" "];
    NSString *locationStr = [chunks componentsJoinedByString:@"+"];
    NSURL *googleUrl = [NSURL URLWithString:[NSString stringWithFormat:GOOGLE_GEOCODE_URL, locationStr]];
    NSURLRequest *request = [NSURLRequest requestWithURL:googleUrl cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:5.0];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    [connection start];
}

- (void)doOpenMapForIOS5WithData:(NSData *)googleData
{
    NSString *response = [[[NSString alloc] initWithData:googleData encoding:NSUTF8StringEncoding] autorelease];
     
    if(!response) {
        [self showMapError];
        return;
    }
     
    NSDictionary *data = [response objectFromJSONString];
    NSDictionary *location = [self retrieveLocationDictionaryFromData:data];
     
    NSNumber *latitude = [location objectForKey:@"lat"];
    NSNumber *longitude = [location objectForKey:@"lng"];
    NSString *formattedAddress = [location objectForKey:@"address"];
     
    if(!latitude || !longitude) {
        [self showMapError];
        return;
    }
     
     if(!formattedAddress) {
         formattedAddress = self.mapAnnotationAddress;
     }
     
     [MBProgressHUD hideHUDForView:self.view animated:YES];
     
     MapViewController *mapViewController = [[MapViewController alloc] initWithNibName:@"MapViewController" bundle:nil];
     mapViewController.latitude = latitude;
     mapViewController.longitude = longitude;
     mapViewController.annotationTitle = self.mapAnnotationName;
     mapViewController.annotationSubtitle = formattedAddress;
     
     [self presentModalViewController:mapViewController animated:YES];
    
     [mapViewController release];
}

- (void)openMapForIOS6WithAddress:(NSString *)address
{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:address completionHandler:^(NSArray *placemarks, NSError *error) {
        if([placemarks count] > 0) {
            MKPlacemark *placeMark = [[MKPlacemark alloc] initWithPlacemark:[placemarks objectAtIndex:0]];
            MKMapItem *mapItemAddress = [[MKMapItem alloc] initWithPlacemark:placeMark];
            NSArray *mapItems = @[mapItemAddress];
            
            [MKMapItem openMapsWithItems:mapItems launchOptions:nil];
            [placeMark release];
            [mapItemAddress release];
        } else {
            [self showMapError];
        }
    }];
}

- (void)openMapWithAddress:(NSString *)address andName:(NSString *)name
{   
    Class itemClass = [MKMapItem class];
    if(itemClass && [itemClass respondsToSelector:@selector(openMapsWithItems:launchOptions:)]) {
        
        // iOS 6
        [self openMapForIOS6WithAddress:address];
        
    } else {
        
        // iOS 5
        [self openMapForIOS5WithAddress:address andName:name];
        
    }
}

#pragma mark - IBActions methods

- (IBAction)optionsButtonPressed:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Options"
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Complete Record", @"Send Receipt", @"Attach Photos", @"Manage Attached Photos", @"Back", nil];
    
    [actionSheet showInView:self.view];
    [actionSheet release];
}

- (IBAction)pickedUpButtonPressed:(id)sender
{
    UIButton *button = (UIButton *)sender;
    NSInteger buttonNumber = button.tag;
    
    BOOL checked;
    
    if([button imageForState:UIControlStateNormal] == [_itemsDischargedButtonImages objectForKey:@"checked"]) {
        [button setImage:[_itemsDischargedButtonImages objectForKey:@"unchecked"] forState:UIControlStateNormal];
        checked = NO;
    } else {
        [button setImage:[_itemsDischargedButtonImages objectForKey:@"checked"] forState:UIControlStateNormal];
        checked = YES;
    }
    
    [_itemsPickedUp replaceObjectAtIndex:buttonNumber withObject:[NSNumber numberWithBool:checked]];
}

- (IBAction)dischargedButtonPressed:(id)sender
{
    UIButton *button = (UIButton *)sender;
    NSInteger buttonNumber = button.tag;
    
    BOOL checked;
    
    if([button imageForState:UIControlStateNormal] == [_itemsDischargedButtonImages objectForKey:@"checked"]) {
        [button setImage:[_itemsDischargedButtonImages objectForKey:@"unchecked"] forState:UIControlStateNormal];
        checked = NO;
    } else {
        [button setImage:[_itemsDischargedButtonImages objectForKey:@"checked"] forState:UIControlStateNormal];
        checked = YES;
    }
    
    [_itemsDischarged replaceObjectAtIndex:buttonNumber withObject:[NSNumber numberWithBool:checked]];
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

- (IBAction)addressButtonPressed:(id)sender
{
    UIButton *button = (UIButton *)sender;
    NSString *address = @"";
    NSString *name = @"";
    
    switch (button.tag) {
        case 0:
            address = [NSString stringWithFormat:@"%@, %@, %@ %@", self.form.billToAddress, self.form.billToCity, self.form.billToState, self.form.billToZipCode];
            name = self.form.billToName;
            break;
        
        case 1:
            address = [NSString stringWithFormat:@"%@, %@, %@ %@", self.form.consigneeAddress, self.form.consigneeCity, self.form.consigneeState, self.form.consigneeZipCode];
            name = self.form.consigneeName;
            break;
            
        case 2:
            address = [NSString stringWithFormat:@"%@, %@, %@ %@", self.form.shipperAddress, self.form.shipperCity, self.form.shipperState, self.form.shipperZipCode];
            name = self.form.shipperName;
            break;
            
        default:
            break;
    }
    
    [self openMapWithAddress:address andName:name];
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

#pragma mark - NSURLConnectionDelegate methods

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self performSelectorOnMainThread:@selector(doOpenMapForIOS5WithData:) withObject:data waitUntilDone:NO];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self performSelectorOnMainThread:@selector(showMapError) withObject:nil waitUntilDone:NO];
}

@end
