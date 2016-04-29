//
//  HYImagePickerZoomView.h
//  Pods
//
//  Created by fangyuxi on 16/4/27.
//
//

#import <UIKit/UIKit.h>

@class HYImagePickerZoomView;

@protocol HYImagePickerZoomViewDelegate <NSObject>

- (void)HYImagePickerZoomViewTapped:(HYImagePickerZoomView *)view;

@end

@interface HYImagePickerZoomView : UIScrollView
{
    
}

- (void)fetchWithItemIndex:(NSInteger)index;
- (void)ressetZoomView;

@property (nonatomic, weak) id<HYImagePickerZoomViewDelegate> tapDelegate;

@end
