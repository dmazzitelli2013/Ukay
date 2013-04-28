//
//  ManifestCellHeader.h
//  Ukay
//
//  Created by David Mazzitelli on 4/28/13.
//  Copyright (c) 2013 David Mazzitelli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FormGroup.h"

@interface ManifestCellHeader : UIView

@property (nonatomic, retain) FormGroup *formGroup;

- (void)fillManifestHeader;

@end
