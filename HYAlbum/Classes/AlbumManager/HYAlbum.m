//
//  HYAlbum.m
//  Pods
//
//  Created by fangyuxi on 16/4/19.
//
//

#import "HYAlbum.h"

@interface HYAlbum ()

@property (nonatomic, strong, readwrite) ALAssetsGroup *group;

@end

@implementation HYAlbum

@synthesize albumPosterImage = _albumPosterImage;

- (instancetype)initWithALAssetGroup:(ALAssetsGroup *)group
{
    self = [super init];
    if (self)
    {
        self.group = group;
        return self;
    }
    return nil;
}

- (UIImage *)albumPosterImage
{
    if (!_albumPosterImage) {
        _albumPosterImage = [UIImage imageWithCGImage:[self.group posterImage]];
    }
    
    return _albumPosterImage;
}

- (NSString *)albumTitle
{
    return [self.group valueForProperty:ALAssetsGroupPropertyName];
}

- (NSUInteger)count
{
    return [self.group numberOfAssets];
}

@end
