//
//  HYImagePickerGroupListViewController.m
//  Pods
//
//  Created by fangyuxi on 16/4/19.
//
//

#import "HYImagePickerAlbumViewController.h"
#import "HYImagePickerViewController.h"
#import "HYImagePickerHelper.h"
#import "HYAlbumManager.h"
#import "HYAlbum.h"

#import "HYImagePickerCollectionViewController.h"

//static const CGFloat HYImagePickerDefaultNavBarHeight = 120;

@interface HYImagePickerAlbumViewController ()<UITableViewDelegate, UITableViewDataSource>

@end

@implementation HYImagePickerAlbumViewController{
    
    UITableView *_tableView;

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title = @"相册";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configNavBar];
    
    [self createView];
    
    [[HYAlbumManager sharedManager] getAllAlbumListWithResult:^(NSArray<HYAlbum *> *albums, NSError *error) {
       
        ((HYImagePickerViewController *)self.navigationController).helper.albums = [[NSArray alloc] initWithArray:[[albums reverseObjectEnumerator] allObjects]];
        
        [_tableView reloadData];
    }];
}

- (void)createView
{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) style:UITableViewStylePlain];
    [self.view addSubview:_tableView];
    
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
}


- (void)configNavBar
{
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    self.navigationItem.rightBarButtonItem = cancel;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ((HYImagePickerViewController *)self.navigationController).helper.albumCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier"];
    if (cell==nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"reuseIdentifier"];
    }
    
    HYAlbum *album = [((HYImagePickerViewController *)self.navigationController).helper.albums objectAtIndex:indexPath.row];

    cell.imageView.image = album.albumPosterImage;
    cell.textLabel.text = album.albumTitle;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu张照片", (unsigned long)album.count];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    HYAlbum *album = [((HYImagePickerViewController *)self.navigationController).helper.albums objectAtIndex:indexPath.row];
    
    ((HYImagePickerViewController *)self.navigationController).helper.currentAlbumIndex = indexPath.row;
    
    HYImagePickerCollectionViewController *controller = [[HYImagePickerCollectionViewController alloc] initWithAlbum:album];
    [self.navigationController pushViewController:controller animated:YES];
}

@end
