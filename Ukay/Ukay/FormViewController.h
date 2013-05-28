//
//  FormViewController.h
//  Ukay
//
//  Created by David Mazzitelli on 4/21/13.
//  Copyright (c) 2013 David Mazzitelli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "BaseViewController.h"
#import "Form.h"

@interface FormViewController : BaseViewController <UITextViewDelegate, UITextFieldDelegate, UIPopoverControllerDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, MFMailComposeViewControllerDelegate, NSURLConnectionDelegate>

@property (nonatomic, retain) Form *form;

@end
