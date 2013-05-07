//
//  AttachedPhotosViewController.h
//  Ukay
//
//  Created by David Mazzitelli on 5/6/13.
//  Copyright (c) 2013 David Mazzitelli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface AttachedPhotosViewController : BaseViewController <UIActionSheetDelegate>

@property (nonatomic, retain) NSMutableArray *attachedPhotoNames;

@end
