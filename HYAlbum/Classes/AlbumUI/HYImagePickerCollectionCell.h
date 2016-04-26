//
//  HYImagePickerCollectionCell.h
//  Pods
//
//  Created by fangyuxi on 16/4/24.
//
//

#import <UIKit/UIKit.h>

@interface HYImagePickerCollectionCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) NSIndexPath *indexPath;

- (void)selectCell;
- (void)unSelectCell;

@end
