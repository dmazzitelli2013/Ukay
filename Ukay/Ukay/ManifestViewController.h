//
//  ManifestViewController.h
//  Ukay
//
//  Created by David Mazzitelli on 4/20/13.
//  Copyright (c) 2013 David Mazzitelli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface ManifestViewController : BaseViewController <UITableViewDelegate, UITableViewDataSource>

+ (ManifestViewController *)sharedManifestViewController;

- (void)fetchData;

@end
