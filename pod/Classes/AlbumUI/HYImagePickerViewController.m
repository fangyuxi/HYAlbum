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
#import "HYImagePickerViewControllerPrivate.h"

NSString *const HYImagePickerFullScreenImageKey = @"HYImagePickerFullScreenImageKey";
NSString *const HYImagePickerFullResolutImagePathKey = @"HYImagePickerFullResolutImagePathKey";

@interface HYImagePickerViewController ()

- (instancetype)initWithRootViewController:(UIViewController  * __nullable)rootViewController;

@end

@implementation HYImagePickerViewController{

    NSInteger _maxSelectedAlow;
    CGFloat _compresstionLevel;
}

- (void)dealloc
{
    [[HYImagePickerHelper sharedHelper] clearAlbums];
    [[HYImagePickerHelper sharedHelper] removeAllSelected];
    [[HYAlbumImageGenerator sharedGenerator] clearMemory];
}

- (instancetype)init
{
    _maxSelectedAlow = 9;
    _compresstionLevel = 0.9;
    return [self initWithRootViewController:[[HYImagePickerAlbumViewController alloc] init]];
}

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super initWithRootViewController:[[HYImagePickerAlbumViewController alloc] init]];
    if (self)
    {
        self.helper = [HYImagePickerHelper sharedHelper];
        self.helper.maxSelectedCountAllow = _maxSelectedAlow;
        self.helper.compresstionLevel = _compresstionLevel;
        return self;
    }
    return nil;
}

- (instancetype)initWithMaxSelectedAllow:(NSInteger)maxSelectedAlow
                    andCompresstionLevel:(CGFloat)level
{
    _maxSelectedAlow = maxSelectedAlow;
    _compresstionLevel = (level < 0 || level > 1) ? 0.9 : level;
    return [self initWithRootViewController:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationBar.translucent = YES;
    self.navigationBar.tintColor = [UIColor whiteColor];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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









