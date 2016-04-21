//
//  HYAlbumManager.m
//  Pods
//
//  Created by fangyuxi on 16/4/19.
//
//

#import "HYAlbumManager.h"
#import <AssetsLibrary/AssetsLibrary.h>

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

-(instancetype)init
{
    self = [super init];
    if (self)
    {
        _library = [[ALAssetsLibrary alloc] init];
        return self;
    }
    return nil;
}
    

- (void)getAlbumsListResult:(HYAlbumManagerAlbumsListBlock)result
{
    [_library enumerateGroupsWithTypes:ALAssetsGroupLibrary usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        
    } failureBlock:^(NSError *error) {
        
    }];
}

- (void)getAlbum:(HYAlbum *)album
          result:(HYAlbumManagerAlbumPhotosBlock)result
{
    if (!album)
    {
        return;
    }
}

@end
