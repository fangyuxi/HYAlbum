//
//  HYImagePickerHelper.m
//  Pods
//
//  Created by fangyuxi on 16/4/23.
//
//

#import "HYImagePickerHelper.h"

NSString *const HYImagePickerSelectedCountChanged = @"HYImagePickerSelectedCountChanged";

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
    [[NSNotificationCenter defaultCenter] postNotificationName:HYImagePickerSelectedCountChanged object:self];
}

- (BOOL)addSelectedItem:(HYAlbumItem *)item
{
    if (!item) {
        return NO;
    }
    
    if (self.maxSelectedCountAllow == [self.selectedItems count])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"超过选图最大限制"
                                                       delegate:nil
                                              cancelButtonTitle:@"好的"
                                              otherButtonTitles:nil, nil];
        [alert show];
        
        return NO;
    }
    
    [self.selectedItems addObject:item];
    [[NSNotificationCenter defaultCenter] postNotificationName:HYImagePickerSelectedCountChanged object:self];
    return YES;
}

- (void)deleteSelectedItem:(HYAlbumItem *)item
{
    if (!item) {
        return;
    }
    
    [self.selectedItems removeObject:item];
    [[NSNotificationCenter defaultCenter] postNotificationName:HYImagePickerSelectedCountChanged object:self];
}

@end
