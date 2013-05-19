//
//  ManifestCell.m
//  Ukay
//
//  Created by David Mazzitelli on 4/21/13.
//  Copyright (c) 2013 David Mazzitelli. All rights reserved.
//

#import "ManifestCell.h"

#define MAX_DESCRIPTION_LENGTH  30

@interface ManifestCell ()

@property (nonatomic, retain) IBOutlet UIView *grayBackgroundView;
@property (nonatomic, retain) IBOutlet UILabel *customerLabel;
@property (nonatomic, retain) IBOutlet UILabel *formNumberLabel;
@property (nonatomic, retain) IBOutlet UILabel *invoiceNumberLabel;
@property (nonatomic, retain) IBOutlet UILabel *typeLabel;
@property (nonatomic, retain) IBOutlet UITextView *consigneeTextView;
@property (nonatomic, retain) IBOutlet UITextView *quantityTextView;
@property (nonatomic, retain) IBOutlet UITextView *descriptionTextView;

@end

@implementation ManifestCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)dealloc
{
    if(_form) {
        [_form release];
    }
    
    [_grayBackgroundView release];
    [_customerLabel release];
    [_formNumberLabel release];
    [_invoiceNumberLabel release];
    [_typeLabel release];
    [_consigneeTextView release];
    [_quantityTextView release];
    [_descriptionTextView release];
    
    [super dealloc];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)fillManifestCell
{
    if(!self.form) {
        return;
    }

    self.formNumberLabel.text = [NSString stringWithFormat:@"%d", self.form.formNumber];
    self.customerLabel.text = self.form.customer;
    self.invoiceNumberLabel.text = self.form.invoice;
    self.typeLabel.text = self.form.type;
    self.consigneeTextView.text = self.form.consignee;

    NSMutableString *quantityString = [NSMutableString string];
    NSMutableString *descriptionString = [NSMutableString string];

    for(Item *item in self.form.items) {
        [quantityString appendFormat:@"%@\n", item.quantity];
        
        if([item.description length] <= MAX_DESCRIPTION_LENGTH) {
            [descriptionString appendFormat:@"%@\n", item.description];
        } else {
            NSString *descriptionSubstring = [NSString stringWithFormat:@"%@...", [item.description substringToIndex:(MAX_DESCRIPTION_LENGTH - 1)]];
            [descriptionString appendFormat:@"%@\n", descriptionSubstring];
        }
    }
    
    self.quantityTextView.text = quantityString;
    self.descriptionTextView.text = descriptionString;
    
    if(self.form.formState == Completed) {
        self.grayBackgroundView.hidden = NO;
    }
}

@end
