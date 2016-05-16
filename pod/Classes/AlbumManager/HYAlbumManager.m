//
//  HYAlbumManager.m
//  Pods
//
//  Created by fangyuxi on 16/4/19.
//
//

#import "HYAlbumManager.h"
#import "HYAlbum.h"
#import "HYAlbumItem.h"

@implementation HYAlbumManager{

    ALAssetsLibrary *_assetsLibrary;
    PHPhotoLibrary  *_phPhotoLibrary;
    
    PHAsset *_phAsset;
    PHAssetCollection *_phCollection;
}

+ (HYAlbumManager *)sharedManager
{
    static HYAlbumManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[HYAlbumManager alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        if (SYSTEM_VERSION_GREATER_THAN(@"8.0"))
        {
            _phPhotoLibrary = [PHPhotoLibrary sharedPhotoLibrary];
        }
        else
        {
            _assetsLibrary = [[ALAssetsLibrary alloc] init];
        }
        
        return self;
    }
    return nil;
}

#pragma mark public

- (void)getAllAlbumListWithResult:(HYAlbumManagerAlbumsListBlock)result
{
    [self getAlbumListWithResult:result byFilterType:HYAlbumFilterTypeAll];
}

- (void)getAlbumListWithResult:(HYAlbumManagerAlbumsListBlock)result
                     byFilterType:(HYAlbumFilterType)type
{
    if (SYSTEM_VERSION_GREATER_THAN(@"8.0"))
    {
        [self p_getCollectionByPHPhotoKitWithResult:result byType:type];
    }
    else
    {
         [self p_getGroupsByALAssetLibraryWithResult:result byType:type];
    }
}

- (void)getItemsInAlbum:(HYAlbum *)album
             withResult:(HYAlbumManagerAlbumPhotosBlock)result
{
    if (!album)
    {
        return;
    }
    if (SYSTEM_VERSION_GREATER_THAN(@"8.0"))
    {
        [self p_getItemsByPHPhotoKitInAlbum:album.collection result:result];
    }
    else
    {
        [self p_getItemsByALAssetLibraryInAlbum:album.group result:result];
    }
}

- (void)getItemsInCameraRollWithResult:(HYAlbumManagerAlbumPhotosBlock)result
{
    [self getAlbumListWithResult:^(NSArray<HYAlbum *> *albums, NSError *error) {
        
        if (albums.count) {
            
            [self getItemsInAlbum:[albums objectAtIndex:0] withResult:^(NSArray<HYAlbumItem *> *items, NSError *error) {
               
                result(items, error);
            }];
        }
    } byFilterType:HYAlbumFilterTypeCameraRoll];
}


#pragma mark get album & item by ALAssetLibrary -- private

- (void)p_getGroupsByALAssetLibraryWithResult:(HYAlbumManagerAlbumsListBlock)result
                                       byType:(HYAlbumFilterType)type
{
    NSMutableArray *groups = [NSMutableArray new];
    
    void (^enumerateGroups)(ALAssetsGroup *group, BOOL *stop) = ^(ALAssetsGroup *group, BOOL *stop){
        
        if (group)
        {
            HYAlbum *album = [[HYAlbum alloc] initWithALAssetGroup:group];
            [groups addObject:album];
        }
        else
        {
            if (result)
            {
                result([[groups reverseObjectEnumerator] allObjects], nil);
            }
        }
    };
    
    void (^emuerateGroupsError)(NSError *error) = ^(NSError *error){
        
        if (result)
        {
            result(groups, error);
        }
    };
    
    if (type == HYAlbumFilterTypeAll)
    {
        [_assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll
                                      usingBlock:enumerateGroups
                                    failureBlock:emuerateGroupsError];
    }
}

- (void)p_getItemsByALAssetLibraryInAlbum:(ALAssetsGroup *)group
                 result:(HYAlbumManagerAlbumPhotosBlock)result
{
    if (!group)
    {
        result(nil,nil);
        return;
    }
    
    [group setAssetsFilter:[ALAssetsFilter allPhotos]];
    
    NSMutableArray *items = [NSMutableArray new];
    [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
       
        if (asset)
        {
            HYAlbumItem *item = [[HYAlbumItem alloc] initWithALAsset:asset];
            [items addObject:item];
        }
        else
        {
            result(items, nil);
        }
    }];
}

#pragma mark get album & item by PhotoKit -- private

- (void)p_getCollectionByPHPhotoKitWithResult:(HYAlbumManagerAlbumsListBlock)result
                                       byType:(HYAlbumFilterType)type
{
    NSMutableArray *collections = [NSMutableArray new];
    
    switch (type)
    {
        case HYAlbumFilterTypeAll:
        {
            dispatch_group_t group =  dispatch_group_create();
            
            PHFetchResult *fetchResultSmartCameraRoll = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
            
            if (fetchResultSmartCameraRoll.count > 0)
            {
                dispatch_group_enter(group);
                [fetchResultSmartCameraRoll enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:obj options:nil];
                    if (result.count != 0)
                    {
                        HYAlbum *album = [[HYAlbum alloc] initWithPHCollection:obj];
                        [collections addObject:album];
                    }
                    
                    if (idx == fetchResultSmartCameraRoll.count - 1)
                    {
                        dispatch_group_leave(group);
                    }
                    
                }];
            }
            
            PHFetchResult *fetchResultAlbum = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
            
            if (fetchResultAlbum.count > 0)
            {
                dispatch_group_enter(group);
                [fetchResultAlbum enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:obj options:nil];
                    if (result.count != 0)
                    {
                        HYAlbum *album = [[HYAlbum alloc] initWithPHCollection:obj];
                        [collections addObject:album];
                    }
                    
                    if (idx == fetchResultAlbum.count - 1)
                    {
                        dispatch_group_leave(group);
                    }
                    
                }];
            }
            
            PHFetchResult *fetchResultSmartRecentlyAdded = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumRecentlyAdded options:nil];
            
            if (fetchResultSmartRecentlyAdded.count > 0)
            {
                dispatch_group_enter(group);
                [fetchResultSmartRecentlyAdded enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:obj options:nil];
                    if (result.count != 0)
                    {
                        HYAlbum *album = [[HYAlbum alloc] initWithPHCollection:obj];
                        [collections addObject:album];
                    }
                    
                    if (idx == fetchResultSmartRecentlyAdded.count - 1)
                    {
                        dispatch_group_leave(group);
                    }
                    
                }];
            }
            
            PHFetchResult *fetchResultSmartPanoramas = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumPanoramas options:nil];
            
            if (fetchResultSmartPanoramas.count > 0)
            {
                dispatch_group_enter(group);
                [fetchResultSmartPanoramas enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:obj options:nil];
                    if (result.count != 0)
                    {
                        HYAlbum *album = [[HYAlbum alloc] initWithPHCollection:obj];
                        [collections addObject:album];
                    }
                    
                    if (idx == fetchResultSmartPanoramas.count - 1)
                    {
                        dispatch_group_leave(group);
                    }
                    
                }];
            }
            
            dispatch_group_notify(group, dispatch_get_main_queue(), ^{
                
                result([[collections reverseObjectEnumerator] allObjects], nil);
            });
            
        }
        break;
        case HYAlbumFilterTypeCameraRoll:
        {
            
        }
        break;
        default:
            break;
    }
    
    
}

- (void)p_getItemsByPHPhotoKitInAlbum:(PHAssetCollection *)collection
                                   result:(HYAlbumManagerAlbumPhotosBlock)handler
{
    PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
    NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:result.count];
    
    [result enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        PHAsset *asset = obj;
        
        if (SYSTEM_VERSION_GREATER_THAN(@"9.0"))
        {
            if (asset.mediaType == PHAssetMediaTypeImage &&
                asset.mediaSubtypes != PHAssetMediaSubtypePhotoLive &&
                asset)
            {
                HYAlbumItem *item = [[HYAlbumItem alloc] initWithPHAsset:asset];
                [items addObject:item];
            }
        }
        else
        {
            if (asset.mediaType == PHAssetMediaTypeImage &&
                asset)
            {
                HYAlbumItem *item = [[HYAlbumItem alloc] initWithPHAsset:asset];
                [items addObject:item];
            }
        }

        if (idx == result.count - 1)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
               
                handler(items, nil);
            });
        }
    }];
}

- (void)triggerAlbumAuthWithBlock:(void(^)(BOOL couldLoadAlbum))result
{
    if (SYSTEM_VERSION_GREATER_THAN(@"8.0"))
    {
        if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusNotDetermined)
        {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                
                if (status == PHAuthorizationStatusAuthorized)
                {
                    result(YES);
                }
                else
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                    message:@"您已拒绝访问相册，请到APP设置中更改"
                                                                   delegate:nil cancelButtonTitle:@"好的"
                                                          otherButtonTitles:nil, nil];
                    [alert show];
                    
                    result(NO);
                }
            }];
        }
        else if([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusDenied ||
                [PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusRestricted)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"您已拒绝访问相册，请到APP设置中更改"
                                                           delegate:nil cancelButtonTitle:@"好的"
                                                  otherButtonTitles:nil, nil];
            [alert show];
            
            result(NO);
        }
        else
        {
            result(YES);
        }

    }
    else
    {
        if([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusNotDetermined)
        {
            [_assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                
                result(YES);
                
            } failureBlock:^(NSError *error) {
                result(NO);
            }];
        }
        else if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusRestricted ||
                 [ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusDenied)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"您已拒绝访问相册，请到APP设置中更改"
                                                           delegate:nil cancelButtonTitle:@"好的"
                                                  otherButtonTitles:nil, nil];
            [alert show];
            
            result(NO);
        }
        else
        {
            result(YES);
        }

    }
}

@end
