//
//  HYImagePickerHelper.m
//  Pods
//
//  Created by fangyuxi on 16/4/23.
//
//

#import "HYImagePickerHelper.h"
#import "HYAlbumManager.h"

NSString *const HYImagePickerSelectedCountChanged = @"HYImagePickerSelectedCountChanged";
NSString *const HYImagePickerCollectionControllerNeedUpdate = @"HYImagePickerCollectionControllerNeedUpdate";

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

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.currentAlbumIndex = -1;
        self.currentShowItemIndex = -1;
        self.maxSelectedCountAllow = 9;
        self.compresstionLevel = 0.9;
        _selectedItems = [NSMutableArray array];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(assetChanged:)
                                                     name:HYAlbumManagerAssetChanged
                                                   object:nil];
        
        return self;
    }
    return nil;
}

- (void)assetChanged:(NSNotification *)notificcation{
    NSDictionary *param = (NSDictionary *)notificcation.object;
    NSMutableSet *set = [[param objectForKey:@"ChangedItems"] mutableCopy];
    NSMutableSet *has = [NSMutableSet setWithArray:[HYImagePickerHelper sharedHelper].selectedItems];
    [set intersectSet:has];
    if (set.count > 0) {
        [set enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
            [[HYImagePickerHelper sharedHelper] deleteSelectedItem:obj];
        }];
    }
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
                                                        message:[NSString stringWithFormat:@"最多能选择%ld张照片", (long)self.maxSelectedCountAllow]
                                                       delegate:nil
                                              cancelButtonTitle:@"好的"
                                              otherButtonTitles:nil, nil];
        [alert show];
        
        return NO;
    }
    
    [self.selectedItems addObject:item];
    [[NSNotificationCenter defaultCenter] postNotificationName:HYImagePickerSelectedCountChanged object:item];
    return YES;
}

- (void)deleteSelectedItem:(HYAlbumItem *)item
{
    if (!item) {
        return;
    }
    
    [self.selectedItems removeObject:item];
    [[NSNotificationCenter defaultCenter] postNotificationName:HYImagePickerSelectedCountChanged object:item];
}

@end
