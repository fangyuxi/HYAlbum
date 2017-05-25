//
//  HYViewController.m
//  HYAlbum
//
//  Created by fangyuxi on 04/18/2016.
//  Copyright (c) 2016 fangyuxi. All rights reserved.
//

#import "HYViewController.h"
#import "HYImagePickerViewController.h"

@interface HYViewController ()<HYImagePickerViewControllerDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    NSMutableArray *array;
}
@end

@implementation HYViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        HYImagePickerViewController *controller = [[HYImagePickerViewController alloc] initWithMaxSelectedAllow:9 andCompresstionLevel:0.8];
        controller.pickerDelegate = self;
        [self presentViewController:controller animated:YES completion:^{
            
        }];
//        UIImagePickerController *controller = [[UIImagePickerController alloc] init];
//        controller.delegate = self;
//        controller.allowsEditing = NO;
//        controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//        array = [NSMutableArray new];
//        [self presentViewController:controller animated:YES completion:^{
//            
//        }];
    });
}

//- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
//    UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
//    NSLog(@"%@", image);
//    [array addObject:image];
//}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

// TO DO
- (void)imagePickerController:(HYImagePickerViewController *)picker
didFinishPickingMediaWithInfo:(NSArray<UIImage *> *)info
{
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
