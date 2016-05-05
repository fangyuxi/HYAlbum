//
//  HYViewController.m
//  HYAlbum
//
//  Created by fangyuxi on 04/18/2016.
//  Copyright (c) 2016 fangyuxi. All rights reserved.
//

#import "HYViewController.h"
#import "HYImagePickerViewController.h"

@interface HYViewController ()

@end

@implementation HYViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        HYImagePickerViewController *controller = [[HYImagePickerViewController alloc] initWithMaxSelectedAllow:9];
        controller.pickerDelegate = self;
        [self presentViewController:controller animated:YES completion:^{
            
        }];
        
    });
    
}

- (void)imagePickerController:(HYImagePickerViewController *)picker
didFinishPickingMediaWithInfo:(NSArray<NSDictionary *> *)info
{
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
