//
//  HYImagePickerZoomView.h
//  Pods
//
//  Created by fangyuxi on 16/4/27.
//
//

#import <UIKit/UIKit.h>

@interface HYImagePickerZoomView : UIScrollView
{
    
}

@property (nonatomic, assign, getter=isShow) BOOL show;

- (void)fetchWithItemIndex:(NSInteger)index;
- (void)ressetZoomView;

@end
