//
//  HYAlbum.m
//  Pods
//
//  Created by fangyuxi on 16/4/19.
//
//

#import "HYAlbum.h"
#import "HYAlbumImageGenerator.h"

@interface HYAlbum ()

@property (nonatomic, strong, readwrite) ALAssetsGroup *group;
@property (nonatomic, strong, readwrite) PHAssetCollection *collection;

@end

@implementation HYAlbum{

    UIImage *_posterImage;

}

- (instancetype)initWithALAssetGroup:(ALAssetsGroup *)group
{
    self = [super init];
    if (self)
    {
        _posterImage = nil;
        self.group = group;
        return self;
    }
    return nil;
}

- (instancetype)initWithPHCollection:(PHAssetCollection *)collectoin
{
    self = [super init];
    if (self)
    {
        _posterImage = nil;
        self.collection = collectoin;
        return self;
    }
    return nil;
}


- (NSString *)albumTitle
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_8_0
    
    return self.collection.localizedTitle;
#else
    return [self.group valueForProperty:ALAssetsGroupPropertyName];
#endif
    
   
}

- (NSUInteger)count
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_8_0
    
    PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:self.collection options:nil];
    return result.count;
    
#else
    
    return [self.group numberOfAssets];
    
#endif
}

- (void)getPosterThumbImageWithSize:(CGSize)size
                             result:(void(^)(UIImage *image))handler
{
    if (!handler) {
        return;
    }
    
    if (_posterImage){
        handler(_posterImage);
    }
    
    [[HYAlbumImageGenerator sharedGenerator] getPosterThumbImageWithSize:size
                                                                   album:self
                                                                  result:^(UIImage *image) {
       
        _posterImage = image;
        handler(_posterImage);
    }];
}

@end
