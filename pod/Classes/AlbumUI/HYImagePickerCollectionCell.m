//
//  HYImagePickerCollectionCell.m
//  Pods
//
//  Created by fangyuxi on 16/4/24.
//
//

#import "HYImagePickerCollectionCell.h"
#import "HYImagePickerHelper.h"

static UIImage *normalImage = nil;
static UIImage *selectedImage = nil;

@implementation HYImagePickerCollectionCell{

    UIButton *_selecteButton;

}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        if (!normalImage) {
            normalImage = [UIImage imageNamed:@"HYAlbum.bundle/PhotoSelectedOff"];
        }
        
        if (!selectedImage) {
            selectedImage = [UIImage imageNamed:@"HYAlbum.bundle/PhotoSelectedOn"];
        }
        
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.clipsToBounds = YES;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_imageView];
        
        _selecteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_selecteButton setBackgroundImage:normalImage forState:UIControlStateNormal];
        [_selecteButton setBackgroundImage:selectedImage forState:UIControlStateSelected];
        [_selecteButton setBackgroundImage:selectedImage forState:UIControlStateHighlighted];
        _selecteButton.frame = CGRectMake(frame.size.width - 27, 2, 25, 25);
        [_selecteButton addTarget:self action:@selector(selectButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:_selecteButton];
        
        return self;
    }
    return nil;
}


- (void)selectButtonClick:(UIButton *)button
{
    if (button.selected)
    {
        HYAlbumItem *item = [[HYImagePickerHelper sharedHelper].currentPhotos objectAtIndex:self.indexPath.item];
        [[HYImagePickerHelper sharedHelper] deleteSelectedItem:item];
        [self unSelectCell];
    }
    else
    {
        HYAlbumItem *item = [[HYImagePickerHelper sharedHelper].currentPhotos objectAtIndex:self.indexPath.item];
        
        if([[HYImagePickerHelper sharedHelper] addSelectedItem:item])
        {
            [self selectCell];
        }
    }
}


- (void)selectCell
{
    if (_selecteButton.selected) {
        return;
    }
    
    _selecteButton.selected = YES;
}

- (void)unSelectCell
{
    if (!_selecteButton.selected) {
        return;
    }
    
    _selecteButton.selected = NO;
}

@end





