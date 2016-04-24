//
//  HYAlbumManager.h
//  Pods
//
//  Created by fangyuxi on 16/4/19.
//
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

/** 目前仅支持照片获取 **/

typedef NS_OPTIONS(NSInteger, HYAlbumFilterType) {

    HYAlbumFilterTypeAll = (NSInteger)ALAssetsGroupAll,
    HYAlbumFilterTypeCameraRoll = (NSInteger)ALAssetsGroupSavedPhotos,
};



@class HYAlbum;
@class HYAlbumItem;

typedef void(^HYAlbumManagerAlbumsListBlock)(NSArray<HYAlbum *> *albums , NSError *error);
typedef void(^HYAlbumManagerAlbumPhotosBlock)(NSArray<HYAlbumItem *> *items , NSError *error);

/** 管理相册中的资源 **/

@interface HYAlbumManager : NSObject
{
    
}

+ (HYAlbumManager *)sharedManager;

/**
 *  获取所有相册列表
 *
 *  @param result 相册列表
 */
- (void)getAllAlbumListWithResult:(HYAlbumManagerAlbumsListBlock)result;

/**
 *  获取指定类型的相册
 *
 *  @param result block
 *  @param type   类型
 */
- (void)getAlbumListWithResult:(HYAlbumManagerAlbumsListBlock)result
                     byFilterType:(HYAlbumFilterType)type;

/**
 *  获取指定相册下面的所有相片
 *
 *  @param album  相册
 *  @param result 相片
 */
- (void)getItemsInAlbum:(HYAlbum *)album
                 withResult:(HYAlbumManagerAlbumPhotosBlock)result;

/**
 *  获取相机胶卷中的照片
 *
 *  @param result block
 */
- (void)getItemsInCameraRollWithResult:(HYAlbumManagerAlbumPhotosBlock)result;


@end
