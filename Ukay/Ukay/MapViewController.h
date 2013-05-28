//
//  MapViewController.h
//  Ukay
//
//  Created by David Mazzitelli on 5/27/13.
//  Copyright (c) 2013 David Mazzitelli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import <MapKit/MapKit.h>

@interface MapViewController : BaseViewController

@property (nonatomic, retain) NSNumber *latitude;
@property (nonatomic, retain) NSNumber *longitude;
@property (nonatomic, retain) NSString *annotationTitle;
@property (nonatomic, retain) NSString *annotationSubtitle;

@end
