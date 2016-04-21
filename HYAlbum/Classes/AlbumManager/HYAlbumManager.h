//
//  HYAlbumManager.h
//  Pods
//
//  Created by fangyuxi on 16/4/19.
//
//

#import <Foundation/Foundation.h>

/** 目前仅支持照片获取 **/

@class HYAlbum;
@class HYAlbumItem;

typedef void(^HYAlbumManagerAlbumsListBlock)(NSArray<HYAlbum *> *albums , NSError *error);
typedef void(^HYAlbumManagerAlbumPhotosBlock)(NSArray<HYAlbumItem *> *albums , NSError *error);

/** 管理相册中的资源 **/

@interface HYAlbumManager : NSObject
{
    
}

+ (HYAlbumManager *)sharedManager;

/**
 *  获取相册列表
 *
 *  @param result 相册列表
 */
- (void)getAlbumsListResult:(HYAlbumManagerAlbumsListBlock)result;

/**
 *  获取指定相册下面的所有相片
 *
 *  @param album  相册
 *  @param result 相片
 */
- (void)getAlbum:(HYAlbum *)album
          result:(HYAlbumManagerAlbumPhotosBlock)result;


@end
