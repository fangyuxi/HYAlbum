//
//  HYAlbum.m
//  Pods
//
//  Created by fangyuxi on 16/4/19.
//
//

#import "HYAlbum.h"
#import "HYAlbumImageGenerator.h"
#import "HYAlbumManager.h"
#import "HYAlbumPrivate.h"
#import "HYAlbumItem.h"

@interface HYAlbum ()

@property (nonatomic, strong, readwrite) ALAssetsGroup *group;
@property (nonatomic, strong, readwrite) PHAssetCollection *collection;

@end

@implementation HYAlbum{
    
    //缓存一张封面图
    UIImage *_posterImage;

}

- (instancetype)initWithALAssetGroup:(ALAssetsGroup *)group{
    self = [super init];
    if (self){
        _posterImage = nil;
        self.group = group;
        return self;
    }
    return nil;
}

- (instancetype)initWithPHCollection:(PHAssetCollection *)collectoin{
    self = [super init];
    if (self)
    {
        _posterImage = nil;
        self.collection = collectoin;
        return self;
    }
    return nil;
}

- (NSString *)identifier{
    if (SYSTEM_VERSION_GREATER_THAN(@"8.0")){
        return self.collection.localIdentifier;
    }
    else{
        return [self.group valueForProperty:ALAssetsGroupPropertyPersistentID];
    }
}

- (NSString *)albumTitle{
    if (SYSTEM_VERSION_GREATER_THAN(@"8.0")){
        return self.collection.localizedTitle;
    }
    else{
        return [self.group valueForProperty:ALAssetsGroupPropertyName];
    }
}

- (NSDate *)createDate{
    if (SYSTEM_VERSION_GREATER_THAN(@"8.0")){
        return [self.collection startDate];
    }
    else{
        return nil;
    }
}

- (NSUInteger)count{
    if (SYSTEM_VERSION_GREATER_THAN(@"8.0")){
        NSInteger num = self.assets.count;
        if (num == 0) {
            num = self.collection.estimatedAssetCount;
        }
        return num;
    }else{
        return [self.group numberOfAssets];
    }
}

- (void)getPosterThumbImageWithSize:(CGSize)size
                             result:(void(^)(UIImage *image))handler{
    if (!handler) {
        return;
    }
    if (_posterImage){
        handler(_posterImage);
    }
    [[HYAlbumImageGenerator sharedGenerator] getPosterThumbImageWithSize:size
                                                                   album:self
                                                                  result:^(UIImage *image) {
       
        _posterImage = image;
        handler(_posterImage);
    }];
}



- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[HYAlbum class]]) {
        return NO;
    }
    
    return [self isEqualToAlbum:object];
}

- (BOOL)isEqualToAlbum:(HYAlbum *)album {
    if (!album) {
        return NO;
    }
    
    return [self.identifier isEqualToString:album.identifier];
}

- (NSUInteger)hash {
    return self.identifier.hash;
}

@end
