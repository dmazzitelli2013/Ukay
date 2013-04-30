//
//  SignatureView.m
//  Ukay
//
//  Created by David Mazzitelli on 4/29/13.
//  Copyright (c) 2013 David Mazzitelli. All rights reserved.
//

#import "SignatureView.h"
#import <QuartzCore/QuartzCore.h>
#import "Squiggle.h"

@interface SignatureView ()

@property (nonatomic, retain) IBOutlet SignatureViewPanel *panel;
@property (nonatomic, assign) BOOL touchBeganOutsidePanel;

@end

@interface SignatureViewPanel ()

@property (nonatomic, retain) IBOutlet UIButton *resetSignatureButton;
@property (nonatomic, retain) NSMutableDictionary *squiggles;
@property (nonatomic, retain) NSMutableArray *finishedSquiggles;
@property (nonatomic, retain) UIColor *color;
@property (nonatomic, assign) float lineWidth;

@end

@implementation SignatureView

- (void)dealloc
{
    [_panel release];
    
    [super dealloc];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self.panel.layer setCornerRadius:15];
    [self.panel.layer setMasksToBounds:YES];
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
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.alpha = 0;
                     } completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
}

@end

@implementation SignatureViewPanel

- (void)dealloc
{
    [_resetSignatureButton release];
    [_squiggles release];
    [_finishedSquiggles release];
    [_color release];
    
    [super dealloc];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.squiggles = [NSMutableDictionary dictionary];
    self.finishedSquiggles = [NSMutableArray array];
    self.color = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    self.lineWidth = 3.5f;
    
    [self.resetSignatureButton addTarget:self action:@selector(resetSignatureButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    for(Squiggle *squiggle in self.finishedSquiggles) {
        [self drawSquiggle:squiggle inContext:context];
    }
    
    for(NSString *key in self.squiggles) {
        Squiggle *squiggle = [self.squiggles valueForKey:key];
        [self drawSquiggle:squiggle inContext:context];
    }
}

- (void)drawSquiggle:(Squiggle *)squiggle inContext:(CGContextRef)context
{
    UIColor *squiggleColor = squiggle.strokeColor;
    CGColorRef colorRef = [squiggleColor CGColor];
    CGContextSetStrokeColorWithColor(context, colorRef);
        
    CGContextSetLineWidth(context, squiggle.lineWidth);
        
    NSMutableArray *points = [squiggle points];
    
    if([points count] == 0) {
        return;
    }
        
    CGPoint firstPoint;
    [[points objectAtIndex:0] getValue:&firstPoint];
        
    CGContextMoveToPoint(context, firstPoint.x, firstPoint.y);
        
    for(int i = 1; i < [points count]; i++) {
        NSValue *value = [points objectAtIndex:i];
        CGPoint point;
        [value getValue:&point];
            
        CGContextAddLineToPoint(context, point.x, point.y);
    }
        
    CGContextStrokePath(context);
    UIGraphicsPushContext(context);
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSArray *array = [ touches allObjects];
    
    for(UITouch *touch in array) {
        Squiggle *squiggle = [[Squiggle alloc] init];
        [squiggle setStrokeColor:self.color];
        [squiggle setLineWidth:self.lineWidth];

        NSValue *touchValue = [NSValue valueWithPointer:touch];
        NSString *key = [NSString stringWithFormat:@"%@", touchValue];
        
        [self.squiggles setValue:squiggle forKey:key];
        [squiggle release];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSArray *array = [touches allObjects];
    
    for(UITouch *touch in array) {
        NSValue * touchValue = [NSValue valueWithPointer:touch];
        
        Squiggle *squiggle = [self.squiggles valueForKey:[NSString stringWithFormat:@"%@", touchValue]];
        
        CGPoint current = [touch locationInView:self];
        CGPoint previous = [touch previousLocationInView:self];
        [squiggle addPoint:current];
        
        CGPoint lower, higher;
        lower.x = (previous.x > current.x ? current.x : previous.x);
        lower.y	= (previous.y > current.y ? current.y: previous.y);
        higher.x = (previous.x < current.x ? current.x : previous.x);
        higher.y = (previous.y < current.y ? current.y: previous.y);
        
        [self setNeedsDisplayInRect:CGRectMake(lower.x - self.lineWidth,
                                               lower.y - self.lineWidth,
                                               higher.x - lower.x + self.lineWidth * 2,
                                               higher.y - lower.y + self.lineWidth * 2)];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for(UITouch *touch in touches) {
        NSValue *touchValue = [NSValue valueWithPointer:touch];
        NSString *key = [NSString stringWithFormat:@"%@", touchValue];
        
        Squiggle *squiggle = [self.squiggles valueForKey:key];
        [self.finishedSquiggles addObject:squiggle];
        [self.squiggles removeObjectForKey:key];
    }
}

- (void)resetView
{
    [self.squiggles removeAllObjects];
    [self.finishedSquiggles removeAllObjects];
    [self setNeedsDisplay];
}

- (IBAction)resetSignatureButtonPressed:(id)sender
{
    [self resetView];
}

@end
