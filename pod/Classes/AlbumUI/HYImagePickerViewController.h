//
//  HYImagePickerViewController.h
//  Pods
//
//  Created by fangyuxi on 16/4/19.
//
//

#import <UIkit/UIkit.h>

@class HYImagePickerHelper;

@interface HYImagePickerViewController : UINavigationController
{
    
}

/**
 *  最大允许选中图片数量，超过这个数量会弹alert，默认9， INT_MAX不限制
 */
- (instancetype)initWithMaxSelectedAllow:(NSInteger)maxSelectedAlow;

@property (nonatomic, strong, readonly) HYImagePickerHelper *helper;

@end
