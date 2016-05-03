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
        
        self.maximumZoomScale = 2;
        self.minimumZoomScale = 1;
        self.zoomScale = 1;
        self.contentSize = CGSizeMake(0, 0);
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap)];
        tap.numberOfTapsRequired = 1;
        [_imageView addGestureRecognizer:tap];
        
        return self;
    }
    return nil;
}

- (void)fetchImageWithItem:(HYAlbumItem *)item
{
    CGSize screen = [UIScreen mainScreen].bounds.size;
    [item getFullScreenImageWithSize:screen result:^(UIImage *image) {
        
        _imageView.image = image;
    }];
}

- (void)ressetZoomView
{
    
}

- (void)handleSingleTap
{
    [self.tapDelegate HYImagePickerZoomViewTapped:self];
}

#pragma mark scroll view delegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imageView;
}

@end
