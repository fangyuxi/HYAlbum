//
//  HYImagePickerPhotoBrowserViewController.h
//  Pods
//
//  Created by fangyuxi on 16/4/19.
//
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, HYAlbumPhotoBrowserType)
{
    HYAlbumPhotoBrowserTypeNormal  = 0,
    HYAlbumPhotoBrowserTypePreView   = 1,
};

/** 预览单张图片 **/

@interface HYImagePickerPhotoBrowserViewController : UIViewController

- (instancetype)initWithBrowserType:(HYAlbumPhotoBrowserType)browserType;

@end
