//
//  HYCache.h
//  <https://github.com/fangyuxi/HYCache>
//
//  Created by fangyuxi on 16/4/15.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.

#import "HYMemoryCache.h"
#import "HYDiskCache.h"

NS_ASSUME_NONNULL_BEGIN

@interface HYCache : NSObject

/**
 *  Default memCache
 */
@property (nonatomic, readonly) HYMemoryCache *memCache;
/**
 *  Default diskCache
 */
@property (nonatomic, readonly) HYDiskCache *diskCache;

/**
 *  Do not use below init methods
 *
 *  @return nil
 */
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

/**
 *  init method
 *
 *  @param name name for debug call stack tree
 *
 *  @return cache
 */
- (instancetype)initWithName:(NSString *)name;

/**
 *  NS_DESIGNATED_INITIALIZER
 *
 *  @param name          name for debug call stack tree
 *  @param directoryPath path for diskCache defautl is library/cache/name
 *
 *  @return cache
 */
- (instancetype)initWithName:(NSString *)name
            andDirectoryPath:(NSString * _Nullable)directoryPath NS_DESIGNATED_INITIALIZER;


- (nullable id)objectForKey:(NSString *)key;

- (void)objectForKey:(NSString *)key
           withBlock:(nullable void (^)(NSString *key ,id __nullable object))block;

/**
 *  存储Object 会阻塞线程
 *
 *  @param key    key
 *  @param inDisk 是否存储在disk中 默认NO
 */
- (void)setObject:(id<NSCoding>)object
           forKey:(NSString *)key
           inDisk:(BOOL)inDisk;

/**
 *  存储Object 不阻塞线程，存储完毕回调block
 *
 *  @param key    key
 *  @param inDisk 是否存储在disk中 默认NO
 *  @param block  block
 */
- (void)setObject:(id<NSCoding>)object
           forKey:(NSString *)key
           inDisk:(BOOL)inDisk
        withBlock:(void(^)())block;

/**
 *  移除对象 会阻塞线程
 */
- (void)removeAllObjects;

/**
 *  异步移除对象
 *
 *  @param block block
 */
- (void)removeAllObjectsWithBlock:(void(^)())block;

/**
 *  是否包含对象
 *
 *  @param key key
 *
 *  @return BOOL
 */
- (BOOL)containsObjectForKey:(NSString *)key;

/**
 *  是否包含对象
 *
 *  @param key   key
 *  @param block block
 */
- (void)containsObjectForKey:(NSString *)key
                   withBlock:(void(^)(BOOL contained))block;
@end

NS_ASSUME_NONNULL_END