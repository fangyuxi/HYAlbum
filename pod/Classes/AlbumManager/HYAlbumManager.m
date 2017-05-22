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

NSString *const HYAlbumManagerAssetChanged = @"HYAlbumManagerAssetChanged"; // ChangedItems // ChangedAlbum

@implementation HYAlbumManager{

    ALAssetsLibrary *_assetsLibrary;
    PHPhotoLibrary  *_phPhotoLibrary;
    
    dispatch_group_t _getAlbumDispatchGroup;
    NSMutableDictionary *_albumsFetched;
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
            [_phPhotoLibrary registerChangeObserver:self];
            _albumsFetched = [NSMutableDictionary new];
        }else{
            _assetsLibrary = [[ALAssetsLibrary alloc] init];
        }
        return self;
    }
    return nil;
}

- (void)dealloc{
    [_phPhotoLibrary unregisterChangeObserver:self];
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
        [self p_getItemsByPHPhotoKitInAlbum:album result:result filterType:type];
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
        [collections addObjectsFromArray:[self p_getSmartAlbumSubtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary
                                                           filterType:HYAlbumFilterTypeImage
                                                             preFetch:YES]];
        [collections addObjectsFromArray:[self p_getSmartAlbumSubtype:PHAssetCollectionSubtypeSmartAlbumPanoramas
                                                           filterType:HYAlbumFilterTypeImage
                                                             preFetch:YES]];
        [collections addObjectsFromArray:[self p_getSmartAlbumSubtype:PHAssetCollectionSubtypeSmartAlbumBursts
                                                           filterType:HYAlbumFilterTypeImage
                                                             preFetch:YES]];
        
        if (SYSTEM_VERSION_GREATER_THAN(@"9.0")) {
            [collections addObjectsFromArray:[self p_getSmartAlbumSubtype:PHAssetCollectionSubtypeSmartAlbumSelfPortraits
                                                               filterType:HYAlbumFilterTypeImage
                                                                 preFetch:YES]];
            [collections addObjectsFromArray:[self p_getSmartAlbumSubtype:PHAssetCollectionSubtypeSmartAlbumScreenshots
                                                               filterType:HYAlbumFilterTypeImage
                                                                 preFetch:YES]];
        }
        
        if (SYSTEM_VERSION_GREATER_THAN(@"10.0")) {
            [collections addObjectsFromArray:[self p_getSmartAlbumSubtype:PHAssetCollectionSubtypeSmartAlbumLivePhotos
                                                               filterType:HYAlbumFilterTypeImage
                                                                 preFetch:YES]];
            [collections addObjectsFromArray:[self p_getSmartAlbumSubtype:PHAssetCollectionSubtypeSmartAlbumDepthEffect
                                                               filterType:HYAlbumFilterTypeImage
                                                                 preFetch:YES]];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            result(collections,nil);
        });
    });
}

- (void)p_getAllVideoAlbum:(HYAlbumManagerAlbumsListBlock)result{
    NSMutableArray *collections = [NSMutableArray new];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [collections addObjectsFromArray:[self p_getSmartAlbumSubtype:PHAssetCollectionSubtypeSmartAlbumVideos
                                                           filterType:HYAlbumFilterTypeVideo
                                                             preFetch:YES]];
        [collections addObjectsFromArray:[self p_getSmartAlbumSubtype:PHAssetCollectionSubtypeSmartAlbumTimelapses
                                                           filterType:HYAlbumFilterTypeVideo
                                                             preFetch:YES]];
        [collections addObjectsFromArray:[self p_getSmartAlbumSubtype:PHAssetCollectionSubtypeSmartAlbumSlomoVideos
                                                           filterType:HYAlbumFilterTypeVideo
                                                             preFetch:YES]];
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
        HYAlbum *album = [[HYAlbum alloc] initWithPHCollection:obj];
        [self p_getItemsByPHPhotoKitInAlbum:album result:^(NSArray<HYAlbumItem *> *items, NSError *error) {
            if (items.count > 0) {
                album.assets = items;
                [collections addObject:album];
            }
        } filterType:type];
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        result(collections,nil);
    });
}

//获取指定智能相册
- (NSMutableArray *)p_getSmartAlbumSubtype:(PHAssetCollectionSubtype)subtype
                                filterType:(HYAlbumFilterType)type
                                  preFetch:(BOOL)preFetch{
    NSMutableArray *collections = [NSMutableArray new];
    PHFetchResult *fetchResultMyAlbum = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:subtype options:nil];
    [fetchResultMyAlbum enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PHFetchResult *result = [PHAsset fetchKeyAssetsInAssetCollection:obj options:nil];
        if (result.count > 0){
            HYAlbum *album = [[HYAlbum alloc] initWithPHCollection:obj];
            [collections addObject:album];
        }
    }];
    if (preFetch) {
        if (collections.count > 0) {
            HYAlbum *album = [collections firstObject];
            [self p_getItemsByPHPhotoKitInAlbum:album result:^(NSArray<HYAlbumItem *> *items, NSError *error) {
                album.assets = items;
            } filterType:type];
        }
    }
    return collections;
}

//获取指定collection中的phassets
- (void)p_getItemsByPHPhotoKitInAlbum:(HYAlbum *)album
                               result:(HYAlbumManagerAlbumPhotosBlock)handler
                           filterType:(HYAlbumFilterType)type
{
    if (!album.collection) {
        return;
    }
    PHFetchOptions *options = [PHFetchOptions new];
    if (type == HYAlbumFilterTypeImage) {
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage]; //subType == all
    }else if (type == HYAlbumFilterTypeVideo){
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeVideo]; // subType == all
    }else{
        options = nil;
    }

    PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:album.collection options:options];
    NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:result.count];
    
    [result enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        PHAsset *asset = obj;
        HYAlbumItem *item = [[HYAlbumItem alloc] initWithPHAsset:asset];
        [items addObject:item];
    }];
    
    album.fetchResult = result;
    [_albumsFetched setObject:album forKey:album.identifier];
    handler(items, nil);
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

#pragma mark notification

- (void)photoLibraryDidChange:(PHChange *)changeInstance{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_albumsFetched enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            HYAlbum *album = (HYAlbum *)obj;
            if (album.collection) {
                PHObjectChangeDetails *details = [changeInstance changeDetailsForObject:album.collection];
                NSObject *object = [details objectAfterChanges];
                if (object) {
                    
                }
            }
            
            if (album.fetchResult) {
                PHFetchResultChangeDetails *change = [changeInstance changeDetailsForFetchResult:album.fetchResult];
                PHFetchResult *object = [change fetchResultAfterChanges];
                if (object) {
                    NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:object.count];
                    [object enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        
                        PHAsset *asset = obj;
                        HYAlbumItem *item = [[HYAlbumItem alloc] initWithPHAsset:asset];
                        [items addObject:item];
                    }];
                    
                    NSMutableSet *resultSet = nil;
                    NSMutableSet *set1 = [NSMutableSet setWithArray:album.assets];
                    NSMutableSet *set2 = [NSMutableSet setWithArray:items];
                    
                    album.fetchResult = object;
                    album.assets = items;
                    [_albumsFetched setObject:album forKey:album.identifier];
                    
                    if (set1.count > set2.count) {
                        [set1 minusSet:set2];
                        resultSet = set1;
                        [[NSNotificationCenter defaultCenter] postNotificationName:HYAlbumManagerAssetChanged object:@{@"ChangedItems":resultSet,@"ChangedAlbum":album}];
                    }else if (set1.count < set2.count){
                        [set2 minusSet:set1];
                        resultSet = set2;
                        [[NSNotificationCenter defaultCenter] postNotificationName:HYAlbumManagerAssetChanged object:@{@"ChangedItems":resultSet,@"ChangedAlbum":album}];
                    }else{
                        [[NSNotificationCenter defaultCenter] postNotificationName:HYAlbumManagerAssetChanged object:@{@"ChangedItems":[NSMutableSet new],@"ChangedAlbum":album}];
                    }
                }
            }
        }];
    });
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
