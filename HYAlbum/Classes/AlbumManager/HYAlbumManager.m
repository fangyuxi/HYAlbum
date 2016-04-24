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

    ALAssetsLibrary *_library;
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
        _library = [[ALAssetsLibrary alloc] init];
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
    [self p_getGroupsByALAssetLibraryWithResult:result byType:type];
}

- (void)getItemsInAlbum:(HYAlbum *)album
             withResult:(HYAlbumManagerAlbumPhotosBlock)result
{
    if (!album)
    {
        return;
    }
    [self p_getItemsByALAssetLibraryInAlbum:album.group result:result];
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
                result(groups, nil);
            }
        }
    };
    
    void (^emuerateGroupsError)(NSError *error) = ^(NSError *error){
        
        if (result)
        {
            result(groups, error);
        }
    };
    
    [_library enumerateGroupsWithTypes:type
                            usingBlock:enumerateGroups
                          failureBlock:emuerateGroupsError];
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

@end
