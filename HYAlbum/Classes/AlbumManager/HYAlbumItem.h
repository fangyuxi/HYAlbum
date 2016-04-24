//
//  HYAlbumItem.h
//  Pods
//
//  Created by fangyuxi on 16/4/19.
//
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "HYAlbumConstant.h"

/** 代表相册中的一个资源 **/

@interface HYAlbumItem : NSObject
{
    
}

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithALAsset:(ALAsset *)asset NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithPHAsset:(PHAsset *)asset NS_DESIGNATED_INITIALIZER;

@property (nonatomic, assign, readonly) HYAlbumItemType itemType;

@property (nonatomic, copy, readonly) NSString *identifier;

@property (nonatomic, copy, readonly) NSString *fileName;

@property (nonatomic, assign, readonly) CGSize dimensions;

@property (nonatomic, assign, readonly) long long fileSize;

@property (nonatomic, strong, readonly) NSDate *createDate;

@property (nonatomic, strong, readonly) NSDate *moditionDate;

@property (nonatomic, strong) UIImage *thumbImage;

@property (nonatomic, strong) UIImage *fullScreenImage;

@property (nonatomic, strong) UIImage *fullResolutionImage;

@property (nonatomic, strong) ALAsset *alAsset;
@property (nonatomic, strong) PHAsset *phAsset;

@end