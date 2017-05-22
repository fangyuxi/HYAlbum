//
//  HYAlbumItem.m
//  Pods
//
//  Created by fangyuxi on 16/4/19.
//
//

#import "HYAlbumItem.h"
#import "HYAlbumImageGenerator.h"
#import "HYAlbumManager.h"
#import "HYAlbumConstant.h"

@implementation HYAlbumItem{
    UIImage *_thumbImage;
}

#pragma mark init method

- (instancetype)init{
    _thumbImage = nil;
    return [self initWithALAsset:nil];
}

- (instancetype)initWithALAsset:(ALAsset *)asset{
    self = [super init];
    if (self){
        self.alAsset = asset;
        self.phAsset = nil;
        return self;
    }
    return nil;
}

- (instancetype)initWithPHAsset:(PHAsset *)asset{
    self = [super init];
    if (self){
        self.phAsset = asset;
        self.alAsset = nil;
        return self;
    }
    return nil;
}

#pragma mark get image

- (void)getThumbImageWithSize:(CGSize)size
                       result:(void(^)(UIImage *image))handler{
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
                            result:(void(^)(UIImage *image))handler{
    if (!handler) {
        return;
    }
    [[HYAlbumImageGenerator sharedGenerator] getFullPreViewImageWithAlbumItem:self imageSize:size result:^(UIImage *image) {
       
        handler(image);
    }];
}

- (void)getFullResolutionImageWithSize:(CGSize)size
                                result:(void(^)(UIImage *image))handler{
    if (!handler) {
        return;
    }
}

#pragma mark getters

- (NSString *)identifier{
    if (SYSTEM_VERSION_GREATER_THAN(@"8.0")){
         return self.phAsset.localIdentifier;
    }
    else{
        return [self.alAsset.defaultRepresentation.url absoluteString];
    }
}

- (NSString *)fileName{
    return nil;
}

- (CGSize)dimensions{
    if (SYSTEM_VERSION_GREATER_THAN(@"8.0")){
        CGSize size = CGSizeMake(self.phAsset.pixelWidth, self.phAsset.pixelHeight);
        return size;
    }
    else{
        return self.alAsset.defaultRepresentation.dimensions;
    }
}

#pragma mark equal

- (BOOL)isEqual:(id)object{
    return [self.identifier isEqualToString:((HYAlbumItem *)object).identifier];
}

- (NSUInteger)hash{
    return NSUINTROTATE([self.identifier hash], NSUINT_BIT / 2);
}

@end
