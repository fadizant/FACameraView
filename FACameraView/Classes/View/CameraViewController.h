//
//  CameraViewController.h
//  Photos_Framework_Example
//
//  Created by Fadi on 2/4/17.
//  Copyright © 2017 ArpitOnTheWay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LibraryImageCollectionViewCell.h"
#import "SHDCameraUtility.h"
#import "libraryCache.h"
#import "ImagesReview.h"

@interface CameraViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,SHDCameraUtilityDelegate,PHPhotoLibraryChangeObserver,libraryCacheDelegate>
{
    SHDCameraUtility *cameraUtility;
    BOOL firstRunComplete;
    libraryCache *imagesLibrary;
}
#pragma mark - Gallary
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *showButton;

@property (nonatomic) int max;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *gallaryHeightConstraint;

#pragma mark - Camera
@property (weak, nonatomic) IBOutlet UIView *cameraView;
@property (retain,nonatomic) UIImage *theImage;
@property (weak, nonatomic) IBOutlet UIButton *captureButton;
@property (weak, nonatomic) IBOutlet UISlider *zoomSlider;

#pragma mark - Close
@property (nonatomic, copy) void (^didDismiss)(NSMutableArray *images);
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;

@end
