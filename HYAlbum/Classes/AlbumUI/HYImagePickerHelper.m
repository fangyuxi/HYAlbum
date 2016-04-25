//
//  HYImagePickerHelper.m
//  Pods
//
//  Created by fangyuxi on 16/4/23.
//
//

#import "HYImagePickerHelper.h"

@implementation HYImagePickerHelper

+ (HYImagePickerHelper *)sharedHelper
{
    static HYImagePickerHelper *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[HYImagePickerHelper alloc] init];
    });
    return _sharedInstance;
}

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
