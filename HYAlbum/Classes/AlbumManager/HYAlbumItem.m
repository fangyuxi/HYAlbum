//
//  HYAlbumItem.m
//  Pods
//
//  Created by fangyuxi on 16/4/19.
//
//

#import "HYAlbumItem.h"
#import "HYAlbumImageGenerator.h"

@implementation HYAlbumItem{

    UIImage *_thumbImage;

}

- (instancetype)init
{
    _thumbImage = nil;
    return [self initWithALAsset:nil];
}

- (instancetype)initWithALAsset:(ALAsset *)asset
{
    self = [super init];
    if (self)
    {
        self.alAsset = asset;
        self.phAsset = nil;
        return self;
    }
    return nil;
}

- (instancetype)initWithPHAsset:(PHAsset *)asset
{
    self = [super init];
    if (self)
    {
        self.phAsset = asset;
        self.alAsset = nil;
        return self;
    }
    return nil;
}

- (void)getThumbImageWithSize:(CGSize)size
                       result:(void(^)(UIImage *image))handler
{
    if (!handler) {
        return;
    }
    
    if (_thumbImage) {
        handler(_thumbImage);
    }
    
    [[HYAlbumImageGenerator sharedGenerator] getThumbImageWithAlbumItem:self imageSize:size result:^(UIImage *image) {
       
        _thumbImage = image;
        handler(_thumbImage);
    }];
}

- (void)getFullScreenImageWithSize:(CGSize)size
                            result:(void(^)(UIImage *image))handler
{
    if (!handler) {
        return;
    }
}

- (void)getFullResolutionImageWithSize:(CGSize)size
                                result:(void(^)(UIImage *image))handler
{
    if (!handler) {
        return;
    }
}

@end
