//
//  libraryCache.m
//  Photos_Framework_Example
//
//  Created by Fadi on 3/4/17.
//  Copyright © 2017 ArpitOnTheWay. All rights reserved.
//

#import "libraryCache.h"
#import <CommonCrypto/CommonDigest.h>

@implementation libraryCache

static BOOL fetching;
static int numberOfImages;
static NSMutableArray <FAImageLibraryItem*>*items;
static id< libraryCacheDelegate> delegate;

+(NSMutableArray<FAImageLibraryItem*>*) Items{
    return items;
}


+(void)getAllPhotos:(id)_delegate
{
    delegate = _delegate;
    if (fetching) {
        if (items && numberOfImages == items.count) {
            for (FAImageLibraryItem *obj in items) {
                obj.selected = NO;
            }
            [self update];
            fetching = NO;
        }
        return;
    }
    fetching = YES;
    
    //New Thread
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0ul);
    dispatch_async(queue, ^{
        @try {
            //To Do in background
            PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
            requestOptions.resizeMode   = PHImageRequestOptionsResizeModeExact;
            requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
            requestOptions.synchronous = YES;
            PHFetchResult *result = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:nil];
            
            NSLog(@"%d",(int)result.count);
            numberOfImages = (int)result.count;
            
            if (items && (int)result.count == items.count) {
                for (FAImageLibraryItem *obj in items) {
                    obj.selected = NO;
                }
                [self update];
                return ;
            }
            
            items =[[NSMutableArray alloc]init];
            
            PHImageManager *manager = [PHImageManager defaultManager];
            
            for (PHAsset *asset in [[result objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, result.count)]] reverseObjectEnumerator] ) {
                
                [manager requestImageDataForAsset:asset
                                          options:requestOptions
                                    resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                                        @try {
                                            UIImage *image = [UIImage imageWithData:imageData];
                                            FAImageLibraryItem *obj = [[FAImageLibraryItem alloc]init];
                                            obj.ID = @"";
                                            obj.imageOrginal = image;
                                            obj.data = imageData;
                                            obj.path = [info valueForKey:@"PHImageFileURLKey"];
                                            obj.selected = NO;
                                            
                                            //resize image
                                            UIGraphicsBeginImageContext(CGSizeMake(255,300));
                                            CGContextRef context = UIGraphicsGetCurrentContext();
                                            [image drawInRect: CGRectMake(0, 0, 255, 300)];
                                            UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
                                            UIGraphicsEndImageContext();
                                            
                                            obj.image = smallImage;
                                            
                                            [items addObject:obj];
                                            
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                
                                                if(numberOfImages == items.count){
                                                    fetching = NO;
                                                }
                                                [self update];

                                                
                                            });
                                        } @catch (NSException *exception) {
                                            
                                        } @finally {
                                            
                                        }
                                    }];
            }
            
            
        } @catch (NSException *exception) {
            
        } @finally {
            
        }
    });
    
}

+(FAImageLibraryItem*)GetItemFromUrl:(NSURL*)url{
    __block FAImageLibraryItem *obj= [[FAImageLibraryItem alloc]init];
    
    if ([[url absoluteString] hasPrefix:@"/var"]) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        NSString *fileComponent = [url lastPathComponent];
        NSArray *currentDocumentDir = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *currentDocumentPath = [currentDocumentDir objectAtIndex: 0];
        NSString *rebasedFilePath = [currentDocumentPath stringByAppendingPathComponent:fileComponent];
        
        if ([fileManager fileExistsAtPath:rebasedFilePath]){
            obj.ID = @"";
            obj.data = [NSData dataWithContentsOfFile:rebasedFilePath];
            obj.imageOrginal = [UIImage imageWithContentsOfFile:rebasedFilePath];
            obj.path = [NSURL URLWithString:rebasedFilePath];
            obj.selected = NO;
            
            //resize image
            UIGraphicsBeginImageContext(CGSizeMake(255,300));
            CGContextRef context = UIGraphicsGetCurrentContext();
            [obj.imageOrginal drawInRect: CGRectMake(0, 0, 255, 300)];
            UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            obj.image = smallImage;
        }
        
    }
    else{
        PHFetchResult *result = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:nil];
        
        NSArray<PHAsset*>* images = [result objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, result.count)]];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"filename == %@", [url lastPathComponent]];
        NSArray *filteredArray = [images filteredArrayUsingPredicate:predicate];
        
        NSLog(@"%d",(int)filteredArray.count);
        
        PHAsset *asset = [filteredArray firstObject];
        
        if (asset != nil) {
            PHImageManager *imageManager = [PHImageManager defaultManager];
            PHImageRequestOptions *options = [[PHImageRequestOptions alloc]init];
            options.synchronous = YES;
            
            //        [imageManager requestImageDataForAsset:asset options:options resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
            //            NSLog(@"requestImageDataForAsset returned info(%@)", info);
            //            image = [UIImage imageWithData:[imageData copy]];
            //        }];
            
            [imageManager requestImageDataForAsset:asset
                                           options:options
                                     resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                                         @try {
                                             UIImage *image = [UIImage imageWithData:imageData];
                                             obj.ID = @"";
                                             obj.imageOrginal = image;
                                             obj.data = imageData;
                                             obj.path = [info valueForKey:@"PHImageFileURLKey"];
                                             obj.selected = NO;
                                             
                                             //resize image
                                             UIGraphicsBeginImageContext(CGSizeMake(255,300));
                                             CGContextRef context = UIGraphicsGetCurrentContext();
                                             [image drawInRect: CGRectMake(0, 0, 255, 300)];
                                             UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
                                             UIGraphicsEndImageContext();
                                             
                                             obj.image = smallImage;
                                             
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 
                                                 if(numberOfImages == items.count){
                                                     fetching = NO;
                                                 }
                                                 [self update];
                                                 
                                                 
                                             });
                                         } @catch (NSException *exception) {
                                             
                                         } @finally {
                                             
                                         }
                                     }];
        }
    }
    
    return obj;
}

+(void)update{
    dispatch_async(dispatch_get_main_queue(), ^{
        if([delegate respondsToSelector:@selector(update)])
        {
            [delegate update];
        }
    });

}

+(void)ClearDelegate{
    delegate = nil;
}



@end
