//
//  item.h
//  Photos_Framework_Example
//
//  Created by Fadi on 29/3/17.
//  Copyright © 2017 ArpitOnTheWay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FAImageLibraryItem : NSObject

@property (retain,nonatomic) NSString *ID;
@property (retain,nonatomic) UIImage *image;
@property (retain,nonatomic) UIImage *imageOrginal;
@property (retain,nonatomic) NSData *data;
@property (retain,nonatomic) NSURL *path;
@property (nonatomic) BOOL selected;

@end
