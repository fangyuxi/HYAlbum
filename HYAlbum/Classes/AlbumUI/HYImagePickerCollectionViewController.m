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
#import "HYAlbumImageGenerator.h"

@interface HYImagePickerCollectionViewController ()<UICollectionViewDataSource,
                                                    UICollectionViewDelegate>
@property (nonatomic, strong) HYAlbum *album;
@property (nonatomic, strong) NSArray *photos;

@end

@implementation HYImagePickerCollectionViewController{

    UICollectionView *_collectionView;
    CGSize _itemSize;

}

- (void)dealloc
{
    [HYImagePickerHelper sharedHelper].currentShowItem = -1;
    [HYImagePickerHelper sharedHelper].currentAlbumIndex = -1;
    [[HYImagePickerHelper sharedHelper] clearCurrentPhotos];
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
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_collectionView];
    
    [_collectionView registerClass:[HYImagePickerCollectionCell class] forCellWithReuseIdentifier:@"imagePickerCell"];
    
    [[HYAlbumManager sharedManager] getItemsInAlbum:self.album withResult:^(NSArray<HYAlbumItem *> *items, NSError *error) {
       
        ((HYImagePickerViewController *)self.navigationController).helper.currentPhotos = items;
        [_collectionView reloadData];
        
    }];
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
    cell.tag = indexPath.item;
    cell.imageView.image = nil;
    HYAlbumItem *item = [((HYImagePickerViewController *)self.navigationController).helper.currentPhotos objectAtIndex:indexPath.item];
    
    [item getThumbImageWithSize:_itemSize result:^(UIImage *image) {
       
        if (cell.tag == indexPath.item)
        {
            cell.imageView.image = image;
        }
    }];

    return cell;
}


@end
