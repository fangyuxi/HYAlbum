//
//  HYImagePickerZoomView.h
//  Pods
//
//  Created by fangyuxi on 16/4/27.
//
//

#import <UIKit/UIKit.h>
#import "HYAlbumItem.h"

@class HYImagePickerZoomView;

@protocol HYImagePickerZoomViewDelegate <NSObject>

- (void)HYImagePickerZoomViewTapped:(HYImagePickerZoomView *)view;

@end

@interface HYImagePickerZoomView : UIScrollView
{
    
}

- (void)fetchImageWithItem:(HYAlbumItem *)item;

- (void)ressetZoomView;

@property (nonatomic, weak) id<HYImagePickerZoomViewDelegate> tapDelegate;

@end
