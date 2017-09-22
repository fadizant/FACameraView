//
//  ImagesReview.m
//  FACameraView
//
//  Created by Fadi Abuzant on 9/22/17.
//

#import "ImagesReview.h"

@implementation ImagesReview

- (void)didMoveToSuperview{
    [super didMoveToSuperview];
    _scroll = [[UIScrollView alloc]initWithFrame:self.bounds];
    _scroll.pagingEnabled = YES;
    [self addSubview:_scroll];
    
    
    //The setup code (in viewDidLoad in your view controller)
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(OpenImage:)];
    [_scroll addGestureRecognizer:singleFingerTap];
}

//The event handling method
- (void)OpenImage:(UITapGestureRecognizer *)recognizer
{
    int page = _scroll.contentOffset.x / _scroll.frame.size.width;
    UIImageView *imageView = [_scroll viewWithTag:page+1];
    if (imageView && _tapToMaximize) {
        CGRect newFrame = [self convertRect:self.bounds toView:nil];
        newFrame.origin.x += 5;
        newFrame.size.width -=5;
        
        maximzedImage = [[UIImageView alloc]initWithFrame:newFrame];
        [maximzedImage setImage:imageView.image];
        
        UIScrollView* scrollView =[[UIScrollView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        [scrollView addSubview:maximzedImage];
        scrollView.contentSize = maximzedImage.frame.size;
        
        // Disabling panning/scrolling in the scrollView
        scrollView.scrollEnabled = NO;
        scrollView.bouncesZoom = NO;
        scrollView.bounces = NO;
        
        // For supporting zoom,
        scrollView.minimumZoomScale = 1.0;
        scrollView.maximumZoomScale = 4.0;
        
        //The setup code (in viewDidLoad in your view controller)
        UITapGestureRecognizer *singleFingerTap =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(CloseImage:)];
        [maximzedImage addGestureRecognizer:singleFingerTap];
        [maximzedImage setUserInteractionEnabled:YES];
        
        scrollView.delegate = self;
        
        [[UIApplication sharedApplication].keyWindow addSubview:scrollView];
        
        
        [UIView animateWithDuration:0.2
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^ {
                             maximzedImage.frame = [UIScreen mainScreen].bounds;
                         }completion:^(BOOL finished) {
                             maximzedImage.frame = [UIScreen mainScreen].bounds;
                         }];
    }
}

- (void)CloseImage:(UITapGestureRecognizer *)recognizer
{
    
    float animat = ((UIScrollView*)recognizer.view.superview).zoomScale > 1.0 ? 0.25 : 0;
    [((UIScrollView*)recognizer.view.superview) setZoomScale:1.0 animated:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, animat * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        CGRect newFrame = [self convertRect:self.bounds toView:nil];
        newFrame.origin.x += 5;
        newFrame.size.width -=5;
        [UIView animateWithDuration:0.25
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^ {
                             maximzedImage.frame = newFrame;
                         }completion:^(BOOL finished) {
                             [recognizer.view.superview removeFromSuperview];
                         }];
    });

    
}

// Implement a single scroll view delegate method
- (UIView*)viewForZoomingInScrollView:(UIScrollView *)aScrollView {
    return maximzedImage;
}

-(void)addImage:(FAImageLibraryItem*)image{
    if(!_attachments){
        _attachments = [NSMutableArray new];
    }
    [_attachments addObject:image];
    //    CGRect frame = CGRectMake((_attachments.count-1) *self.frame.size.width + 5 , 0, self.frame.size.width - 5, self.frame.size.height);
    //    UIImageView *imageView = [[UIImageView alloc]initWithFrame:frame];
    UIImageView *imageView = [UIImageView new];
    [imageView setImage:image.imageOrginal];
    imageView.tag = _attachments.count;
    [_scroll addSubview:imageView];
    _scroll.contentSize = CGSizeMake(_attachments.count *self.frame.size.width, self.frame.size.height);
    
    [self setConstraintsImage:imageView];
    
}

-(void)removeImage:(FAImageLibraryItem*)image{
    NSMutableArray<FAImageLibraryItem*>* newAttachments =  [[NSMutableArray alloc]initWithArray:_attachments];
    
    [newAttachments removeObject:image];
    [_attachments removeAllObjects];
    
    for (UIImageView *image in _scroll.subviews) {
        if (image.tag) {
            [image removeFromSuperview];
        }
    }
    
    for (FAImageLibraryItem *item in newAttachments) {
        [self addImage:item];
    }
    
}

-(void)setConstraintsImage:(UIImageView*)imageView{
    [imageView removeConstraints:imageView.constraints];
    [imageView updateConstraints];
    [_scroll updateConstraints];
    
    [imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    //x
    NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_scroll attribute:NSLayoutAttributeLeft multiplier:1 constant:(imageView.tag-1) *_scroll.frame.size.width + 5];
    //y
    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_scroll attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    //h
    NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:_scroll.frame.size.height];
    //w
    NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:_scroll.frame.size.width - 5];
    //set
    [_scroll addConstraints:@[left, top]];
    [imageView addConstraints:@[height, width]];
    
    [imageView updateConstraints];
    [_scroll updateConstraints];
}
@end
