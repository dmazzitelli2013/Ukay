//
//  ImageUtils.h
//  Ukay
//
//  Created by David Mazzitelli on 5/6/13.
//  Copyright (c) 2013 David Mazzitelli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageUtils : NSObject

+ (void)saveImageInDocuments:(UIImage *)image withName:(NSString *)name;
+ (UIImage *)loadImageNamed:(NSString *)name;
+ (UIImage *)thumbnailForImageName:(NSString *)name;
+ (void)deleteImageFromDocuments:(NSString *)name;

@end
