//
//  HYAlbumImageGenerator.m
//  Pods
//
//  Created by fangyuxi on 16/4/19.
//
//

#import "HYAlbumImageGenerator.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "HYMemoryCache.h"

@implementation HYAlbumImageGenerator{

    HYMemoryCache *_cache;
}

+ (HYAlbumImageGenerator *)sharedGenerator
{
    static HYAlbumImageGenerator *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[HYAlbumImageGenerator alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _cache = [[HYMemoryCache alloc] initWithName:@"com.HYAlbum.ImageCache"];
        return self;
    }
    return nil;
}

- (void)getThumbImageWithAlbumItem:(HYAlbumItem *)item
                         imageSize:(CGSize)size
                            result:(void(^)(UIImage *image))handler
{
    if (!item) {
        return;
    }
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_8_0
    NSInteger retinaMultiplier = [UIScreen mainScreen].scale;
    CGSize retinaSquare = CGSizeMake(size.width * retinaMultiplier, size.height * retinaMultiplier);
    
    PHImageRequestOptions *option = [PHImageRequestOptions new];
    option.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    option.resizeMode = PHImageRequestOptionsResizeModeExact;
    [[PHImageManager defaultManager] requestImageForAsset:item.phAsset targetSize:retinaSquare contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage *poster, NSDictionary *info) {
        
        handler(poster);
    }];
#else
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        UIImage *image = [UIImage imageWithCGImage:item.alAsset.aspectRatioThumbnail];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            handler(image);
            
        });
    });
#endif
}

- (void)getPosterThumbImageWithSize:(CGSize)size
                              album:(HYAlbum *)album
                             result:(void(^)(UIImage *image))handler
{
    if (!album) {
        
        handler(nil);
        return;
    }
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_8_0
    
    PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:album.collection options:nil];
    if (result.count == 0) {
        
        handler(nil);
        return;
    }
    
    PHAsset *asset = [result objectAtIndex:0];
    NSInteger retinaMultiplier = [UIScreen mainScreen].scale;
    CGSize retinaSquare = CGSizeMake(size.width * retinaMultiplier, size.height * retinaMultiplier);
    
    PHImageRequestOptions *option = [PHImageRequestOptions new];
    option.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    option.resizeMode = PHImageRequestOptionsResizeModeExact;
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:retinaSquare contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage *poster, NSDictionary *info) {
        
        handler(poster);
    }];
#else
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        handler([UIImage imageWithCGImage:album.group.posterImage]);
    });
    
#endif
}

- (void)getFullPreViewImageWithAlbumItem:(HYAlbumItem *)item
                               imageSize:(CGSize)size
                                  result:(void(^)(UIImage *image))handler
{
    if (!item) {
        handler(nil);
        return;
    }
    
    UIImage *poster = [_cache objectForKey:item.identifier];
    if (poster) {
        handler(poster);
        return;
    }
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_8_0
    
    NSInteger retinaMultiplier = [UIScreen mainScreen].scale;
    CGSize retinaSquare = CGSizeMake(size.width * retinaMultiplier, size.height * retinaMultiplier);
    
    PHImageRequestOptions *option = [PHImageRequestOptions new];
    option.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    option.resizeMode = PHImageRequestOptionsResizeModeExact;
    [[PHImageManager defaultManager] requestImageForAsset:item.phAsset targetSize:retinaSquare contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage *poster, NSDictionary *info) {
        
        [_cache setObject:poster forKey:item.identifier withBlock:^(HYMemoryCache * _Nonnull cache, NSString * _Nonnull key, id  _Nullable object) {
            
        }];
        
        handler(poster);
    }];
    
#else
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        handler([UIImage imageWithCGImage:item.alAsset.defaultRepresentation.fullResolutionImage]);
    });
    
#endif
    
    
}

- (void)clearMemory
{
    [_cache removeAllObjectWithBlock:^(HYMemoryCache * _Nonnull cache) {
        
    }];
}

@end
