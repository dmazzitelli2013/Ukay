//
//  DatePickerViewController.m
//  Ukay
//
//  Created by David Mazzitelli on 4/22/13.
//  Copyright (c) 2013 David Mazzitelli. All rights reserved.
//

#import "DatePickerViewController.h"

@interface DatePickerViewController ()

@property (nonatomic, retain) IBOutlet UIDatePicker *datePicker;

@end

@implementation DatePickerViewController

- (void)dealloc
{
    [_datePicker release];
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    self.datePicker = nil;
    
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)getSelectedDate
{
    NSDate *date = [self.datePicker date];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM-dd-yy"];
    
    NSString *stringFromDate = [formatter stringFromDate:date];
    [formatter release];
    
    return stringFromDate;
}

@end
