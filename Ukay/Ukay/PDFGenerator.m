//
//  PDFGenerator.m
//  Ukay
//
//  Created by David Mazzitelli on 4/28/13.
//  Copyright (c) 2013 David Mazzitelli. All rights reserved.
//

#import "PDFGenerator.h"
#import <QuartzCore/QuartzCore.h>
#import "ImageUtils.h"

#define UITEXTVIEW_MARGIN       10
#define UITEXTFIELD_MARGIN      5

@implementation PDFGenerator

+ (NSString *)pdfsDirectory
{
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES) objectAtIndex:0];
    
    return documentsDirectory;
}

+ (void)createPDFfromUIView:(UIView *)view andImages:(NSArray *)images saveToDocumentsWithFileName:(NSString *)filename showAlert:(BOOL)showAlert
{
    // Creates a mutable data object for updating with binary data, like a byte array
    NSMutableData *pdfData = [NSMutableData data];
    
    // Points the pdf converter to the mutable data object and to the UIView to be converted
    UIGraphicsBeginPDFContextToData(pdfData, view.bounds, nil);
    UIGraphicsBeginPDFPage();
    CGContextRef pdfContext = UIGraphicsGetCurrentContext();
    
    [self deactivateViewClass:[UITextView class] inView:view];
    [self deactivateViewClass:[UITextField class] inView:view];
    [self deactivateViewClass:[UILabel class] inView:view];
    
    // draws rect to the view and thus this is captured by UIGraphicsBeginPDFContextToData
    [view.layer renderInContext:pdfContext];
    
    [self activateViewClass:[UITextView class] inView:view];
    [self activateViewClass:[UITextField class] inView:view];
    [self activateViewClass:[UILabel class] inView:view];
    
    [self renderTextViewsFromView:view];
    [self renderTextFieldsFromView:view];
    [self renderLabelsFromView:view];
    
    [self renderImages:images];
    
    // remove PDF rendering context
    UIGraphicsEndPDFContext();
    
    // Retrieves the document directories from the iOS device
    NSString *pdfsDirectory = [self pdfsDirectory];
    NSString *documentDirectoryFilename = [pdfsDirectory stringByAppendingPathComponent:filename];
    
    // instructs the mutable data object to write its context to a file on disk
    [pdfData writeToFile:documentDirectoryFilename atomically:YES];
    NSLog(@"documentDirectoryFileName: %@", documentDirectoryFilename);
    
    if(showAlert) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"PDF file created successfully" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        [alertView release];
    }
}

+ (void)deactivateViewClass:(Class)class inView:(UIView *)view
{
    for(UIView *subView in view.subviews) {
        if([subView isKindOfClass:class]) {
            [subView setHidden:YES];
        }
    }
}

+ (void)activateViewClass:(Class)class inView:(UIView *)view
{
    for(UIView *subView in view.subviews) {
        if([subView isKindOfClass:class]) {
            [subView setHidden:NO];
        }
    }
}

+ (void)renderTextViewsFromView:(UIView *)view
{
    for(UIView *subView in view.subviews) {
        if([subView isKindOfClass:[UITextView class]]) {
            [self renderUITextView:(UITextView *)subView];
        }
    }
}

+ (void)renderTextFieldsFromView:(UIView *)view
{
    for(UIView *subView in view.subviews) {
        if([subView isKindOfClass:[UITextField class]]) {
            [self renderUITextField:(UITextField *)subView];
        }
    }
}

+ (void)renderLabelsFromView:(UIView *)view
{
    for(UIView *subView in view.subviews) {
        if([subView isKindOfClass:[UILabel class]]) {
            [self renderUILabel:(UILabel *)subView];
        }
    }
}

+ (void)renderUITextView:(UITextView *)textView
{
    NSString *textToDraw = textView.text;
    UIFont *font = textView.font;
    
    CGSize fixedSize = textView.contentSize;
    fixedSize.width -= 2 * UITEXTVIEW_MARGIN;
    fixedSize.height = 999999;
    
    CGSize stringSize = [textToDraw sizeWithFont:font constrainedToSize:fixedSize lineBreakMode:UILineBreakModeWordWrap];
    
    CGRect renderingRect;
    if(textView.textAlignment == NSTextAlignmentCenter) {
        renderingRect = CGRectMake(textView.frame.origin.x, textView.frame.origin.y + UITEXTVIEW_MARGIN, textView.contentSize.width, stringSize.height);
    } else {
        renderingRect = CGRectMake(textView.frame.origin.x + UITEXTVIEW_MARGIN, textView.frame.origin.y + UITEXTVIEW_MARGIN, stringSize.width, stringSize.height);
    }
    
    [textToDraw drawInRect:renderingRect withFont:font lineBreakMode:UILineBreakModeWordWrap alignment:textView.textAlignment];
}

+ (void)renderUITextField:(UITextField *)textField
{
    NSString *textToDraw = textField.text;
    UIFont *font = textField.font;
    
    CGSize fixedSize = textField.frame.size;
    fixedSize.width -= 2 * UITEXTFIELD_MARGIN;
    fixedSize.height = 999999;
    
    CGSize stringSize = [textToDraw sizeWithFont:font constrainedToSize:fixedSize lineBreakMode:UILineBreakModeWordWrap];
    CGRect renderingRect = CGRectMake(textField.frame.origin.x, textField.frame.origin.y + UITEXTFIELD_MARGIN, stringSize.width, stringSize.height);
    
    [textToDraw drawInRect:renderingRect withFont:font lineBreakMode:UILineBreakModeWordWrap alignment:textField.textAlignment];
}

+ (void)renderUILabel:(UILabel *)label
{
    NSString *textToDraw = label.text;
    UIFont *font = label.font;
    
    CGRect renderingRect = CGRectMake(label.frame.origin.x, label.frame.origin.y, label.frame.size.width, label.frame.size.height);
    
    [textToDraw drawInRect:renderingRect withFont:font lineBreakMode:UILineBreakModeWordWrap alignment:label.textAlignment];
}

+ (void)renderImages:(NSArray *)images
{
    for(NSString *imageName in images) {
        UIImage *image = [ImageUtils loadImageNamed:imageName];
        
        if(image) {
            UIGraphicsBeginPDFPage();
            CGRect rect = [self rectForImage:image];
            [image drawInRect:rect];
        }
    }
}

+ (CGRect)rectForImage:(UIImage *)image
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat width = screenRect.size.width;
    screenRect.size.width = screenRect.size.height;
    screenRect.size.height = width;
    
    CGFloat imageWidth = image.size.width;
    CGFloat imageHeight = image.size.height;
    CGFloat aspectRatio = imageWidth / imageHeight;
    
    if(imageWidth > imageHeight) {
        imageWidth = screenRect.size.width;
        imageHeight = imageWidth / aspectRatio;
    } else {
        imageHeight = screenRect.size.height;
        imageWidth = imageHeight * aspectRatio;
    }
    
    return CGRectMake(0, 0, imageWidth, imageHeight);
}

+ (NSData *)dataForPDFFileWithName:(NSString *)filename
{
    NSString *pdfsDirectory = [self pdfsDirectory];
    NSString *filePath = [pdfsDirectory stringByAppendingPathComponent:filename];
    NSURL *url = [NSURL fileURLWithPath:filePath];
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    return data;
}

@end
