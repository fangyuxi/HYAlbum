//
//  HYImagePickerCollectionViewController.m
//  Pods
//
//  Created by fangyuxi on 16/4/19.
//
//

#import "HYImagePickerCollectionViewController.h"
#import "HYImagePickerCollectionCell.h"
#import "HYAlbum.h"
#import "HYAlbumItem.h"
#import "HYAlbumManager.h"
#import "HYImagePickerHelper.h"
#import "HYImagePickerViewController.h"

@interface HYImagePickerCollectionViewController ()<UICollectionViewDataSource,
                                                    UICollectionViewDelegate>
@property (nonatomic, strong) HYAlbum *album;
@property (nonatomic, strong) NSArray *photos;

@end

@implementation HYImagePickerCollectionViewController{

    UICollectionView *_collectionView;

}

- (instancetype)initWithAlbum:(HYAlbum *)album
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = self.album.albumTitle;
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.minimumLineSpacing = 0;
    NSInteger size = [UIScreen mainScreen].bounds.size.width / 4;
    flowLayout.itemSize = CGSizeMake(size, size);
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
    _collectionView.contentInset = UIEdgeInsetsMake(0, 0, 64, 0);
    _collectionView.scrollIndicatorInsets = _collectionView.contentInset;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_collectionView];
    
    [_collectionView registerClass:[HYImagePickerCollectionCell class] forCellWithReuseIdentifier:@"imagePickerCell"];
    
    [[HYAlbumManager sharedManager] getItemsInAlbum:self.album withResult:^(NSArray<HYAlbumItem *> *items, NSError *error) {
       
        ((HYImagePickerViewController *)self.navigationController).helper.currentPhotos = items;
        [_collectionView reloadData];
        
    }];
//    [ASSETHELPER getPhotoListOfGroupByIndex:ASSETHELPER.currentGroupIndex result:^(NSArray *r) {
//        [[JFImageManager sharedManager] startCahcePhotoThumbWithSize:CGSizeMake(size, size)];
//        [photosList reloadData];
//        if (ASSETHELPER.previewIndex>=0) {
//            JFPhotoBrowserViewController *photoBrowser = [[JFPhotoBrowserViewController alloc] initWithPreview];
//            photoBrowser.delegate = self.navigationController;
//            [self.navigationController pushViewController:photoBrowser animated:YES];
//        }
//        
//        for (NSDictionary *dict in ASSETHELPER.selectdPhotos) {
//            NSArray *temp = [[[dict allKeys] firstObject] componentsSeparatedByString:@"-"];
//            NSInteger row = [temp[0] integerValue];
//            NSInteger group = [temp[1] integerValue];
//            if (group==ASSETHELPER.currentGroupIndex) {
//                [photosList scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
//                break;
//            }
//        }
//    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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
    //cell.indexPath = indexPath;
    //cell.tag = indexPath.item;
    HYAlbumItem *item = [((HYImagePickerViewController *)self.navigationController).helper.currentPhotos objectAtIndex:indexPath.item];
    cell.imageView.image = item.thumbImage;
    
//    [[JFImageManager sharedManager] thumbWithAsset:asset resultHandler:^(UIImage *result) {
//        if (cell.tag==indexPath.item) {
//            cell.imageView.image = result;
//        }
//    }];
    return cell;
}


@end
