//
//  HYImagePickerZoomView.m
//  Pods
//
//  Created by fangyuxi on 16/4/27.
//
//

#import "HYImagePickerZoomView.h"
#import "HYImagePickerHelper.h"
#import "HYAlbumImageGenerator.h"
#import <AVFoundation/AVFoundation.h>

@interface HYImagePickerZoomView ()<UIScrollViewDelegate>

@end

@implementation HYImagePickerZoomView{
    
    UIImageView *_imageView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor blackColor];
        self.delegate = self;
        
        CGSize screen = [UIScreen mainScreen].bounds.size;
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screen.width, screen.height)];
        _imageView.userInteractionEnabled = YES;
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_imageView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap)];
        tap.numberOfTapsRequired = 1;
        [_imageView addGestureRecognizer:tap];
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        doubleTap.numberOfTapsRequired = 2;
        [_imageView addGestureRecognizer:doubleTap];
        
        return self;
    }
    return nil;
}

- (void)fetchImageWithItem:(HYAlbumItem *)item
{
    CGSize screen = [UIScreen mainScreen].bounds.size;
    [item getFullScreenImageWithSize:screen result:^(UIImage *image) {
        
        _imageView.image = image;
        [self displayImage];
    }];
}

- (void)displayImage
{
    if (_imageView.image)
    {
        self.maximumZoomScale = 1;
        self.minimumZoomScale = 1;
        self.zoomScale = 1;
        
        self.contentSize = CGSizeMake(0, 0);
        
        CGRect photoImageViewFrame;
        photoImageViewFrame.origin = CGPointZero;
        photoImageViewFrame.size = _imageView.image.size;
        
        _imageView.frame = photoImageViewFrame;
        self.contentSize = photoImageViewFrame.size;
        
        [self setMaxMinZoomScalesForCurrentBounds];
        
        [self setNeedsLayout];
    }
}

- (void)setMaxMinZoomScalesForCurrentBounds
{
    self.maximumZoomScale = 1;
    self.minimumZoomScale = 1;
    self.zoomScale = 1;

    // Sizes
    CGSize boundsSize = self.bounds.size;
    boundsSize.width -= 0.1;
    boundsSize.height -= 0.1;
    
    CGSize imageSize = _imageView.frame.size;
    
    CGFloat xScale = boundsSize.width / imageSize.width;
    CGFloat yScale = boundsSize.height / imageSize.height;
    CGFloat minScale = MIN(xScale, yScale);
    
    if (xScale > 1 && yScale > 1)
    {
        minScale = 1.0;
    }
    
    CGFloat maxScale = 2.0;
    if ([UIScreen instancesRespondToSelector:@selector(scale)])
    {
        maxScale = maxScale / [[UIScreen mainScreen] scale];
        
        if (maxScale < minScale)
        {
            maxScale = minScale * 2;
        }
    }
    
    self.maximumZoomScale = maxScale;
    self.minimumZoomScale = minScale;
    self.zoomScale = minScale;
    
    _imageView.frame = CGRectMake(0, 0, _imageView.frame.size.width, _imageView.frame.size.height);
    [self setNeedsLayout];    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = _imageView.frame;
    
    if (frameToCenter.size.width < boundsSize.width)
    {
        frameToCenter.origin.x = floorf((boundsSize.width - frameToCenter.size.width) / 2.0);
    }
    else
    {
        frameToCenter.origin.x = 0;
    }
    
    if (frameToCenter.size.height < boundsSize.height)
    {
        frameToCenter.origin.y = floorf((boundsSize.height - frameToCenter.size.height) / 2.0);
    }
    else
    {
        frameToCenter.origin.y = 0;
    }
    
    if (!CGRectEqualToRect(_imageView.frame, frameToCenter))
        _imageView.frame = frameToCenter;
}

- (void)ressetZoomView
{
    
}


- (void)handleSingleTap
{
    [self.tapDelegate HYImagePickerZoomViewTapped:self];
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)recognizer
{
    [NSObject cancelPreviousPerformRequestsWithTarget:_imageView];
    
    CGPoint touchPoint = [recognizer locationInView:_imageView];
    
    // Zoom
    if (self.zoomScale == self.maximumZoomScale)
    {
        // Zoom out
        [self setZoomScale:self.minimumZoomScale animated:YES];
        
    }
    else
    {
        // Zoom in
        [self zoomToRect:CGRectMake(touchPoint.x, touchPoint.y, 1, 1) animated:YES];
    }
}

#pragma mark scroll view delegate

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imageView;
}

@end
