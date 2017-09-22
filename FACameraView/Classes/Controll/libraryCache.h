//
//  libraryCache.h
//  Photos_Framework_Example
//
//  Created by Fadi on 3/4/17.
//  Copyright © 2017 ArpitOnTheWay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FAImageLibraryItem.h"

@import Photos;

@protocol libraryCacheDelegate <NSObject>
-(void)update;
@end

@interface libraryCache : NSObject


+(NSMutableArray<FAImageLibraryItem*>*) Items;
+(void)getAllPhotos:(id)_delegate;
+(void)ClearDelegate;
+(FAImageLibraryItem*)GetItemFromUrl:(NSURL*)url;

@end

