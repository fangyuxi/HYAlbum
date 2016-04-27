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

@interface HYAlbumImageGenerator : NSObject

+ (HYAlbumImageGenerator *)sharedGenerator;

/**
 *  获取相册封面图
 *
 *  @param size     size
 *  @param album    album
 *  @param handler handler  callback in main thread
 */
- (void)getPosterThumbImageWithSize:(CGSize)size
                              album:(HYAlbum *)album
                             result:(void(^)(UIImage *image))handler;

/**
 *  获取指定size的缩略图
 *
 *  @param item    item
 *  @param size    size
 *  @param handler handler 运行在主线城中的回调
 */
- (void)getThumbImageWithAlbumItem:(HYAlbumItem *)item
                         imageSize:(CGSize)size
                            result:(void(^)(UIImage *image))handler;

/**
 *  获取指定尺寸的全屏预览图
 *
 *  @param item    item
 *  @param size    size
 *  @param handler handler 运行在主线程中
 */
- (void)getFullPreViewImageWithAlbumItem:(HYAlbumItem *)item
                               imageSize:(CGSize)size
                                  result:(void(^)(UIImage *image))handler;


@end
