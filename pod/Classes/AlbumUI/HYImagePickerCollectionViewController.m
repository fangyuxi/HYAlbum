//
//  HYImagePickerCollectionViewController.m
//  Pods
//
//  Created by fangyuxi on 16/4/19.
//
//

#import "HYImagePickerCollectionViewController.h"
#import "HYImagePickerPhotoBrowserViewController.h"
#import "HYImagePickerCollectionCell.h"
#import "HYAlbum.h"
#import "HYAlbumItem.h"
#import "HYAlbumManager.h"
#import "HYImagePickerHelper.h"
#import "HYImagePickerViewController.h"
#import "HYImagePickerViewControllerPrivate.h"
#import "HYAlbumImageGenerator.h"

@interface HYImagePickerCollectionViewController ()<UICollectionViewDataSource,
                                                    UICollectionViewDelegate>
@property (nonatomic, strong) HYAlbum *album;
@property (nonatomic, strong) NSArray *photos;

@end

@implementation HYImagePickerCollectionViewController{

    UICollectionView *_collectionView;
    CGSize _itemSize;
    
    UIBarButtonItem *_selectNumBarButton;
    UIBarButtonItem *_previewBarButton;
    UIBarButtonItem *_doneBarButton;

}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [HYImagePickerHelper sharedHelper].currentShowItemIndex = -1;
    [HYImagePickerHelper sharedHelper].currentAlbumIndex = -1;
    [[HYImagePickerHelper sharedHelper] clearCurrentPhotos];
}

- (instancetype)initWithAlbum:(HYAlbum *)album
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(selectedItemsCountChanged:)
                                                    name:HYImagePickerSelectedCountChanged
                                                  object:nil];
        
        NSParameterAssert(album);
        self.album = album;
        return self;
    }
    return nil;
}

- (instancetype)init
{
    return [self initWithAlbum:nil];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return [self initWithAlbum:nil];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        return self;
    }
    return nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = self.album.albumTitle;
    
    [self p_createCollectionView];
    [self p_createToolBar];
    
    if (self.album.assets.count > 0) {
        ((HYImagePickerViewController *)self.navigationController).helper.currentPhotos = self.album.assets;
        [_collectionView reloadData];
    }else{
        [[HYAlbumManager sharedManager] getItemsInAlbum:self.album
                                             withResult:^(NSArray<HYAlbumItem *> *items,
                                                          NSError *error) {
                                                 ((HYImagePickerViewController *)self.navigationController).helper.currentPhotos = items;
                                                 [_collectionView reloadData];
                                             } byFilterType:HYAlbumFilterTypeImage];
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

- (void)p_createCollectionView
{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.minimumLineSpacing = 3;
    NSInteger size = [UIScreen mainScreen].bounds.size.width / 4 - 1;
    if (size % 2 != 0)
    {
        size -= 1;
    }
    _itemSize = CGSizeMake(size, size);
    flowLayout.itemSize = _itemSize;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
    _collectionView.bounces = YES;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = [UIColor whiteColor];
    [_collectionView registerClass:[HYImagePickerCollectionCell class]
        forCellWithReuseIdentifier:@"imagePickerCell"];
    [self.view addSubview:_collectionView];
}

- (void)p_createToolBar
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(p_cancel)];
    
    UIBarButtonItem *leftFix = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    UIBarButtonItem *rightFix = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    _previewBarButton = [[UIBarButtonItem alloc] initWithTitle:@"预览" style:UIBarButtonItemStylePlain target:self action:@selector(p_preview)];
    UIBarButtonItem *fix = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    _selectNumBarButton = [[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"%ld/%ld", (unsigned long)[[HYImagePickerHelper sharedHelper].selectedItems count], (long)[HYImagePickerHelper sharedHelper].maxSelectedCountAllow] style:UIBarButtonItemStylePlain target:nil action:nil];
    UIBarButtonItem *fix2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    _doneBarButton = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(p_choiceDone)];
    
    _selectNumBarButton.enabled = [[HYImagePickerHelper sharedHelper].selectedItems count] > 0 ? YES : NO;
    _doneBarButton.enabled = [[HYImagePickerHelper sharedHelper].selectedItems count] > 0 ? YES : NO;
    _previewBarButton.enabled = [[HYImagePickerHelper sharedHelper].selectedItems count] > 0 ? YES : NO;
    
    [self setToolbarItems:@[leftFix, _previewBarButton, fix, _selectNumBarButton, fix2, _doneBarButton, rightFix]];
    self.navigationController.toolbar.tintColor = [UIColor colorWithRed:255.0f / 255.0f green:99.0f / 255.0f blue:96.0f / 255.0f alpha:1];
}

#pragma mark collection view delegate datasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    return ((HYImagePickerViewController *)self.navigationController).helper.currentPhotoCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    HYImagePickerCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"imagePickerCell" forIndexPath:indexPath];
    cell.indexPath = indexPath;
    cell.tag = indexPath.item;
    
    HYAlbumItem *item = [((HYImagePickerViewController *)self.navigationController).helper.currentPhotos objectAtIndex:indexPath.item];
    
    if ([[HYImagePickerHelper sharedHelper].selectedItems containsObject:item]) {
        [cell selectCell];
    }
    else{
        [cell unSelectCell];
    }
    
    [item getThumbImageWithSize:_itemSize result:^(UIImage *image) {
       
        if (cell.indexPath == indexPath)
        {
            cell.imageView.image = image;
        }
    }];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView
            didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [HYImagePickerHelper sharedHelper].currentShowItemIndex = indexPath.item;
    HYImagePickerPhotoBrowserViewController *controller = [[HYImagePickerPhotoBrowserViewController alloc] initWithBrowserType:HYAlbumPhotoBrowserTypeNormal];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark selected items count changed

- (void)selectedItemsCountChanged:(NSNotification *)notification
{
    _selectNumBarButton.title = [NSString stringWithFormat:@"%ld/%ld", (unsigned long)[[HYImagePickerHelper sharedHelper].selectedItems count], (long)[HYImagePickerHelper sharedHelper].maxSelectedCountAllow];
    
    HYAlbumItem *item = notification.object;
    NSInteger indexPathItem = [[HYImagePickerHelper sharedHelper].currentPhotos indexOfObject:item];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:indexPathItem inSection:0];
    
    [_collectionView reloadItemsAtIndexPaths:@[indexPath]];
    
    if ([[HYImagePickerHelper sharedHelper].selectedItems count] > 0) {
        _selectNumBarButton.enabled = YES;
        _doneBarButton.enabled = YES;
        _previewBarButton.enabled = YES;
    }
    else{
        _selectNumBarButton.enabled = NO;
        _doneBarButton.enabled = NO;
        _previewBarButton.enabled = NO;
    }
}

#pragma mark bar button item

- (void)p_cancel
{
    [self dismissViewControllerAnimated:YES completion:^{
        
        HYImagePickerViewController *picker = (HYImagePickerViewController *)self.navigationController;
        if (picker.pickerDelegate && [picker.pickerDelegate respondsToSelector:@selector(imagePickerControllerDidCancel:)]) {
            
            [picker.pickerDelegate imagePickerControllerDidCancel:picker];
        }
    }];
}


- (void)p_preview
{
    HYImagePickerPhotoBrowserViewController *controller = [[HYImagePickerPhotoBrowserViewController alloc] initWithBrowserType:HYAlbumPhotoBrowserTypePreView];
    [self.navigationController pushViewController:controller animated:YES];
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


@end




