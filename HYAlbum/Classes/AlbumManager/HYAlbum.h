//
//  HYAlbum.h
//  Pods
//
//  Created by fangyuxi on 16/4/19.
//
//

#import <Foundation/Foundation.h>

/** 代表一个相册 **/

@interface HYAlbum : NSObject
{
    
}

/**
 *  封面封面
 */
@property (nonatomic, strong) UIImage *albumPosterImage;

/**
 *  相册名字
 */
@property (nonatomic, copy) NSString *albumTitle;

/**
 *  创建时间
 */
@property (nonatomic, copy) NSDate *createDate;
@end
