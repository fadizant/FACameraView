//
//  CameraViewController.m
//  Photos_Framework_Example
//
//  Created by Fadi on 2/4/17.
//  Copyright © 2017 ArpitOnTheWay. All rights reserved.
//

#import "CameraViewController.h"

@interface CameraViewController ()

@end

@implementation CameraViewController

- (instancetype)init
{
    NSBundle *podBundle = [NSBundle bundleForClass:[CameraViewController class]];
    id data = [podBundle URLForResource:@"FACameraView" withExtension:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithURL:data];
    self = [[CameraViewController alloc]initWithNibName:@"CameraViewController" bundle:bundle];
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //camera
    cameraUtility = [[SHDCameraUtility alloc] initWithView:self.cameraView andDelegate:self];
    
    //register cell
    NSBundle *podBundle = [NSBundle bundleForClass:[LibraryImageCollectionViewCell class]];
    [_collectionView registerNib:[UINib nibWithNibName:@"LibraryImageCollectionViewCell" bundle:podBundle] forCellWithReuseIdentifier:@"LibraryImageCollectionViewCell"];
    [_collectionView setBounces:NO];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //captureButton style
    [_captureButton.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [_captureButton.layer setBorderWidth:3];
    [_captureButton.layer setCornerRadius:_captureButton.frame.size.height/2];
    
    //zoom slider style
    [_zoomSlider setThumbImage:[UIImage imageNamed:@"slider"] forState:UIControlStateNormal];
    
    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
        //get images
        [self getAllPhotos];
    } else {
        //request permissin
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {
                [PHPhotoLibrary.sharedPhotoLibrary registerChangeObserver:self];
            }
        }];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark: New Library
-(void)getAllPhotos{
    
    [libraryCache getAllPhotos:self];
}

- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    [self getAllPhotos];
}

-(void)update{
    [_collectionView reloadData];
    if (!firstRunComplete) {
        firstRunComplete = YES;
        [self.view layoutIfNeeded];
        _gallaryHeightConstraint.constant = 100;
        [UIView animateWithDuration:.5
                         animations:^{
                             [self.view layoutIfNeeded]; // Called on parent view
                             _showButton.selected = YES;
                         }];
    }
}

#pragma mark: Camera

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [cameraUtility finalizeLoadWithView:self.cameraView];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [cameraUtility selfDestruct];
    [libraryCache ClearDelegate];
}

- (void)cameraUtilityDidStartVideoOutput:(NSError *)error{
    
}
- (void)cameraUtilityDidTakePhoto:(UIImage *)photo{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.selected == %i", YES];
    NSArray *filteredArray = [[libraryCache Items] filteredArrayUsingPredicate:predicate];
    
    BOOL canSelect = _max ? filteredArray.count < _max : YES;
    
    FAImageLibraryItem *obj = [[FAImageLibraryItem alloc]init];
    obj.imageOrginal = photo;
    obj.selected = canSelect;
    
    //resize image
    UIGraphicsBeginImageContext(CGSizeMake(255,300));
    CGContextRef context = UIGraphicsGetCurrentContext();
    [photo drawInRect: CGRectMake(0, 0, 255, 300)];
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    obj.image = smallImage;
    
    [[libraryCache Items] insertObject:obj atIndex:0];
    [self.collectionView reloadData];
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
}

- (IBAction)flash:(UIButton *)sender {
    UIButton *button = sender;
    if (button.isSelected){
        button.selected = NO;
    }else{
        button.selected = YES;
    }
    [cameraUtility switchFlash];
}

- (IBAction)location:(UIButton *)sender {
    [cameraUtility switchCameraPosition];
}

- (IBAction)ImageFromCamera:(UIButton *)sender {
    [cameraUtility touchDown];
    [cameraUtility touchUp];
}

#pragma mark zoom

- (IBAction)zoomChange:(UISlider *)sender {
    [cameraUtility zoomTo:sender.value];
    [self hideShowZoomSlider:sender.value];
}

-(void)zoomChanged:(float)value{
    _zoomSlider.value = value;
    [self hideShowZoomSlider:value];
}

-(void)hideShowZoomSlider:(float)value{
    if (value > 1 ) {
        [UIView animateWithDuration:0.5 animations:^{
            _zoomSlider.alpha = 1;
        } completion: ^(BOOL finished) {
        }];
    } else if (value <= 1 ) {
        [UIView animateWithDuration:0.5 animations:^{
            _zoomSlider.alpha = 0;
        } completion: ^(BOOL finished) {
        }];
    }
}

#pragma mark: Collection View Data Source & Delegates


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [[libraryCache Items] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"LibraryImageCollectionViewCell";
    
    LibraryImageCollectionViewCell *cell=[self.collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (!cell)
    {
        cell = [[LibraryImageCollectionViewCell alloc]init];
    }
    
    [cell.imageView setImage:[[libraryCache Items] objectAtIndex:indexPath.row].image];
    
    [cell.selectImage setHidden:![[libraryCache Items] objectAtIndex:indexPath.row].selected];
    
    
    return  cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.selected == %i", YES];
    NSArray *filteredArray = [[libraryCache Items] filteredArrayUsingPredicate:predicate];
    
    if (filteredArray.count < _max || _max == 0 || [[libraryCache Items] objectAtIndex:indexPath.row].selected) {
        LibraryImageCollectionViewCell *cell= (LibraryImageCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
        
        [[libraryCache Items] objectAtIndex:indexPath.row].selected = ![[libraryCache Items] objectAtIndex:indexPath.row].selected;
        
        [cell.selectImage setHidden:![[libraryCache Items] objectAtIndex:indexPath.row].selected];
    }
    
    
    
}

- (IBAction)HideShowGallary:(UIButton *)sender {
    
    [self.view layoutIfNeeded];
    
    _gallaryHeightConstraint.constant = _gallaryHeightConstraint.constant ? 0 : 100;
    [UIView animateWithDuration:.5
                     animations:^{
                         [self.view layoutIfNeeded]; // Called on parent view
                         sender.selected = _gallaryHeightConstraint.constant > 0;
                     }];
    
}


- (IBAction)dismiss:(id)sender
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.selected == %i", YES];
    NSArray *filteredArray = [[libraryCache Items] filteredArrayUsingPredicate:predicate];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (self.didDismiss)
        self.didDismiss([[NSMutableArray alloc]initWithArray:filteredArray]);
}

- (IBAction)cancel:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}



@end
