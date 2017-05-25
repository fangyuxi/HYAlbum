//
//  HYAlbumImageGenerator.h
//  Pods
//
//  Created by fangyuxi on 16/4/19.
//
//

#import <Foundation/Foundation.h>
#import "HYAlbum.h"
#import "HYAlbumItem.h"

/** 获取合适尺寸的图片并缓存 **/
/** 所有方法暂时不支持iCloud中下载图片，后期考虑支持 **/

@interface HYAlbumImageGenerator : NSObject

+ (HYAlbumImageGenerator *)sharedGenerator;

/**
 获取相册封面图

 @param size 'size'
 @param album 'album'
 @param handler 'result'
 */
- (void)getPosterThumbImageWithSize:(CGSize)size
                              album:(HYAlbum *)album
                             result:(void(^)(UIImage *image))handler;

/**
 获取指定尺寸的缩略图
 
 @param item 'item'
 @param size 'CGSize'
 @param handler 'result'
 */
- (void)getThumbImageWithAlbumItem:(HYAlbumItem *)item
                         imageSize:(CGSize)size
                            result:(void(^)(UIImage *image))handler;


/**
 获取指定尺寸的预览图

 @param item 'item'
 @param size 'CGSize'
 @param handler 'result'
 */
- (void)getFullPreViewImageWithAlbumItem:(HYAlbumItem *)item
                               imageSize:(CGSize)size
                                  result:(void(^)(UIImage *image))handler;


/**
 获取原图

 @param item 'item'
 @param handler 'result'
 */
- (void)getOriginalImageWithAlbumItem:(HYAlbumItem *)item
                               result:(void(^)(UIImage *image))handler;


/**
 清空缓存
 */
- (void)clearMemory;

@end
