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
    BOOL _needLayout;
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
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap)];
        tap.numberOfTapsRequired = 1;
        [_imageView addGestureRecognizer:tap];
        
        //[self setMaxMinZoomScalesForCurrentBounds:NO];
       // _needLayout = YES;
        
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

- (CGSize)imageFitSize
{
    
    if (_imageView.image.size.width > _imageView.image.size.height)
    {
        if (_imageView.image.size) {
            <#statements#>
        }
    }
}

- (void)handleSingleTap
{
    [self.tapDelegate HYImagePickerZoomViewTapped:self];
}

#pragma mark scroll view delegate

-(void)scrollViewDidZoom:(UIScrollView *)scrollView{
    CGFloat xcenter = scrollView.center.x , ycenter = scrollView.center.y;
    //目前contentsize的width是否大于原scrollview的contentsize，如果大于，设置imageview中心x点为contentsize的一半，以固定imageview在该contentsize中心。如果不大于说明图像的宽还没有超出屏幕范围，可继续让中心x点为屏幕中点，此种情况确保图像在屏幕中心。
    xcenter = scrollView.contentSize.width > scrollView.frame.size.width ?
    scrollView.contentSize.width/2 : xcenter;
    //同上，此处修改y值
    ycenter = scrollView.contentSize.height > scrollView.frame.size.height ?
    scrollView.contentSize.height/2 : ycenter;
    [_imageView setCenter:CGPointMake(xcenter, ycenter)];
}
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imageView;
}

@end
