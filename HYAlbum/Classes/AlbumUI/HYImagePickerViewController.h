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

@property (nonatomic, strong, readonly) HYImagePickerHelper *helper;

@end
