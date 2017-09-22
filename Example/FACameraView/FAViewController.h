//
//  FAViewController.h
//  FACameraView
//
//  Created by fadizant on 09/21/2017.
//  Copyright (c) 2017 fadizant. All rights reserved.
//

@import UIKit;
#import "CameraViewController.h"

@interface FAViewController : UIViewController{
    NSMutableArray<FAImageLibraryItem*>* attachments;
}


@property (weak, nonatomic) IBOutlet ImagesReview *Review;
@property (weak, nonatomic) IBOutlet UIButton *removeButton;

@end
