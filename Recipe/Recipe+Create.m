//
//  Recipe+Create.m
//  Recipe
//
//  Created by yuchiliu on 12/1/13.
//  Copyright (c) 2013 CS193P. All rights reserved.
//

#import "Recipe+Create.h"
#import "RecipeFetcher.h"
#import "CookStyle+Create.h"

@implementation Recipe (Create)

+ (Recipe *)recipeWithInfo:(NSDictionary *)recipeDictionary
    inManagedObjectContext:(NSManagedObjectContext *)context
{
    Recipe *recipe = nil;
    
    NSString *unique = recipeDictionary[RECIPE_ID];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Recipe"];
    request.predicate = [NSPredicate predicateWithFormat:@"unique = %@", unique];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || ([matches count] > 1)) {
        // handle error
    } else if ([matches count]) {
        recipe = [matches firstObject];
    } else {
        recipe = [NSEntityDescription insertNewObjectForEntityForName:@"Recipe"
                                              inManagedObjectContext:context];
        recipe.unique = [recipeDictionary valueForKey:RECIPE_ID];
        recipe.title = [recipeDictionary valueForKeyPath:RECIPE_TITLE];
        recipe.preptime = [recipeDictionary valueForKeyPath:RECIPE_PREPTIME];
        recipe.imageURL = [recipeDictionary valueForKeyPath:RECIPE_IMAGEURL];
        recipe.ingredients = [NSKeyedArchiver archivedDataWithRootObject:[recipeDictionary valueForKeyPath:RECIPE_INGREDIENTS]];
        recipe.buyPlace = [recipeDictionary valueForKeyPath:RECIPE_BUYPLACE];
        recipe.procedures = [NSKeyedArchiver archivedDataWithRootObject:[recipeDictionary valueForKeyPath:RECIPE_PROCEDURES]];
        NSString *cookStyle = [recipeDictionary valueForKeyPath:RECIPE_COOKSTYLE];
        recipe.difficulty = [recipeDictionary valueForKey:RECIPE_DIFFICULTY];
        recipe.whichStyle = [CookStyle cookStyleWithName:cookStyle inManagedObjectContext:context];
        recipe.isfavorite = [NSNumber numberWithBool:NO];
    }
    return recipe;
}

+ (void)loadRecipesFromArray:(NSArray *)recipes
    intoManagedObjectContext:(NSManagedObjectContext *)context
{
    for (NSDictionary *recipe in recipes) {
        [self recipeWithInfo:recipe inManagedObjectContext:context];
    }
}

@end
