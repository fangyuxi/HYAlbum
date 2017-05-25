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

+ (HYAlbumImageGenerator *)sharedGenerator{
    static HYAlbumImageGenerator *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[HYAlbumImageGenerator alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init{
    self = [super init];
    _cache = [[HYMemoryCache alloc] initWithName:@"com.hyalbum.imagegeneratorcache"];
    return self;
}

#pragma mark get image

- (void)getThumbImageWithAlbumItem:(HYAlbumItem *)item
                         imageSize:(CGSize)size
                            result:(void(^)(UIImage *image))handler
{
    if (!item) {
        return;
    }
    
    if (SYSTEM_VERSION_GREATER_THAN(@"8.0")){
        NSInteger retinaMultiplier = [UIScreen mainScreen].scale;
        CGSize retinaSquare = CGSizeMake(size.width * retinaMultiplier, size.height * retinaMultiplier);
        
        PHImageRequestOptions *option = [PHImageRequestOptions new];
        option.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        option.resizeMode = PHImageRequestOptionsResizeModeExact;
        [[PHCachingImageManager defaultManager] requestImageForAsset:item.phAsset targetSize:retinaSquare contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage *poster, NSDictionary *info) {
            handler(poster);
        }];
    }else{
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
    if (SYSTEM_VERSION_GREATER_THAN(@"8.0")){
        PHAsset *asset = nil;
        if (album.assets.count > 0) {
            asset = [album.assets firstObject].phAsset;
        }else{
            PHFetchResult *result = [PHAsset fetchKeyAssetsInAssetCollection:album.collection options:nil];
            if (result.count == 0) {
                handler(nil);
                return;
            }
            asset = [result firstObject];
        }
        
        NSInteger retinaMultiplier = [UIScreen mainScreen].scale;
        CGSize retinaSquare = CGSizeMake(size.width * retinaMultiplier, size.height * retinaMultiplier);
        
        PHImageRequestOptions *option = [PHImageRequestOptions new];
        option.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        option.resizeMode = PHImageRequestOptionsResizeModeExact;
        [[PHCachingImageManager defaultManager] requestImageForAsset:asset targetSize:retinaSquare contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage *poster, NSDictionary *info) {
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
    __block UIImage *fullImage = [_cache objectForKey:key];
    if (fullImage) {
        handler(fullImage);
        return;
    }
    [self p_calculateSizeWithItem:item result:^(CGSize befittingImageSize) {
        if (SYSTEM_VERSION_GREATER_THAN(@"8.0")){
            PHImageRequestOptions *option = [PHImageRequestOptions new];
            option.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
            option.resizeMode = PHImageRequestOptionsResizeModeFast;
            [[PHCachingImageManager defaultManager] requestImageForAsset:item.phAsset
                                                              targetSize:befittingImageSize
                                                             contentMode:PHImageContentModeAspectFill
                                                                 options:option resultHandler:^(UIImage *fullImage, NSDictionary *info) {
                [_cache setObject:fullImage forKey:key withBlock:^(HYMemoryCache * _Nonnull cache, NSString * _Nonnull key, id  _Nullable object) {
                }];
                handler(fullImage);
            }];
        }
        else{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                fullImage = [UIImage imageWithCGImage:item.alAsset.defaultRepresentation.fullScreenImage];
                [_cache setObject:fullImage forKey:key withBlock:^(HYMemoryCache * _Nonnull cache, NSString * _Nonnull key, id  _Nullable object) {
                    
                }];
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    handler(fullImage);
                });
            });
        }
    }];
}

- (void)getOriginalImageWithAlbumItem:(HYAlbumItem *)item
                               result:(void(^)(UIImage *image))handler{
    if (!item) {
        handler(nil);
        return;
    }
    
    __block UIImage *resultImage;
    if (SYSTEM_VERSION_GREATER_THAN(@"8.0")) {
        PHImageRequestOptions *phImageRequestOptions = [[PHImageRequestOptions alloc] init];
        phImageRequestOptions.version = PHImageRequestOptionsVersionCurrent;
        phImageRequestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
        phImageRequestOptions.synchronous = YES;
        [[PHCachingImageManager defaultManager] requestImageForAsset:item.phAsset
                                                          targetSize:PHImageManagerMaximumSize
                                                         contentMode:PHImageContentModeDefault
                                                             options:phImageRequestOptions
                                                       resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            handler(result);
        }];
    } else {
        CGImageRef fullResolutionImageRef = [item.alAsset.defaultRepresentation fullResolutionImage];
        // 通过 fullResolutionImage 获取到的的高清图实际上并不带上在照片应用中使用“编辑”处理的效果，需要额外在 AlAssetRepresentation 中获取这些信息
        NSString *adjustment = [[item.alAsset.defaultRepresentation metadata] objectForKey:@"AdjustmentXMP"];
        if (adjustment) {
            // 如果有在照片应用中使用“编辑”效果，则需要获取这些编辑后的滤镜，手工叠加到原图中
            NSData *xmpData = [adjustment dataUsingEncoding:NSUTF8StringEncoding];
            CIImage *tempImage = [CIImage imageWithCGImage:fullResolutionImageRef];
            
            NSError *error;
            NSArray *filterArray = [CIFilter filterArrayFromSerializedXMP:xmpData
                                                         inputImageExtent:tempImage.extent
                                                                    error:&error];
            CIContext *context = [CIContext contextWithOptions:nil];
            if (filterArray && !error) {
                for (CIFilter *filter in filterArray) {
                    [filter setValue:tempImage forKey:kCIInputImageKey];
                    tempImage = [filter outputImage];
                }
                fullResolutionImageRef = [context createCGImage:tempImage fromRect:[tempImage extent]];
            }
        }
        // 生成最终返回的 UIImage，同时把图片的 orientation 也补充上去
        resultImage = [UIImage imageWithCGImage:fullResolutionImageRef scale:[item.alAsset.defaultRepresentation scale] orientation:(UIImageOrientation)[item.alAsset.defaultRepresentation orientation]];
        handler(resultImage);
    }
    
}



#pragma mark clear memory

- (void)clearMemory
{
    [_cache removeAllObjectWithBlock:^(HYMemoryCache * _Nonnull cache) {
        
    }];
}

#pragma mark resizing image


/**
 根据item 算出来合适显示图片的尺寸

 @param item 'item'
 @param result 'result'
 */
- (void)p_calculateSizeWithItem:(HYAlbumItem *)item
                         result:(void(^)(CGSize befittingImageSize))result
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
    
    result(finalImageSize);
}

@end
