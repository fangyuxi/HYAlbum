//
//  HYImagePickerHelper.h
//  Pods
//
//  Created by fangyuxi on 16/4/23.
//
//

#import <Foundation/Foundation.h>
#import "HYAlbumItem.h"

extern NSString *const HYImagePickerSelectedCountChanged;
extern NSString *const HYImagePickerCollectionControllerNeedUpdate;

@interface HYImagePickerHelper : NSObject
{
    
}

+ (HYImagePickerHelper *)sharedHelper;

/**
 *  当前正在浏览的相册 index at albums
 */
@property (nonatomic, assign) NSInteger currentAlbumIndex;

/**
 *  所有相册的数组
 */
@property (nonatomic, strong) NSArray *albums;

/**
 *  相册数量
 */
@property (nonatomic, assign, readonly) NSInteger albumCount;

/**
 *  当前正在浏览的照片索引 index at currentPhotos
 */
@property (nonatomic, assign) NSInteger currentShowItemIndex;

/**
 *  当前正在浏览的相册的所有照片
 */
@property (nonatomic, strong) NSArray *currentPhotos;

/**
 *  当前正在浏览的相册的所有照片数量
 */
@property (nonatomic, assign) NSInteger currentPhotoCount;

/**
 *  最大允许选中图片数量，超过这个数量会弹alert，默认9， INT_MAX不限制
 */
@property (nonatomic, assign) NSInteger maxSelectedCountAllow;

/**
 *  已经选中的item数组
 */
@property (nonatomic, strong, readonly) NSMutableArray *selectedItems;

/**
 *  选中
 *
 *  @param item item
 */
- (BOOL)addSelectedItem:(HYAlbumItem *)item;

/**
 *  取消选中
 *
 *  @param item item
 */
- (void)deleteSelectedItem:(HYAlbumItem *)item;



- (void)clearCurrentPhotos;
- (void)clearAlbums;
- (void)removeAllSelected;

@end












