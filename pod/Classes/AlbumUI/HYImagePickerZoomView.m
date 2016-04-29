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

@implementation HYImagePickerZoomView{
    
    UIImageView *_imageView;

}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor blackColor];
        CGSize screen = [UIScreen mainScreen].bounds.size;
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screen.width, screen.height)];
        _imageView.userInteractionEnabled = YES;
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_imageView];
        
        self.contentSize = CGSizeMake(frame.size.width, frame.size.height);
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap)];
        tap.numberOfTapsRequired = 1;
        [_imageView addGestureRecognizer:tap];
        
        return self;
    }
    return nil;
}

- (void)fetchWithItemIndex:(NSInteger)index
{
    CGSize screen = [UIScreen mainScreen].bounds.size;
    HYAlbumItem *item = [[HYImagePickerHelper sharedHelper].currentPhotos objectAtIndex:index];
    
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

@end
