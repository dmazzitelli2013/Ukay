//
//  ManifestCell.h
//  Ukay
//
//  Created by David Mazzitelli on 4/21/13.
//  Copyright (c) 2013 David Mazzitelli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Form.h"

@interface ManifestCell : UITableViewCell

@property (nonatomic, retain) Form *form;

- (void)fillManifestCell;

@end
