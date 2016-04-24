//
//  HYImagePickerCollectionCell.m
//  Pods
//
//  Created by fangyuxi on 16/4/24.
//
//

#import "HYImagePickerCollectionCell.h"

@implementation HYImagePickerCollectionCell{

    UIView *_placeHolder;

}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        [self addSubview:_imageView];
        
        _placeHolder = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width - 30, 4, 26, 26)];
        _placeHolder.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.1];
        _placeHolder.layer.cornerRadius = 13;
        _placeHolder.layer.borderColor = [UIColor whiteColor].CGColor;
        _placeHolder.layer.borderWidth = 1;
        _placeHolder.userInteractionEnabled = NO;
        [self addSubview:_placeHolder];
        
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapCell:)];
//        [self addGestureRecognizer:tap];
        return self;
    }
    return nil;
}

@end
