//
//  item.m
//  Photos_Framework_Example
//
//  Created by Fadi on 29/3/17.
//  Copyright © 2017 ArpitOnTheWay. All rights reserved.
//

#import "FAImageLibraryItem.h"

@implementation FAImageLibraryItem

-(NSString*)ID{
    if (!_ID) {
        return @"";
    }
    return _ID;
}
@end
