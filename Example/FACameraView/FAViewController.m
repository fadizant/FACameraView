//
//  FAViewController.m
//  FACameraView
//
//  Created by fadizant on 09/21/2017.
//  Copyright (c) 2017 fadizant. All rights reserved.
//

#import "FAViewController.h"

@interface FAViewController ()

@end

@implementation FAViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)ShowComera:(UIButton *)sender {
    
//    NSBundle *podBundle = [NSBundle bundleForClass:[CameraViewController class]];
//    id data = [podBundle URLForResource:@"FACameraView" withExtension:@"bundle"];
//    NSBundle *bundle = [NSBundle bundleWithURL:data];
//    CameraViewController *cam = [[CameraViewController alloc]initWithNibName:@"CameraViewController" bundle:bundle];
    
    CameraViewController *cam = [CameraViewController new];
    cam.max = 3;
    cam.didDismiss = ^void(NSMutableArray<FAImageLibraryItem*>* images)
    {
        if (!attachments) {
            attachments = [[NSMutableArray alloc]init];
        }
        [attachments addObjectsFromArray:images];
        for (FAImageLibraryItem *item in images) {
            [_Review addImage:item];
        }
        [_removeButton setHidden:!attachments.count];
    };
    
    [self presentViewController:cam animated:YES completion:^{
    }];
}

- (IBAction)RemoveButton:(UIButton *)sender {
    int page = _Review.scroll.contentOffset.x / _Review.scroll.frame.size.width;
    [_Review removeImage:[attachments objectAtIndex:page]];
    [attachments removeObject:[attachments objectAtIndex:page]];
    [_removeButton setHidden:!attachments.count];
}

@end
