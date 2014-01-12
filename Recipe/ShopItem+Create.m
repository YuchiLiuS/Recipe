//
//  ShopItem+Create.m
//  Recipe
//
//  Created by yuchiliu on 12/5/13.
//  Copyright (c) 2013 CS193P. All rights reserved.
//

#import "ShopItem+Create.h"

@implementation ShopItem (Create)

+ (void)shopItemWithNamePlace:(NSString*)name buyPlace:(NSString*)buyPlace inManagedObjectContext:(NSManagedObjectContext *)context
{
    if ([name length]) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ShopItem"];
        request.predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
        
        NSError *error;
        NSArray *matches = [context executeFetchRequest:request error:&error];
        
        if (!matches || ([matches count] > 1)) {
            
        } else if (![matches count]) {
            ShopItem *shopitem = [NSEntityDescription insertNewObjectForEntityForName:@"ShopItem"
                                                      inManagedObjectContext:context];
            shopitem.name = name;
            shopitem.buyPlace = buyPlace;
        }
    }

}

@end
