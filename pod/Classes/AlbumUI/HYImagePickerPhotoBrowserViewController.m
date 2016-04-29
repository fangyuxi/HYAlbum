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
    [self p_fetchZoomViewWithPageNum:[HYImagePickerHelper sharedHelper].currentShowItemIndex];
    [self p_fetchZoomViewWithPageNum:[HYImagePickerHelper sharedHelper].currentShowItemIndex - 1];
    [self p_fetchZoomViewWithPageNum:[HYImagePickerHelper sharedHelper].currentShowItemIndex + 1];
    
    if ([HYImagePickerHelper sharedHelper].currentShowItemIndex != 0) {
        
        [_scrollView setContentOffset:CGPointMake([HYImagePickerHelper sharedHelper].currentShowItemIndex * _scrollView.frame.size.width, 0)];
    }
}

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
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
        [zoomView fetchWithItemIndex:pageNum];
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

    NSInteger page = floor((scrollView.contentOffset.x - scrollView.frame.size.width / 2) / scrollView.frame.size.width) + 1;
    
    [HYImagePickerHelper sharedHelper].currentShowItemIndex = page;
    
    [self p_removeZoomViewWithPageNum:[HYImagePickerHelper sharedHelper].currentShowItemIndex - 2];
    [self p_removeZoomViewWithPageNum:[HYImagePickerHelper sharedHelper].currentShowItemIndex + 2];
    
    [self p_fetchZoomViewWithPageNum:[HYImagePickerHelper sharedHelper].currentShowItemIndex];
    [self p_fetchZoomViewWithPageNum:[HYImagePickerHelper sharedHelper].currentShowItemIndex - 1];
    [self p_fetchZoomViewWithPageNum:[HYImagePickerHelper sharedHelper].currentShowItemIndex + 1];
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










