//
//  AttachedPhotosViewController.m
//  Ukay
//
//  Created by David Mazzitelli on 5/6/13.
//  Copyright (c) 2013 David Mazzitelli. All rights reserved.
//

#import "AttachedPhotosViewController.h"
#import "ImageUtils.h"

@interface AttachedPhotosViewController () {
    NSString *_currentImageName;
}

@property (nonatomic, retain) IBOutlet UIView *contentView;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

@end

@implementation AttachedPhotosViewController

- (void)dealloc
{
    [_contentView release];
    [_scrollView release];
    
    if(_attachedPhotoNames) {
        [_attachedPhotoNames release];
    }
    
    [super dealloc];
}

- (void)addImagesToContentView
{
    NSArray *subviews = [self.contentView subviews];
    for(UIView *subview in subviews) {
        [subview removeFromSuperview];
    }
    
    CGFloat totalHeight = 10;
    
    for(NSString *imageName in self.attachedPhotoNames) {
        UIImage *thumbnail = [ImageUtils thumbnailForImageName:imageName];
        totalHeight += 10;
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:thumbnail];
        imageView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imagePressed:)];
        [imageView addGestureRecognizer:tapGestureRecognizer];
        [imageView setAccessibilityIdentifier:imageName];
        [tapGestureRecognizer release];
        
        imageView.frame = CGRectMake((self.view.frame.size.width - imageView.frame.size.width) / 2.0f, totalHeight, imageView.frame.size.width, imageView.frame.size.height);
        
        totalHeight += thumbnail.size.height ;
        
        CGRect frame = self.contentView.frame;
        frame.size.height = totalHeight;
        self.contentView.frame = frame;
        
        [self.contentView addSubview:imageView];
        [imageView release];
    }
    
    [self.scrollView setContentSize:self.contentView.frame.size];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self addImagesToContentView];
}

- (void)viewDidUnload
{
    self.contentView = nil;
    self.scrollView = nil;
    
    [super viewDidUnload];
}

- (void)imagePressed:(UITapGestureRecognizer *)tapGestureRecognizer
{
    _currentImageName = tapGestureRecognizer.view.accessibilityIdentifier; // don't retain
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Options"
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Delete Photo", @"Cancel", nil];
    
    [actionSheet showInView:self.view];
    [actionSheet release];
}

#pragma mark - UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [self.attachedPhotoNames removeObject:_currentImageName];
            [ImageUtils deleteImageFromDocuments:_currentImageName];
            [self addImagesToContentView];
            break;
            
        default:
            break;
    }
}

@end
