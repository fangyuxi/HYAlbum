//
//  HYAlbumPrivate.h
//  Pods
//
//  Created by Romeo on 2017/5/19.
//
//

@interface HYAlbum ()

@property (nonatomic, strong, readwrite) NSArray<HYAlbumItem *> *assets;
@property (nonatomic, strong) PHFetchResult *fetchResult;

@end
