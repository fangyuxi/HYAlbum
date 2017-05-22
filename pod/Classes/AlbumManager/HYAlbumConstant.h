//
//  HYAlbumConstant.h
//  Pods
//
//  Created by fangyuxi on 16/4/23.
//
//



typedef NS_ENUM(NSUInteger, HYAlbumItemType)
{
    HYAlbumItemTypeUnkown  = 0,
    HYAlbumItemTypePhoto   = 1,
    HYAlbumItemTypeVideo   = 2,
    HYAlbumItemTypeLive    = 3
};


#define NSUINT_BIT (CHAR_BIT * sizeof(NSUInteger))
#define NSUINTROTATE(val, howmuch) ((((NSUInteger)val) << howmuch) | (((NSUInteger)val) >> (NSUINT_BIT - howmuch)))
