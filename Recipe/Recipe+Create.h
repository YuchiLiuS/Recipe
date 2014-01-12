//
//  Recipe+Create.h
//  Recipe
//
//  Created by yuchiliu on 12/1/13.
//  Copyright (c) 2013 CS193P. All rights reserved.
//

#import "Recipe.h"

@interface Recipe (Create)

+ (Recipe *)recipeWithInfo:(NSDictionary *)recipeDictionary
        inManagedObjectContext:(NSManagedObjectContext *)context;

+ (void)loadRecipesFromArray:(NSArray *)recipes
         intoManagedObjectContext:(NSManagedObjectContext *)context;

@end
