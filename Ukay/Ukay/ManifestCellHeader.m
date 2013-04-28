//
//  ManifestCellHeader.m
//  Ukay
//
//  Created by David Mazzitelli on 4/28/13.
//  Copyright (c) 2013 David Mazzitelli. All rights reserved.
//

#import "ManifestCellHeader.h"

@interface ManifestCellHeader ()

@property (nonatomic, retain) IBOutlet UILabel *driverLabel;
@property (nonatomic, retain) IBOutlet UILabel *helperLabel;
@property (nonatomic, retain) IBOutlet UILabel *routeNameLabel;
@property (nonatomic, retain) IBOutlet UILabel *routeDateLabel;

@end

@implementation ManifestCellHeader

- (void)dealloc
{
    if(_formGroup) {
        [_formGroup release];
    }
    
    [super dealloc];
}

- (void)fillManifestHeader
{
    self.driverLabel.text = self.formGroup.driver;
    self.helperLabel.text = self.formGroup.helper;
    self.routeNameLabel.text = self.formGroup.routeName;
    self.routeDateLabel.text = @"";
    
    if(self.formGroup.date) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM-dd-yy"];
        NSDate *date = [dateFormatter dateFromString:self.formGroup.date];
        [dateFormatter release];
        
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"EEEE, MMM dd, yyyy"];
        NSString *dateStr = [dateFormatter stringFromDate:date];
        [dateFormatter release];
        
        self.routeDateLabel.text = dateStr;
    }
}

@end
