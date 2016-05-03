//
//  HYImagePickerViewController.m
//  Pods
//
//  Created by fangyuxi on 16/4/19.
//
//

#import "HYImagePickerViewController.h"
#import "HYImagePickerAlbumViewController.h"
#import "HYImagePickerHelper.h"
#import "HYAlbumImageGenerator.h"

@interface HYImagePickerViewController ()

@property (nonatomic, strong, readwrite) HYImagePickerHelper *helper;

@end

@implementation HYImagePickerViewController{

    NSInteger _maxSelectedAlow;
}

- (void)dealloc
{
    [[HYImagePickerHelper sharedHelper] clearAlbums];
    [[HYImagePickerHelper sharedHelper] removeAllSelected];
    [[HYAlbumImageGenerator sharedGenerator] clearMemory];
}

- (instancetype)init
{
    return [self initWithRootViewController:[[HYImagePickerAlbumViewController alloc] init]];
}

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super initWithRootViewController:[[HYImagePickerAlbumViewController alloc] init]];
    if (self)
    {
        _maxSelectedAlow = 9;
        return self;
    }
    return nil;
}

- (instancetype)initWithMaxSelectedAllow:(NSInteger)maxSelectedAlow
{
    self = [super initWithRootViewController:[[HYImagePickerAlbumViewController alloc] init]];
    if (self)
    {
        _maxSelectedAlow = maxSelectedAlow;
        return self;
    }
    return nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.helper = [HYImagePickerHelper sharedHelper];
    self.helper.maxSelectedCountAllow = 9;
    
    self.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationBar.translucent = YES;
    self.navigationBar.tintColor = [UIColor whiteColor];
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
