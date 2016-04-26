//
//  HYImagePickerHelper.m
//  Pods
//
//  Created by fangyuxi on 16/4/23.
//
//

#import "HYImagePickerHelper.h"

@interface HYImagePickerHelper ()

@property (nonatomic, strong, readwrite) NSMutableArray *selectedItems;

@end

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
        self.currentShowItemIndex = -1;
        self.maxSelectedCountAllow = 9;
        
        _selectedItems = [NSMutableArray array];
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

- (void)clearCurrentPhotos
{
    self.currentPhotos = nil;
}

- (void)clearAlbums
{
    self.albums = nil;
}

- (void)removeAllSelected
{
    self.selectedItems = [NSMutableArray array];
}

- (void)addSelectedItem:(HYAlbumItem *)item
{
    if (!item) {
        return;
    }
    
    if (self.maxSelectedCountAllow == [self.selectedItems count])
    {
        return;
    }
    
    [self.selectedItems addObject:item];
}

- (void)deleteSelectedItem:(HYAlbumItem *)item
{
    if (!item) {
        return;
    }
    
    [self.selectedItems removeObject:item];
}

@end
