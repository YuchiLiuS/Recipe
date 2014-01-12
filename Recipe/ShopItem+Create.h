//
//  ShopItem+Create.h
//  Recipe
//
//  Created by yuchiliu on 12/5/13.
//  Copyright (c) 2013 CS193P. All rights reserved.
//

#import "ShopItem.h"

@interface ShopItem (Create)

+ (void)shopItemWithNamePlace:(NSString*)name buyPlace:(NSString*)buyPlace inManagedObjectContext:(NSManagedObjectContext *)context;
@end
