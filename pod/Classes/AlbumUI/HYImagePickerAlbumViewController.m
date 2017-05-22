//
//  HYImagePickerGroupListViewController.m
//  Pods
//
//  Created by fangyuxi on 16/4/19.
//
//

#import "HYImagePickerAlbumViewController.h"
#import "HYImagePickerViewController.h"
#import "HYImagePickerViewControllerPrivate.h"
#import "HYImagePickerHelper.h"
#import "HYAlbumManager.h"
#import "HYAlbum.h"

#import "HYImagePickerCollectionViewController.h"

@interface HYImagePickerAlbumViewController ()<UITableViewDelegate, UITableViewDataSource>

@end

@implementation HYImagePickerAlbumViewController{
    
    UITableView *_tableView;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.toolbarHidden = YES;
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    
    self.title = @"相册";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self p_configNavBar];
    [self p_createView];
    
    [[HYAlbumManager sharedManager] triggerAlbumAuthWithBlock:^(BOOL couldLoadAlbum) {
       
        if (couldLoadAlbum) {
            [[HYAlbumManager sharedManager] getAlbumListWithResult:^(NSArray<HYAlbum *> *albums, NSError *error) {
                
                ((HYImagePickerViewController *)self.navigationController).helper.albums = [[NSArray alloc] initWithArray:[[albums reverseObjectEnumerator] allObjects]];
                [_tableView reloadData];
                
            } byFilterType:HYAlbumFilterTypeImage];
        }
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(assetChanged:)
                                                 name:HYAlbumManagerAssetChanged
                                               object:nil];
}

- (void)p_createView
{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) style:UITableViewStylePlain];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _tableView.separatorColor = self.view.backgroundColor;
    [self.view addSubview:_tableView];
    
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
}

- (void)assetChanged:(NSNotification *)notificcation{
    [_tableView reloadData];
}

- (void)p_configNavBar
{
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(p_backAction)];
    self.navigationItem.rightBarButtonItem = back;
}

- (void)p_backAction
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
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
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"reuseIdentifier"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    HYAlbum *album = [((HYImagePickerViewController *)self.navigationController).helper.albums objectAtIndex:indexPath.row];

    [album getPosterThumbImageWithSize:CGSizeMake(80, 80) result:^(UIImage *image) {
       
        cell.imageView.image = image;
        [cell setNeedsLayout];
    }];
    
    cell.textLabel.text = album.albumTitle;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)album.count];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    HYAlbum *album = [((HYImagePickerViewController *)self.navigationController).helper.albums objectAtIndex:indexPath.row];
    
    ((HYImagePickerViewController *)self.navigationController).helper.currentAlbumIndex = indexPath.row;
    
    HYImagePickerCollectionViewController *controller = [[HYImagePickerCollectionViewController alloc] initWithAlbum:album];
    [self.navigationController pushViewController:controller animated:YES];
}


#pragma mark rotate

- (BOOL)shouldAutorotate
{
    return NO;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}


@end
