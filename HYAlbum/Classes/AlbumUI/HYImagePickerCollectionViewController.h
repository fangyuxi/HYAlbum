//
//  HYImagePickerCollectionViewController.h
//  Pods
//
//  Created by fangyuxi on 16/4/19.
//
//

#import <UIKit/UIKit.h>

@class HYAlbum;

/** 相册中的照片展示 **/

@interface HYImagePickerCollectionViewController : UIViewController

- (instancetype)initWithAlbum:(HYAlbum *)album NS_DESIGNATED_INITIALIZER;

@end
