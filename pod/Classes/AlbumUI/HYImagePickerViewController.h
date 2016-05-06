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

/**
 *  picker finish delegate
 *
 *  @param picker picker
 *  @param info   全屏预览图片： HYImagePickerFullScreenImageKey
                  原始图片路径： HYImagePickerFullResolutImagePathKey
 
    需要调用方调用dismiss
 */
- (void)imagePickerController:(HYImagePickerViewController *)picker
didFinishPickingMediaWithInfo:(NSArray<NSDictionary *> *)info;

//需要调用方调用dismiss
- (void)imagePickerControllerDidCancel:(HYImagePickerViewController *)picker;

@end

@interface HYImagePickerViewController : UINavigationController
{
    
}

@property (nonatomic, weak) id<HYImagePickerViewControllerDelegate> pickerDelegate;

/**
 *  创建 Picker
 *
 *  @param maxSelectedAlow 最大允许选择几张图片
 *  @param level           图片的压缩等级
 *
 *  @return picker
 */
- (instancetype)initWithMaxSelectedAllow:(NSInteger)maxSelectedAlow
                    andCompresstionLevel:(CGFloat)level;

@end
