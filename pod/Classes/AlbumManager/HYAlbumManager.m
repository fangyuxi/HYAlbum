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
#import "HYAlbumPrivate.h"

@implementation HYAlbumManager{

    ALAssetsLibrary *_assetsLibrary;
    PHPhotoLibrary  *_phPhotoLibrary;
    
    dispatch_group_t _getAlbumDispatchGroup;
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

- (instancetype)init{
    self = [super init];
    if (self){
        if (SYSTEM_VERSION_GREATER_THAN(@"8.0")){
            _phPhotoLibrary = [PHPhotoLibrary sharedPhotoLibrary];
        }else{
            _assetsLibrary = [[ALAssetsLibrary alloc] init];
        }
        return self;
    }
    return nil;
}

#pragma mark public

- (void)getAllAlbumListWithResult:(HYAlbumManagerAlbumsListBlock)result{
    [self getAlbumListWithResult:result byFilterType:HYAlbumFilterTypeAll];
}

- (void)getAlbumListWithResult:(HYAlbumManagerAlbumsListBlock)result
                     byFilterType:(HYAlbumFilterType)type{
    if (SYSTEM_VERSION_GREATER_THAN(@"8.0")){
        [self p_getCollectionByPHPhotoKitWithResult:result byType:type];
    }else{
         [self p_getGroupsByALAssetLibraryWithResult:result byType:type];
    }
}

- (void)getItemsInAlbum:(HYAlbum *)album
             withResult:(HYAlbumManagerAlbumPhotosBlock)result
           byFilterType:(HYAlbumFilterType)type
{
    if (!album){
        return;
    }
    if (SYSTEM_VERSION_GREATER_THAN(@"8.0")){
        [self p_getItemsByPHPhotoKitInAlbum:album.collection result:result filterType:type];
    }else{
        [self p_getItemsByALAssetLibraryInAlbum:album.group result:result];
    }
}

#pragma mark get album & item by PhotoKit

- (void)p_getCollectionByPHPhotoKitWithResult:(HYAlbumManagerAlbumsListBlock)result
                                       byType:(HYAlbumFilterType)type{
    NSMutableArray *collections = [NSMutableArray new];
    if (type == HYAlbumFilterTypeAll) {
        
        _getAlbumDispatchGroup = dispatch_group_create();
        if (_getAlbumDispatchGroup) {
            dispatch_group_enter(_getAlbumDispatchGroup);
            [self p_getAllImageAlbum:^(NSArray<HYAlbum *> *albums, NSError *error) {
                [collections addObjectsFromArray:[[albums reverseObjectEnumerator] allObjects]];
                dispatch_group_leave(_getAlbumDispatchGroup);
            }];
            dispatch_group_enter(_getAlbumDispatchGroup);
            [self p_getAllVideoAlbum:^(NSArray<HYAlbum *> *albums, NSError *error) {
                [collections addObjectsFromArray:[[albums reverseObjectEnumerator] allObjects]];
                dispatch_group_leave(_getAlbumDispatchGroup);
            }];
            dispatch_group_enter(_getAlbumDispatchGroup);
            [self p_getMyAlbum:^(NSArray<HYAlbum *> *albums, NSError *error) {
                [collections addObjectsFromArray:[[albums reverseObjectEnumerator] allObjects]];
                dispatch_group_leave(_getAlbumDispatchGroup);
            } byType:HYAlbumFilterTypeAll];
            
            dispatch_group_notify(_getAlbumDispatchGroup, dispatch_get_main_queue(), ^{
                result(collections, nil);
            });
        }
    }else if(type == HYAlbumFilterTypeImage){
        _getAlbumDispatchGroup = dispatch_group_create();
        if (_getAlbumDispatchGroup) {
            dispatch_group_enter(_getAlbumDispatchGroup);
            [self p_getAllImageAlbum:^(NSArray<HYAlbum *> *albums, NSError *error) {
                [collections addObjectsFromArray:[[albums reverseObjectEnumerator] allObjects]];
                dispatch_group_leave(_getAlbumDispatchGroup);
            }];
            dispatch_group_enter(_getAlbumDispatchGroup);
            [self p_getMyAlbum:^(NSArray<HYAlbum *> *albums, NSError *error) {
                [collections addObjectsFromArray:[[albums reverseObjectEnumerator] allObjects]];
                dispatch_group_leave(_getAlbumDispatchGroup);
            } byType:HYAlbumFilterTypeImage];
            
            dispatch_group_notify(_getAlbumDispatchGroup, dispatch_get_main_queue(), ^{
                result(collections, nil);
            });
        }
        
    }else if(type == HYAlbumFilterTypeVideo){
        _getAlbumDispatchGroup = dispatch_group_create();
        if (_getAlbumDispatchGroup) {
            dispatch_group_enter(_getAlbumDispatchGroup);
            [self p_getAllVideoAlbum:^(NSArray<HYAlbum *> *albums, NSError *error) {
                [collections addObjectsFromArray:[[albums reverseObjectEnumerator] allObjects]];
                dispatch_group_leave(_getAlbumDispatchGroup);
            }];
            dispatch_group_enter(_getAlbumDispatchGroup);
            [self p_getMyAlbum:^(NSArray<HYAlbum *> *albums, NSError *error) {
                [collections addObjectsFromArray:[[albums reverseObjectEnumerator] allObjects]];
                dispatch_group_leave(_getAlbumDispatchGroup);
            } byType:HYAlbumFilterTypeVideo];
            
            dispatch_group_notify(_getAlbumDispatchGroup, dispatch_get_main_queue(), ^{
                result(collections, nil);
            });
        }
    }
}

- (void)p_getAllImageAlbum:(HYAlbumManagerAlbumsListBlock)result{
    
    NSMutableArray *collections = [NSMutableArray new];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [collections addObjectsFromArray:[self p_getSmartAlbumSubtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary]];
        [collections addObjectsFromArray:[self p_getSmartAlbumSubtype:PHAssetCollectionSubtypeSmartAlbumPanoramas]];
        [collections addObjectsFromArray:[self p_getSmartAlbumSubtype:PHAssetCollectionSubtypeSmartAlbumBursts]];
        
        if (SYSTEM_VERSION_GREATER_THAN(@"9.0")) {
            [collections addObjectsFromArray:[self p_getSmartAlbumSubtype:PHAssetCollectionSubtypeSmartAlbumSelfPortraits]];
            [collections addObjectsFromArray:[self p_getSmartAlbumSubtype:PHAssetCollectionSubtypeSmartAlbumScreenshots]];
        }
        
        if (SYSTEM_VERSION_GREATER_THAN(@"10.0")) {
            [collections addObjectsFromArray:[self p_getSmartAlbumSubtype:PHAssetCollectionSubtypeSmartAlbumLivePhotos]];
            [collections addObjectsFromArray:[self p_getSmartAlbumSubtype:PHAssetCollectionSubtypeSmartAlbumDepthEffect]];
        }
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            result(collections,nil);
        });
    });
}

- (void)p_getAllVideoAlbum:(HYAlbumManagerAlbumsListBlock)result{
    NSMutableArray *collections = [NSMutableArray new];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [collections addObjectsFromArray:[self p_getSmartAlbumSubtype:PHAssetCollectionSubtypeSmartAlbumVideos]];
        [collections addObjectsFromArray:[self p_getSmartAlbumSubtype:PHAssetCollectionSubtypeSmartAlbumTimelapses]];
        [collections addObjectsFromArray:[self p_getSmartAlbumSubtype:PHAssetCollectionSubtypeSmartAlbumSlomoVideos]];
        dispatch_async(dispatch_get_main_queue(), ^{
            result(collections,nil);
        });
    });
}

//获取自己创建的相册
- (void)p_getMyAlbum:(HYAlbumManagerAlbumsListBlock)result
              byType:(HYAlbumFilterType)type{
    
    NSMutableArray *collections = [NSMutableArray new];
    
    PHFetchResult *fetchResultMyAlbum = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
    PHFetchOptions *options = [PHFetchOptions new];
    if (type == HYAlbumFilterTypeImage){
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];
    }else if (type == HYAlbumFilterTypeVideo){
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeVideo];
    }
    
    [fetchResultMyAlbum enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableArray *assets = [NSMutableArray new];
        PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:obj options:options];
        [result enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            HYAlbumItem *item = [[HYAlbumItem alloc] initWithPHAsset:obj];
            [assets addObject:item];
        }];
        if (assets.count > 0) {
            HYAlbum *album = [[HYAlbum alloc] initWithPHCollection:obj];
            album.assets = assets;
            [collections addObject:album];
        }
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        result(collections,nil);
    });
}

//获取指定智能相册
- (NSMutableArray *)p_getSmartAlbumSubtype:(PHAssetCollectionSubtype)subtype{
    NSMutableArray *collections = [NSMutableArray new];
    PHFetchResult *fetchResultMyAlbum = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:subtype options:nil];
    [fetchResultMyAlbum enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PHFetchResult *result = [PHAsset fetchKeyAssetsInAssetCollection:obj options:nil];
        if (result.count > 0){
            HYAlbum *album = [[HYAlbum alloc] initWithPHCollection:obj];
            [collections addObject:album];
        }
    }];
    
    return collections;
}

//获取指定collection中的phassets
- (void)p_getItemsByPHPhotoKitInAlbum:(PHAssetCollection *)collection
                               result:(HYAlbumManagerAlbumPhotosBlock)handler
                           filterType:(HYAlbumFilterType)type
{
    PHFetchOptions *options = [PHFetchOptions new];
    if (type == HYAlbumFilterTypeImage) {
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage]; //subType == all
    }else if (type == HYAlbumFilterTypeVideo){
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeVideo]; // subType == all
    }else{
        options = nil;
    }

    PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:collection options:options];
    NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:result.count];
    
    [result enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        PHAsset *asset = obj;
        HYAlbumItem *item = [[HYAlbumItem alloc] initWithPHAsset:asset];
        [items addObject:item];
        handler(items, nil);
    }];
}

- (void)triggerAlbumAuthWithBlock:(void(^)(BOOL couldLoadAlbum))result
{
    if (SYSTEM_VERSION_GREATER_THAN(@"8.0")){
        if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusNotDetermined){
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized){
                    result(YES);
                }else{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                    message:@"您已拒绝访问相册，请到APP设置中更改"
                                                                   delegate:nil cancelButtonTitle:@"好的"
                                                          otherButtonTitles:nil, nil];
                    [alert show];
                    result(NO);
                }
            }];
        }else if([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusDenied ||
                 [PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusRestricted){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"您已拒绝访问相册，请到APP设置中更改"
                                                           delegate:nil cancelButtonTitle:@"好的"
                                                  otherButtonTitles:nil, nil];
            [alert show];
            result(NO);
        }else{
            result(YES);
        }
    }
    else
    {
        if([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusNotDetermined){
            [_assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                
                result(YES);
                
            } failureBlock:^(NSError *error) {
                result(NO);
            }];
        }else if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusRestricted ||
                  [ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusDenied){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"您已拒绝访问相册，请到APP设置中更改"
                                                           delegate:nil cancelButtonTitle:@"好的"
                                                  otherButtonTitles:nil, nil];
            [alert show];
            result(NO);
        }else{
            result(YES);
        }
    }
}


#pragma mark get album & item by ALAssetLibrary

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

@end
