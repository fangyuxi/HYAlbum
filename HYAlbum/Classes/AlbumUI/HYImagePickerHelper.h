//
//  HYImagePickerHelper.h
//  Pods
//
//  Created by fangyuxi on 16/4/23.
//
//

#import <Foundation/Foundation.h>

@interface HYImagePickerHelper : NSObject
{
    
}

+ (HYImagePickerHelper *)sharedHelper;

/**
 *  所有相册的数组
 */
@property (nonatomic, strong) NSArray *albums;

/**
 *  相册数量
 */
@property (nonatomic, assign, readonly) NSInteger albumCount;
/**
 *  当前正在浏览的相册
 */
@property (nonatomic, assign) NSInteger currentAlbumIndex;

/**
 *  当前正在浏览的相册的所有照片
 */
@property (nonatomic, strong) NSArray *currentPhotos;

/**
 *  当前正在浏览的相册的所有照片数量
 */
@property (nonatomic, assign) NSInteger currentPhotoCount;

/**
 *  当前正在浏览的照片大图
 */
@property (nonatomic, assign) NSInteger currentShowItem;

- (void)clearCurrentPhotos;
- (void)clearAlbums;

@end
