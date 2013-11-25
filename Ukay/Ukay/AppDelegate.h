//
//  AppDelegate.h
//  Ukay
//
//  Created by David Mazzitelli on 4/20/13.
//  Copyright (c) 2013 David Mazzitelli. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LoginViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) LoginViewController *viewController;
@property (strong, nonatomic) NSString *pushToken;

+ (AppDelegate *)sharedAppDelegate;

@end
