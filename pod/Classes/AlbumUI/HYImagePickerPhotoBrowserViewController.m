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
#import "HYImagePickerViewController.h"

#define HYImagePickerZoomViewTag 100

@interface HYImagePickerPhotoBrowserViewController()<UIScrollViewDelegate, HYImagePickerZoomViewDelegate>

@end

@implementation HYImagePickerPhotoBrowserViewController{

    UIScrollView *_scrollView;
    HYAlbumPhotoBrowserType _browserType;
    NSInteger _nowPageNum;
    
    UIButton *_rightSelectButton;
    
    NSArray *_preViewItemArray;
    
    UIBarButtonItem *_selectNumBarButton;
    UIBarButtonItem *_previewBarButton;
    UIBarButtonItem *_doneBarButton;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _scrollView.delegate = nil;
}

- (instancetype)initWithBrowserType:(HYAlbumPhotoBrowserType)browserType
{
    self = [super init];
    if (self)
    {
        _browserType = browserType;
        
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
    
    if (_browserType == HYAlbumPhotoBrowserTypeNormal)
    {
        self.title = @"照片";
    }
    else
    {
        self.title = @"预览";
        _preViewItemArray = [[HYImagePickerHelper sharedHelper].selectedItems copy];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(selectedItemsCountChanged:)
                                                 name:HYImagePickerSelectedCountChanged
                                               object:nil];
    
    [self p_createNavBarItem];
    [self p_createToolBar];
    [self p_createScrollView];
    
    NSInteger pageNum = _browserType == HYAlbumPhotoBrowserTypeNormal ? [HYImagePickerHelper sharedHelper].currentShowItemIndex : 0;
    [self p_updatePageNum:pageNum];
    [self p_fetchZoomViewWithPageNum:_nowPageNum];
    [self p_fetchZoomViewWithPageNum:_nowPageNum - 1];
    [self p_fetchZoomViewWithPageNum:_nowPageNum + 1];
    
    if (_nowPageNum != 0) {
        
        [_scrollView setContentOffset:CGPointMake(_nowPageNum * _scrollView.frame.size.width, 0)];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.toolbarHidden = NO;
    self.navigationController.toolbar.barTintColor = [UIColor blackColor];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}

- (void)p_createNavBarItem
{
    _rightSelectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_rightSelectButton setBackgroundImage:[UIImage imageNamed:@"HYAlbum.bundle/PhotoSelectedOff"] forState:UIControlStateNormal];
    [_rightSelectButton setBackgroundImage:[UIImage imageNamed:@"HYAlbum.bundle/PhotoSelectedOn"] forState:UIControlStateSelected];
    [_rightSelectButton setBackgroundImage:[UIImage imageNamed:@"HYAlbum.bundle/PhotoSelectedOn"] forState:UIControlStateHighlighted];
    [_rightSelectButton addTarget:self action:@selector(p_selectItem) forControlEvents:UIControlEventTouchUpInside];
    _rightSelectButton.frame = CGRectMake(0, 0, 25, 25);
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:_rightSelectButton];
    self.navigationItem.rightBarButtonItem = item;
}

- (void)p_createToolBar
{
    UIBarButtonItem *leftFix = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    UIBarButtonItem *rightFix = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    _previewBarButton = [[UIBarButtonItem alloc] initWithTitle:@"原图" style:UIBarButtonItemStylePlain target:self action:@selector(p_selectFullImage)];
    _previewBarButton.enabled = NO;
    UIBarButtonItem *fix = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    _selectNumBarButton = [[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"%ld/%ld", (unsigned long)[[HYImagePickerHelper sharedHelper].selectedItems count], (long)[HYImagePickerHelper sharedHelper].maxSelectedCountAllow] style:UIBarButtonItemStylePlain target:nil action:nil];
    UIBarButtonItem *fix2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    _doneBarButton = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(p_choiceDone)];
    
    _selectNumBarButton.enabled = [[HYImagePickerHelper sharedHelper].selectedItems count] > 0 ? YES : NO;
    _doneBarButton.enabled = [[HYImagePickerHelper sharedHelper].selectedItems count] > 0 ? YES : NO;
    //_previewBarButton.enabled = [[HYImagePickerHelper sharedHelper].selectedItems count] > 0 ? YES : NO;
    
    [self setToolbarItems:@[leftFix, _previewBarButton, fix, _selectNumBarButton, fix2, _doneBarButton, rightFix]];
    self.navigationController.toolbar.tintColor = [UIColor colorWithRed:255.0f / 255.0f green:99.0f / 255.0f blue:96.0f / 255.0f alpha:1];
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

- (void)p_selectFullImage
{
    
}

- (void)p_choiceDone
{
    HYImagePickerViewController *picker = (HYImagePickerViewController *)self.navigationController;
    if (picker.pickerDelegate && [picker.pickerDelegate respondsToSelector:@selector(imagePickerController:didFinishPickingMediaWithInfo:)]) {
        
        NSMutableArray *array = [NSMutableArray array];
        dispatch_group_t group = dispatch_group_create();
        
        for (HYAlbumItem *item in [HYImagePickerHelper sharedHelper].selectedItems)
        {
            dispatch_group_enter(group);
            [item getFullScreenImageWithSize:[UIScreen mainScreen].bounds.size result:^(UIImage *image) {
                
                @autoreleasepool
                {
                    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                    if (image)
                    {
                        NSData *data = UIImageJPEGRepresentation(image, [HYImagePickerHelper sharedHelper].compresstionLevel);
                        UIImage *depressImage = [UIImage imageWithData:data scale:[[UIScreen mainScreen] scale]];
                        if (depressImage)
                        {
                            [dic setObject:depressImage forKey:HYImagePickerFullScreenImageKey];
                        }
                        [array addObject:dic];
                    }
                }
                
                dispatch_group_leave(group);
            }];
        }
        
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            
            [picker.pickerDelegate imagePickerController:picker didFinishPickingMediaWithInfo:array];
            
        });
    }
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
        return [_preViewItemArray count];
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
    HYAlbumItem *item = _browserType == HYAlbumPhotoBrowserTypeNormal ? [[HYImagePickerHelper sharedHelper].currentPhotos objectAtIndex:pageNum] : [_preViewItemArray objectAtIndex:pageNum];
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
    if (_browserType == HYAlbumPhotoBrowserTypeNormal)
    {
        [HYImagePickerHelper sharedHelper].currentShowItemIndex = pageNum;
    }
    
    HYAlbumItem *item = [self p_itemAtPageNum:pageNum];
    if ([[HYImagePickerHelper sharedHelper].selectedItems containsObject:item])
    {
        _rightSelectButton.selected = YES;
    }
    else
    {
        _rightSelectButton.selected = NO;
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

- (void)p_selectItem
{
    HYAlbumItem *item = [self p_itemAtPageNum:_nowPageNum];
    if ([[HYImagePickerHelper sharedHelper].selectedItems containsObject:item])
    {
        _rightSelectButton.selected = NO;
        [[HYImagePickerHelper sharedHelper] deleteSelectedItem:item];
    }
    else
    {
        _rightSelectButton.selected = [[HYImagePickerHelper sharedHelper] addSelectedItem:item];
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

#pragma mark selected items count changed

- (void)selectedItemsCountChanged:(NSNotification *)notification
{
    _selectNumBarButton.title = [NSString stringWithFormat:@"%ld/%ld", (unsigned long)[[HYImagePickerHelper sharedHelper].selectedItems count], (long)[HYImagePickerHelper sharedHelper].maxSelectedCountAllow];
    
    if ([[HYImagePickerHelper sharedHelper].selectedItems count] > 0)
    {
        _selectNumBarButton.enabled = YES;
        _doneBarButton.enabled = YES;
        //_previewBarButton.enabled = YES;
    }
    else
    {
        _selectNumBarButton.enabled = NO;
        _doneBarButton.enabled = NO;
        //_previewBarButton.enabled = NO;
    }
}


- (void)HYImagePickerZoomViewTapped:(HYImagePickerZoomView *)view
{
    if (self.navigationController.navigationBarHidden)
    {
        [self.navigationController setToolbarHidden:NO animated:YES];
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
    else
    {
        [self.navigationController setToolbarHidden:YES animated:YES];
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
}

@end










