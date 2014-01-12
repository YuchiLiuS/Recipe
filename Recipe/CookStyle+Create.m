//
//  CookStyle+Create.m
//  Recipe
//
//  Created by yuchiliu on 12/1/13.
//  Copyright (c) 2013 CS193P. All rights reserved.
//

#import "CookStyle+Create.h"

@implementation CookStyle (Create)

+ (CookStyle *)cookStyleWithName:(NSString *)name
          inManagedObjectContext:(NSManagedObjectContext *)context
{
    CookStyle *cookstyle = nil;
    
    if ([name length]) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CookStyle"];
        request.predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
        
        NSError *error;
        NSArray *matches = [context executeFetchRequest:request error:&error];
        
        if (!matches || ([matches count] > 1)) {
            
        } else if (![matches count]) {
            cookstyle = [NSEntityDescription insertNewObjectForEntityForName:@"CookStyle"
                                                         inManagedObjectContext:context];
            cookstyle.name = name;
        } else {
            cookstyle = [matches lastObject];
        }
    }
    
    return cookstyle;
}
@end
