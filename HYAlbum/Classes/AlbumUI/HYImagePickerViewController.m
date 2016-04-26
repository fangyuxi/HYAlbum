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

@interface HYImagePickerViewController ()

@property (nonatomic, strong, readwrite) HYImagePickerHelper *helper;

@end

@implementation HYImagePickerViewController

- (void)dealloc
{
    [[HYImagePickerHelper sharedHelper] clearAlbums];
}

- (instancetype)init
{
    return [self initWithRootViewController:[HYImagePickerAlbumViewController new]];
}

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super initWithRootViewController:[HYImagePickerAlbumViewController new]];
    if (self)
    {
        return self;
    }
    return nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.helper = [HYImagePickerHelper sharedHelper];
    
    self.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationBar.translucent = YES;
    self.navigationBar.tintColor = [UIColor whiteColor];
}

@end
