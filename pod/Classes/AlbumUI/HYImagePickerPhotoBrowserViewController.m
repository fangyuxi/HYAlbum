//
//  HYImagePickerPhotoBrowserViewController.m
//  Pods
//
//  Created by fangyuxi on 16/4/19.
//
//

#import "HYImagePickerPhotoBrowserViewController.h"
#import "HYImagePickerHelper.h"
#import "HYImagePickerZoomView.h"

#define HYImagePickerZoomViewTag 100

@interface HYImagePickerPhotoBrowserViewController()<UIScrollViewDelegate, HYImagePickerZoomViewDelegate>

@end

@implementation HYImagePickerPhotoBrowserViewController{

    UIScrollView *_scrollView;
    HYAlbumPhotoBrowserType _browserType;
    BOOL _hidenStatusBar;
    NSInteger _nowPageNum;
}

- (void)dealloc
{
    _scrollView.delegate = nil;
}

- (instancetype)initWithBrowserType:(HYAlbumPhotoBrowserType)browserType
{
    self = [super init];
    if (self)
    {
        _browserType = browserType;
        _hidenStatusBar = NO;
        
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.extendedLayoutIncludesOpaqueBars = YES;
        
        return self;
    }
    return nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    [self p_createScrollView];
    
    [self p_updatePageNum:0];
    [self p_fetchZoomViewWithPageNum:_nowPageNum];
    [self p_fetchZoomViewWithPageNum:_nowPageNum - 1];
    [self p_fetchZoomViewWithPageNum:_nowPageNum + 1];
    
    if (_nowPageNum != 0) {
        
        [_scrollView setContentOffset:CGPointMake(_nowPageNum * _scrollView.frame.size.width, 0)];
    }
    
    if (_browserType == HYAlbumPhotoBrowserTypeNormal)
    {
        self.title = @"照片";
    }
    else
    {
        self.title = @"预览";
    }
}

- (void)p_createScrollView
{
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.pagingEnabled = YES;
    _scrollView.bounces = NO;
    _scrollView.delegate = self;
    _scrollView.backgroundColor = [UIColor blueColor];
    [self.view addSubview:_scrollView];
    
    _scrollView.contentSize = CGSizeMake([self p_numberOfBrowserPhoto] * _scrollView.frame.size.width, _scrollView.frame.size.height);
}

/**
 *  返回此次需要预览的图片数量
 *
 *  @return count
 */
- (NSInteger)p_numberOfBrowserPhoto
{
    if (_browserType == HYAlbumPhotoBrowserTypeNormal)
    {
        return [HYImagePickerHelper sharedHelper].currentPhotoCount;
    }
    else
    {
        return [[HYImagePickerHelper sharedHelper].selectedItems count];
    }
}

/**
 *  根据预览类型返回item
 *
 *  @param pageNum pageNum
 *
 *  @return item
 */
- (HYAlbumItem *)p_itemAtPageNum:(NSInteger)pageNum
{
    HYAlbumItem *item = _browserType == HYAlbumPhotoBrowserTypeNormal ? [[HYImagePickerHelper sharedHelper].currentPhotos objectAtIndex:pageNum] : [[HYImagePickerHelper sharedHelper].selectedItems objectAtIndex:pageNum];
    return item;
}

/**
 *  更新当前显示的Photo index
 *
 *  @param pageNum pageNum
 */
- (void)p_updatePageNum:(NSInteger)pageNum
{
    _nowPageNum = pageNum;
    if (_browserType == HYAlbumPhotoBrowserTypeNormal) {
        [HYImagePickerHelper sharedHelper].currentShowItemIndex = pageNum;
    }
}

/**
 *  在指定页码处添加ZoomView
 *
 *  @param pageNum pageNum
 */
- (void)p_fetchZoomViewWithPageNum:(NSInteger)pageNum
{
    if (pageNum < 0)
    {
        return;
    }
    if (pageNum >= [self p_numberOfBrowserPhoto])
    {
        return;
    }
    
    HYImagePickerZoomView *zoomView = (HYImagePickerZoomView *)[_scrollView viewWithTag:pageNum + HYImagePickerZoomViewTag];
    
    if (zoomView == nil)
    {
        zoomView = [[HYImagePickerZoomView alloc] initWithFrame:CGRectMake(_scrollView.frame.size.width*pageNum, 0, _scrollView.frame.size.width, _scrollView.frame.size.height)];
        zoomView.tapDelegate = self;
        [_scrollView addSubview:zoomView];
         zoomView.tag = pageNum + HYImagePickerZoomViewTag;
        
        [zoomView fetchImageWithItem:[self p_itemAtPageNum:pageNum]];
    }
}

/**
 *  移除制定页码处的ZoomView
 *
 *  @param pageNum pageNum
 */
- (void)p_removeZoomViewWithPageNum:(NSInteger)pageNum
{
    if (pageNum < 0)
    {
        return;
    }
    if (pageNum >= [self p_numberOfBrowserPhoto])
    {
        return;
    }
    
    HYImagePickerZoomView *photoView = (HYImagePickerZoomView *)[_scrollView viewWithTag:pageNum + HYImagePickerZoomViewTag];
    if (photoView)
    {
        [photoView removeFromSuperview];
    }
}

#pragma mark scrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!scrollView.tracking && !scrollView.decelerating)
    {
        return;
    }

    NSInteger pageNum = floor((scrollView.contentOffset.x - scrollView.frame.size.width / 2) / scrollView.frame.size.width) + 1;
    
    [self p_updatePageNum:pageNum];
    
    [self p_removeZoomViewWithPageNum:_nowPageNum - 2];
    [self p_removeZoomViewWithPageNum:_nowPageNum + 2];
    
    [self p_fetchZoomViewWithPageNum:_nowPageNum];
    [self p_fetchZoomViewWithPageNum:_nowPageNum - 1];
    [self p_fetchZoomViewWithPageNum:_nowPageNum + 1];
}

#pragma mark notification 

- (void)HYImagePickerZoomViewTapped:(HYImagePickerZoomView *)view
{
    if (self.navigationController.navigationBarHidden)
    {
        _hidenStatusBar = NO;
        
        [UIView animateWithDuration:0.2 animations:^{
            
            [self setNeedsStatusBarAppearanceUpdate];
        }];
        
        
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
    else
    {
        _hidenStatusBar = YES;
        [UIView animateWithDuration:0.2 animations:^{
            
            [self setNeedsStatusBarAppearanceUpdate];
        }];
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
- (BOOL)prefersStatusBarHidden
{
    return _hidenStatusBar;
}

@end










