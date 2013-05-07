//
//  ImageUtils.m
//  Ukay
//
//  Created by David Mazzitelli on 5/6/13.
//  Copyright (c) 2013 David Mazzitelli. All rights reserved.
//

#import "ImageUtils.h"

@implementation ImageUtils

+ (NSString *)imagesDirectory
{
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *imagesPath = [documentsDirectory stringByAppendingPathComponent:@"images"];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:imagesPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:imagesPath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    return imagesPath;
}

+ (void)saveImageInDocuments:(UIImage *)image withName:(NSString *)name
{
    NSString *imagesPath = [self imagesDirectory];    
    NSString *savedImagePath = [imagesPath stringByAppendingPathComponent:name];
    NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
    [imageData writeToFile:savedImagePath atomically:NO];
}

+ (void)deleteImageFromDocuments:(NSString *)name
{
    NSString *imagePath = [self imagesDirectory];
    NSString *savedImagePath = [imagePath stringByAppendingPathComponent:name];
    [[NSFileManager defaultManager] removeItemAtPath:savedImagePath error:nil];
}

+ (UIImage *)thumbnailForImageName:(NSString *)name
{
    NSString *imagesPath = [self imagesDirectory];
    NSString *savedImagePath = [imagesPath stringByAppendingPathComponent:name];
    UIImage *image = [UIImage imageWithContentsOfFile:savedImagePath];
    
    return [self resizedImage:image withMaxWidth:300];
}

+ (UIImage *)resizedImage:(UIImage *)image withMaxWidth:(CGFloat)maxWidth
{
    CGFloat proportionality = maxWidth / image.size.width;
    CGFloat maxHeight = image.size.height * proportionality;
    
    CGRect newRect = CGRectIntegral(CGRectMake(0, 0, maxWidth, maxHeight));
    CGImageRef imageRef = image.CGImage;
    
    // Build a context that's the same dimensions as the new size
    CGContextRef bitmap = CGBitmapContextCreate(NULL,
                                                newRect.size.width,
                                                newRect.size.height,
                                                CGImageGetBitsPerComponent(imageRef),
                                                0,
                                                CGImageGetColorSpace(imageRef),
                                                CGImageGetBitmapInfo(imageRef));
    
    // Draw into the context; this scales the image
    CGContextDrawImage(bitmap, newRect, imageRef);
    
    // Get the resized image from the context and a UIImage
    CGImageRef newImageRef = CGBitmapContextCreateImage(bitmap);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    
    // Clean up
    CGContextRelease(bitmap);
    CGImageRelease(newImageRef);
    
    return newImage;
}

@end
