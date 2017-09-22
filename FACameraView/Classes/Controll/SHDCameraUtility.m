//
//  SHDCameraManager.m
//  CameraAppTemplate
//
//  Created by Sergey Grischyov on 07.03.16.
//  Copyright © 2016 ShadeApps. All rights reserved.
//

#import "SHDCameraUtility.h"
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreImage/CoreImage.h>
#import <UIKit/UIKitDefines.h>
#import <UIKit/UIColor.h>
#import <UIKit/UIGeometry.h>
#import "FBKCameraFocusSquare.h"

@interface SHDCameraUtility ()
@property (nonatomic, strong) UIView *videoLayerView;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;
@end

@implementation SHDCameraUtility{
    BOOL canSavePicture;
    BOOL flashIsOn;
    AVCaptureDeviceInput *currentInput;
    UIVisualEffectView *blurView;
    
    //foucs
    FBKCameraFocusSquare *camFocus;
}

#pragma mark - Lifecycle

- (instancetype)init{
    return [self initWithView:nil andDelegate:nil];
}

- (instancetype)initWithView:(UIView *)sourceView andDelegate:(id)delegate{
    if (self = [super init]){
        self.delegate = delegate;
        self.videoLayerView = sourceView;
        blurView = [self visualEffectsViewWithFrame:[[[UIApplication sharedApplication] delegate] window].bounds];
        [self.videoLayerView addSubview:blurView];
        [self setupSession];
    }
    
    return self;
}

- (void)selfDestruct{
    //Stop capture session
    [_captureSession stopRunning];
    _captureSession = nil;
}

#pragma mark - Internal methods

- (UIVisualEffectView *)visualEffectsViewWithFrame:(CGRect)frame{
    UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *newView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    newView.frame = frame;
    return newView;
}

- (void)setupSession{
    //Capture Session
    _captureSession = [[AVCaptureSession alloc]init];
    _captureSession.sessionPreset = AVCaptureSessionPresetPhoto;
    
    //Input
    currentInput = [AVCaptureDeviceInput deviceInputWithDevice:[self rearCamera] error:nil];
    if (!currentInput){
        if ([self.delegate respondsToSelector:@selector(cameraUtilityDidStartVideoOutput:)]){
            [self.delegate cameraUtilityDidStartVideoOutput:[NSError errorWithDomain:@"SHDCameraError" code:404 userInfo:@{@"description" : @"Couldn't locate camera, you might need to enable camera access in iOS privacy settings for this app."}]];
        }
        return;
    }
    
    [_captureSession addInput:currentInput];
    
    //Output
    _stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [_stillImageOutput setOutputSettings:outputSettings];
    [_captureSession addOutput:_stillImageOutput];
    
    //Preview Layer
    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    _videoPreviewLayer.frame = _videoLayerView.bounds;
    _videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.videoLayerView.layer insertSublayer:_videoPreviewLayer atIndex:0];
    
    //Start capture session
    [_captureSession startRunning];
    
    //setup foucs
    [self Foucs];
    
    //setup zoom
    [self zoom];
}

- (AVCaptureDevice *)frontCamera{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == AVCaptureDevicePositionFront) return device;
    }
    return nil;
}

- (AVCaptureDevice *)rearCamera{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == AVCaptureDevicePositionBack) return device;
    }
    return nil;
}

- (void)captureImage{
    [self blinkScreen];
    UIDeviceOrientation currentDeviceOrientation = UIDevice.currentDevice.orientation;
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in _stillImageOutput.connections)
    {
        for (AVCaptureInputPort *port in [connection inputPorts])
        {
            if ([[port mediaType] isEqual:AVMediaTypeVideo])
            {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) { break; }
    }
    
    [_stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error){
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
        if (!imageData){
            //Error here! (wow!)
            return;
        }
        
        UIImage *resultingImage = [UIImage imageWithData:imageData];
        resultingImage = [UIImage imageWithCGImage:[resultingImage CGImage] scale:[resultingImage scale] orientation:[self rotationNeededForImageCapturedWithDeviceOrientation:currentDeviceOrientation]];
        //Save picture here (delegate)
        if ([self.delegate respondsToSelector:@selector(cameraUtilityDidTakePhoto:)]){
            [self.delegate cameraUtilityDidTakePhoto:resultingImage];
        }
    }];
}

- (void)hideBlurViewAnimated:(BOOL)animated{
    CGFloat duration = 0.0;
    if (animated) duration = 1.0;
    
    [UIView animateWithDuration:duration animations:^{
        blurView.alpha = 0.0;
    }completion:^(BOOL finished){
        [blurView removeFromSuperview];
        blurView.alpha = 1.0;
    }];
}

- (void)blinkScreen{
    UIView *wholeWhiteView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
    wholeWhiteView.backgroundColor = [UIColor whiteColor];
    [[UIApplication sharedApplication].keyWindow addSubview:wholeWhiteView];
    
    [UIView animateWithDuration:0.2 animations:^{
        wholeWhiteView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [wholeWhiteView removeFromSuperview];
    }];
}

#pragma mark - External methods

-(void)finalizeLoadWithView:(UIView *)sourceView{
    _videoPreviewLayer.frame = sourceView.bounds;
    _videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self hideBlurViewAnimated:YES];
}

- (void)switchCameraPosition{
    [self.videoLayerView addSubview:blurView];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        AVCaptureDevice *desiredDevice = (currentInput.device.position == AVCaptureDevicePositionBack) ? [self frontCamera] : [self rearCamera];
        [self.captureSession beginConfiguration];
        currentInput = [AVCaptureDeviceInput deviceInputWithDevice:desiredDevice error:nil];
        if (currentInput){
            for (AVCaptureInput *oldInput in self.captureSession.inputs){
                [self.captureSession removeInput:oldInput];
            }
            [self.captureSession addInput:currentInput];
            [self.captureSession commitConfiguration];
        }else{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if ([self.delegate respondsToSelector:@selector(cameraUtilityDidStartVideoOutput:)]){
                    [self.delegate cameraUtilityDidStartVideoOutput:[NSError errorWithDomain:@"SHDCameraError" code:404 userInfo:@{@"description" : @"Couldn't locate camera, you might need to enable camera access in iOS privacy settings for this app."}]];
                }
            });
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self hideBlurViewAnimated:YES];
        });
    });
}

- (void)switchFlash{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasTorch]){
        [device lockForConfiguration:nil];
        if (flashIsOn) {
            flashIsOn = NO;
            [device setTorchMode:AVCaptureTorchModeOff];
        }else{
            flashIsOn = YES;
            [device setTorchMode:AVCaptureTorchModeOn];
        }
        [device unlockForConfiguration];
    }
}

- (void)touchDown{
    canSavePicture = YES;
}

- (void)touchUp{
    if (canSavePicture){
        canSavePicture = NO;
        [self captureImage];
    }
}

// return the UIImageOrientation needed for an image captured with a specific deviceOrientation
- (UIImageOrientation)rotationNeededForImageCapturedWithDeviceOrientation:(UIDeviceOrientation)deviceOrientation{
    UIImageOrientation rotationOrientation;
    switch (deviceOrientation) {
        case UIDeviceOrientationPortraitUpsideDown: {
            rotationOrientation = UIImageOrientationLeft;
        } break;
            
        case UIDeviceOrientationLandscapeRight: {
            rotationOrientation = UIImageOrientationDown;
        } break;
            
        case UIDeviceOrientationLandscapeLeft: {
            rotationOrientation = UIImageOrientationUp;
        } break;
            
        case UIDeviceOrientationPortrait:
        default: {
            rotationOrientation = UIImageOrientationRight;
        } break;
    }
    return rotationOrientation;
}

#pragma mark - foucs

-(void)Foucs{
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToFocus:)];
    [tapGR setNumberOfTapsRequired:1];
    [tapGR setNumberOfTouchesRequired:1];
    [self.videoLayerView addGestureRecognizer:tapGR];
    
}

-(void)tapToFocus:(UITapGestureRecognizer *)singleTap{
    CGPoint touchPoint = [singleTap locationInView:self.videoLayerView];
    
    [self focus:touchPoint];
    
    if (camFocus)
    {
        [camFocus removeFromSuperview];
    }
    camFocus = [[FBKCameraFocusSquare alloc]initWithFrame:CGRectMake(touchPoint.x-40, touchPoint.y-40, 80, 80)];
    [camFocus setBackgroundColor:[UIColor clearColor]];
    [self.videoLayerView addSubview:camFocus];
    [camFocus setNeedsDisplay];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:1.5];
    [camFocus setAlpha:0.0];
    [UIView commitAnimations];
    
}


- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchPoint = [touch locationInView:touch.view];
    [self focus:touchPoint];
    
    if (camFocus)
    {
        [camFocus removeFromSuperview];
    }
    if ([[touch view] isKindOfClass:[AVCaptureVideoPreviewLayer class]])
    {
        camFocus = [[FBKCameraFocusSquare alloc]initWithFrame:CGRectMake(touchPoint.x-40, touchPoint.y-40, 80, 80)];
        [camFocus setBackgroundColor:[UIColor clearColor]];
        [self.videoLayerView addSubview:camFocus];
        [camFocus setNeedsDisplay];
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:1.5];
        [camFocus setAlpha:0.0];
        [UIView commitAnimations];
    }
}

- (void) focus:(CGPoint) aPoint;
{
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil) {
        AVCaptureDevice *device = [captureDeviceClass defaultDeviceWithMediaType:AVMediaTypeVideo];
        if([device isFocusPointOfInterestSupported] &&
           [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            CGRect screenRect = [[UIScreen mainScreen] bounds];
            double screenWidth = screenRect.size.width;
            double screenHeight = screenRect.size.height;
            double focus_x = aPoint.x/screenWidth;
            double focus_y = aPoint.y/screenHeight;
            if([device lockForConfiguration:nil]) {
                [device setFocusPointOfInterest:CGPointMake(focus_x,focus_y)];
                [device setFocusMode:AVCaptureFocusModeAutoFocus];
                if ([device isExposureModeSupported:AVCaptureExposureModeAutoExpose]){
                    [device setExposureMode:AVCaptureExposureModeAutoExpose];
                }
                [device unlockForConfiguration];
            }
        }
    }
}
#pragma mark - Zoom
-(void)zoom{
    UIPinchGestureRecognizer *tapGR = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchToZoomRecognizer:)];
    [self.videoLayerView addGestureRecognizer:tapGR];
    
}

-(void) handlePinchToZoomRecognizer:(UIPinchGestureRecognizer*)pinchRecognizer {
    const CGFloat pinchVelocityDividerFactor = 10.0f;
    
    if (pinchRecognizer.state == UIGestureRecognizerStateChanged) {
        NSError *error = nil;
        Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
        if (captureDeviceClass != nil) {
            AVCaptureDevice *videoDevice = [captureDeviceClass defaultDeviceWithMediaType:AVMediaTypeVideo];
            if ([videoDevice lockForConfiguration:&error]) {
                CGFloat desiredZoomFactor = videoDevice.videoZoomFactor + atan2f(pinchRecognizer.velocity, pinchVelocityDividerFactor);
                // Check if desiredZoomFactor fits required range from 1.0 to activeFormat.videoMaxZoomFactor
                if (desiredZoomFactor < 10) {
                    videoDevice.videoZoomFactor = MAX(1.0, MIN(desiredZoomFactor, videoDevice.activeFormat.videoMaxZoomFactor));
                    [videoDevice unlockForConfiguration];
//                    NSLog(@"ZOOM = %f",desiredZoomFactor);
//                    NSLog(@"Value = %f",atan2f(pinchRecognizer.velocity, pinchVelocityDividerFactor));
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if([self.delegate respondsToSelector:@selector(zoomChanged:)])
                        {
                            [self.delegate zoomChanged:desiredZoomFactor];
                        }
                    });
                }
                
            } else {
                NSLog(@"error: %@", error);
            }
        }
    }
}

-(void)zoomTo:(float)value
{
    NSError *error = nil;
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil) {
        AVCaptureDevice *videoDevice = [captureDeviceClass defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([videoDevice lockForConfiguration:&error]) {
            CGFloat desiredZoomFactor = value;
            // Check if desiredZoomFactor fits required range from 1.0 to activeFormat.videoMaxZoomFactor
            videoDevice.videoZoomFactor = MAX(1.0, MIN(desiredZoomFactor, videoDevice.activeFormat.videoMaxZoomFactor));
            [videoDevice unlockForConfiguration];
        } else {
            NSLog(@"error: %@", error);
        }
    }
}
@end
