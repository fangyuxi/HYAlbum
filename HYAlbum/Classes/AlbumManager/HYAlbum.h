//
//  HYAlbum.h
//  Pods
//
//  Created by fangyuxi on 16/4/19.
//
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "HYAlbumConstant.h"
/** 代表一个相册 **/

@interface HYAlbum : NSObject
{
    
}

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithALAssetGroup:(ALAssetsGroup *)group NS_DESIGNATED_INITIALIZER;

/**
 *  封面封面
 */
@property (nonatomic, strong, readonly) UIImage *albumPosterImage;

/**
 *  相册名字
 */
@property (nonatomic, copy, readonly) NSString *albumTitle;

/**
 *  创建时间 iOS 8.0之后有效
 */
@property (nonatomic, copy, readonly) NSDate *createDate;

@property (nonatomic, assign, readwrite) NSUInteger count;

@property (nonatomic, strong, readonly) ALAssetsGroup *group;

@end
