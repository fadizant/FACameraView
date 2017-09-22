//
//  ImagesReview.h
//  FACameraView
//
//  Created by Fadi Abuzant on 9/22/17.
//

#import <UIKit/UIKit.h>
#import "FAImageLibraryItem.h"

//View IBInspectable property in UI
IB_DESIGNABLE

@interface ImagesReview : UIView<UIScrollViewDelegate>{
    
    UIImageView *maximzedImage;
}
/**
 * Enable click to full view
 */
@property (nonatomic) IBInspectable BOOL tapToMaximize;

@property (nonatomic,retain) NSMutableArray<FAImageLibraryItem*>* attachments;
@property (nonatomic,retain) UIScrollView *scroll;

-(void)addImage:(FAImageLibraryItem*)image;
-(void)removeImage:(FAImageLibraryItem*)image;
@end
