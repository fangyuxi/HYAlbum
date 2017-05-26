//
//  HYImagePickerViewController.h
//  Pods
//
//  Created by fangyuxi on 16/4/19.
//
//

#import <UIkit/UIkit.h>

@class HYImagePickerHelper;
@class HYImagePickerViewController;

extern NSString *const HYImagePickerFullScreenImageKey;
extern NSString *const HYImagePickerFullResolutImagePathKey;

@protocol HYImagePickerViewControllerDelegate<NSObject>
@optional

- (void)imagePickerController:(HYImagePickerViewController *)picker
didFinishPickingMediaWithInfo:(NSArray<UIImage *> *)info;

- (void)imagePickerControllerDidCancel:(HYImagePickerViewController *)picker;

@end

@interface HYImagePickerViewController : UINavigationController

@property (nonatomic, weak) id<HYImagePickerViewControllerDelegate> pickerDelegate;


/**
 创建

 @param maxSelectedAlow 最大可选择的数量
 @param level 原图的压缩比例
 @return 'instance'
 */
- (instancetype)initWithMaxSelectedAllow:(NSInteger)maxSelectedAlow
                       compresstionLevel:(CGFloat)level;

@end
