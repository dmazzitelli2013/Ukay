//
//  SignatureView.m
//  Ukay
//
//  Created by David Mazzitelli on 4/29/13.
//  Copyright (c) 2013 David Mazzitelli. All rights reserved.
//

#import "SignatureView.h"
#import <QuartzCore/QuartzCore.h>
#import "NICSignatureView.h"

@interface SignatureView ()

@property (nonatomic, retain) IBOutlet UIButton *button;
@property (nonatomic, retain) NICSignatureView *panel;
@property (nonatomic, assign) BOOL touchBeganOutsidePanel;

@end

@implementation SignatureView

- (void)dealloc
{
    [_button release];
    [_panel release];
    
    if(_signatureTargetView) {
        [_signatureTargetView release];
    }
    
    [super dealloc];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.panel = [[[NICSignatureView alloc] initWithFrame:CGRectMake(112, 274, 800, 200) context:nil] autorelease];
    [self.panel.layer setCornerRadius:15];
    [self.panel.layer setMasksToBounds:YES];
    
    [self insertSubview:self.panel belowSubview:self.button];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *firstTouch = [[touches allObjects] objectAtIndex:0];
    CGPoint point = [firstTouch locationInView:self];
    self.touchBeganOutsidePanel = !CGRectContainsPoint(self.panel.frame, point);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *firstTouch = [[touches allObjects] objectAtIndex:0];
    CGPoint point = [firstTouch locationInView:self];
    BOOL touchEndedOutsidePanel = !CGRectContainsPoint(self.panel.frame, point);
    
    if(touchEndedOutsidePanel && self.touchBeganOutsidePanel) {
        [self removeSlowFromSuperview];
    }
}

- (void)addSlowInView:(UIView *)view
{
    self.alpha = 0;
    [view addSubview:self];
    
    [UIView animateWithDuration:0.5
                    animations:^{
                        self.alpha = 1;
                    }];
}

- (void)removeSlowFromSuperview
{
    
    
    if([self.signatureTargetView isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)self.signatureTargetView;
        [button setBackgroundImage:nil forState:UIControlStateNormal];
        
        if(self.panel.signatureImage) {
            [button setBackgroundImage:self.panel.signatureImage forState:UIControlStateNormal];
        }
    }

    [UIView animateWithDuration:0.5
                     animations:^{
                         self.alpha = 0;
                     } completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
}

#pragma mark - IBAction methods

- (IBAction)resetSignatureButtonPressed:(id)sender
{
    [self.panel erase];
}

@end
