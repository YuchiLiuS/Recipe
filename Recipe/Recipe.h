//
//  Recipe.h
//  Recipe
//
//  Created by yuchiliu on 12/5/13.
//  Copyright (c) 2013 CS193P. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CookStyle;

@interface Recipe : NSManagedObject

@property (nonatomic, retain) NSString * buyPlace;
@property (nonatomic, retain) NSString * difficulty;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSData * ingredients;
@property (nonatomic, retain) NSNumber * isfavorite;
@property (nonatomic, retain) NSDate * lastviewed;
@property (nonatomic, retain) NSString * preptime;
@property (nonatomic, retain) NSData * procedures;
@property (nonatomic, retain) NSData * thumbnailData;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * unique;
@property (nonatomic, retain) CookStyle *whichStyle;

@end
