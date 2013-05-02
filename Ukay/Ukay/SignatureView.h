//
//  SignatureView.h
//  Ukay
//
//  Created by David Mazzitelli on 4/29/13.
//  Copyright (c) 2013 David Mazzitelli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignatureView : UIView

@property (nonatomic, retain) UIView *signatureTargetView;

- (void)addSlowInView:(UIView *)view;

@end