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
#import "HYCache.h"
#import "HYAlbumManager.h"

@implementation HYAlbumImageGenerator{

    HYMemoryCache *_cache;
}


#pragma mark init method

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

#pragma mark get image

- (void)getThumbImageWithAlbumItem:(HYAlbumItem *)item
                         imageSize:(CGSize)size
                            result:(void(^)(UIImage *image))handler
{
    if (!item) {
        return;
    }
    
    if (SYSTEM_VERSION_GREATER_THAN(@"8.0"))
    {
        NSInteger retinaMultiplier = [UIScreen mainScreen].scale;
        CGSize retinaSquare = CGSizeMake(size.width * retinaMultiplier, size.height * retinaMultiplier);
        
        PHImageRequestOptions *option = [PHImageRequestOptions new];
        option.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        option.resizeMode = PHImageRequestOptionsResizeModeExact;
        [[PHImageManager defaultManager] requestImageForAsset:item.phAsset targetSize:retinaSquare contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage *poster, NSDictionary *info) {
            
            handler(poster);
        }];
    }
    else
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            UIImage *image = [UIImage imageWithCGImage:item.alAsset.aspectRatioThumbnail];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                handler(image);
                
            });
        });
    }
}

- (void)getPosterThumbImageWithSize:(CGSize)size
                              album:(HYAlbum *)album
                             result:(void(^)(UIImage *image))handler
{
    if (!album) {
        
        handler(nil);
        return;
    }
    
    if (SYSTEM_VERSION_GREATER_THAN(@"8.0"))
    {
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
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            handler([UIImage imageWithCGImage:album.group.posterImage]);
        });
    }
}

- (void)getFullPreViewImageWithAlbumItem:(HYAlbumItem *)item
                               imageSize:(CGSize)size
                                  result:(void(^)(UIImage *image))handler
{
    if (!item) {
        handler(nil);
        return;
    }
    
    NSString *key = [NSString stringWithFormat:@"%@_%@", item.identifier, NSStringFromCGSize(size)];
    UIImage *fullImage = [_cache objectForKey:key];
    if (fullImage) {
        handler(fullImage);
        return;
    }
    
    
    [self p_calculateSizeWithItem:item result:^(CGFloat maxPixel, BOOL islongImage, CGSize befittingImageSize) {
       
        
        if (SYSTEM_VERSION_GREATER_THAN(@"8.0"))
        {
            PHImageRequestOptions *option = [PHImageRequestOptions new];
            option.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
            option.resizeMode = PHImageRequestOptionsResizeModeFast;
            [[PHImageManager defaultManager] requestImageForAsset:item.phAsset targetSize:befittingImageSize contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage *fullImage, NSDictionary *info) {
                
                [_cache setObject:fullImage forKey:key withBlock:^(HYMemoryCache * _Nonnull cache, NSString * _Nonnull key, id  _Nullable object) {
                    
                }];
                
                handler(fullImage);
            }];
        }
        else
        {
            if (maxPixel == 0) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    handler([UIImage imageWithCGImage:item.alAsset.defaultRepresentation.fullResolutionImage]);
                });
            }
            else
            {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    
                    UIImage *fullImage = [self p_resizeImageForAsset:item.alAsset maxPixelSize:maxPixel];
                    
                    [_cache setObject:fullImage forKey:key withBlock:^(HYMemoryCache * _Nonnull cache, NSString * _Nonnull key, id  _Nullable object) {
                        
                    }];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        handler(fullImage);
                    });
                });
            }
        }
    }];
}


#pragma mark clear memory

- (void)clearMemory
{
    [_cache removeAllObjectWithBlock:^(HYMemoryCache * _Nonnull cache) {
        
    }];
}

#pragma mark resizing image

/**
 *  根据item 算出来合适显示图片的尺寸
 *
 *  @param item   item
 *  @param result block in main thread
 */
- (void)p_calculateSizeWithItem:(HYAlbumItem *)item
                         result:(void(^)(CGFloat maxPixel, BOOL islongImage, CGSize befittingImageSize))result
{
    CGSize dimensions = item.dimensions;
    CGSize finalImageSize = CGSizeZero;
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat maxPixel = 0;
    BOOL isLong = NO;
    
    if (dimensions.width > dimensions.height)
    {
        if (dimensions.width / 2 > dimensions.height &&
            dimensions.width / 2 > screenSize.width * [UIScreen mainScreen].scale)
        {
            float scale = (dimensions.height / (screenSize.width * [UIScreen mainScreen].scale));
            if (scale < 1)
            {
                maxPixel = dimensions.width;
                finalImageSize = CGSizeMake(maxPixel, dimensions.height);
            }
            else
            {
                maxPixel = dimensions.width / scale;
                finalImageSize = CGSizeMake(maxPixel, dimensions.height / scale);
            }
            isLong = YES;
        }
        else
        {
            maxPixel = 0;
            finalImageSize = CGSizeMake(screenSize.width * [UIScreen mainScreen].scale, screenSize.height * [UIScreen mainScreen].scale);
        }
    }
    else
    {
        if (dimensions.height / 2 > dimensions.width &&
            dimensions.height / 2 > screenSize.height * [UIScreen mainScreen].scale)
        {
            float scale = (dimensions.width / (screenSize.width * [UIScreen mainScreen].scale));
            if (scale < 1)
            {
                maxPixel = dimensions.height;
                finalImageSize = CGSizeMake(dimensions.width, maxPixel);
            }
            else
            {
                maxPixel = dimensions.height / scale;
                finalImageSize = CGSizeMake(dimensions.width / scale, maxPixel);
            }
            isLong = YES;
        }
        else
        {
            maxPixel = 0;
           finalImageSize = CGSizeMake(screenSize.width * [UIScreen mainScreen].scale, screenSize.height * [UIScreen mainScreen].scale);
        }
    }
    
    result(maxPixel, isLong, finalImageSize);
}

static size_t getAssetBytesCallback(void *info, void *buffer, off_t position, size_t count)
{
    ALAssetRepresentation *rep = (__bridge id)info;
    
    NSError *error = nil;
    size_t countRead = [rep getBytes:(uint8_t *)buffer fromOffset:position length:count error:&error];
    
    if (countRead == 0 && error)
    {
        NSLog(@"thumbnailForAsset:maxPixelSize: got an error reading an asset: %@", error);
    }
    
    return countRead;
}

static void releaseAssetCallback(void *info)
{
    CFRelease(info);
}

- (UIImage *)p_resizeImageForAsset:(ALAsset *)asset
                   maxPixelSize:(NSUInteger)size
{
    NSParameterAssert(asset != nil);
    NSParameterAssert(size > 0);
    
    ALAssetRepresentation *rep = [asset defaultRepresentation];
    
    CGDataProviderDirectCallbacks callbacks = {
        .version = 0,
        .getBytePointer = NULL,
        .releaseBytePointer = NULL,
        .getBytesAtPosition = getAssetBytesCallback,
        .releaseInfo = releaseAssetCallback,
    };
    
    CGDataProviderRef provider = CGDataProviderCreateDirect((void *)CFBridgingRetain(rep), [rep size], &callbacks);
    CGImageSourceRef source = CGImageSourceCreateWithDataProvider(provider, NULL);
    
    CGImageRef imageRef = CGImageSourceCreateThumbnailAtIndex(source, 0, (__bridge CFDictionaryRef)@{(NSString *)kCGImageSourceCreateThumbnailFromImageAlways : @YES,
        (NSString *)kCGImageSourceThumbnailMaxPixelSize : @(size),
        (NSString *)kCGImageSourceCreateThumbnailWithTransform : @YES});
    
    CFRelease(source);
    CFRelease(provider);
    
    if (!imageRef)
    {
        return nil;
    }
    
    return [UIImage imageWithCGImage:imageRef];
}


@end
