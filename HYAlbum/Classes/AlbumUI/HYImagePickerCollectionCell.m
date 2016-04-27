//
//  HYImagePickerCollectionCell.m
//  Pods
//
//  Created by fangyuxi on 16/4/24.
//
//

#import "HYImagePickerCollectionCell.h"
#import "HYImagePickerHelper.h"

@implementation HYImagePickerCollectionCell{

    UIButton *_selecteButton;

}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_imageView];
        
        
        _selecteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_selecteButton setBackgroundColor:[UIColor redColor]];
        _selecteButton.frame = CGRectMake(frame.size.width - 24, 4, 20, 20);
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
    _selecteButton.backgroundColor = [UIColor blueColor];
}

- (void)unSelectCell
{
    if (!_selecteButton.selected) {
        return;
    }
    
    _selecteButton.selected = NO;
    _selecteButton.backgroundColor = [UIColor redColor];
}

@end





