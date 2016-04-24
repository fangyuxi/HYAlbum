//
//  HYImagePickerHelper.m
//  Pods
//
//  Created by fangyuxi on 16/4/23.
//
//

#import "HYImagePickerHelper.h"

@implementation HYImagePickerHelper

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.currentAlbumIndex = -1;
        self.currentShowItem = -1;
        return self;
    }
    return nil;
}

- (NSInteger)albumCount
{
    return [self.albums count];
}

- (NSInteger)currentPhotoCount
{
    return [self.currentPhotos count];
}

@end
