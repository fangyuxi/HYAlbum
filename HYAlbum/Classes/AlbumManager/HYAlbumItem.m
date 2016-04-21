//
//  HYAlbumItem.m
//  Pods
//
//  Created by fangyuxi on 16/4/19.
//
//

#import "HYAlbumItem.h"
#import "HYAlbumImageGenerator.h"

@implementation HYAlbumItem

- (instancetype)init
{
    return [self initWithALAsset:nil];
}

- (instancetype)initWithALAsset:(ALAsset *)asset
{
    self = [super init];
    if (self)
    {
        self.alAsset = asset;
        self.phAsset = nil;
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
    }
    return nil;
}

@end
