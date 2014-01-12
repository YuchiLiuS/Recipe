//
//  Recipe Fetcher.h
//  Recipe
//
//  Created by yuchiliu on 12/1/13.
//  Copyright (c) 2013 CS193P. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecipeFetcher : NSObject

#define RESULTS_RECIPES @"Recipes"
#define RECIPE_ID @"recipeID"
#define RECIPE_TITLE @"title"
#define RECIPE_PREPTIME @"preptime"
#define RECIPE_IMAGEURL @"imageURL"
#define RECIPE_INGREDIENTS @"Ingredients"
#define RECIPE_INGREDIENT_ITEM @"Item"
#define RECIPE_INGREDIENT_QUANTITY @"Quantity"
#define RECIPE_BUYPLACE @"buyPlace"
#define RECIPE_COOKSTYLE @"cookstyle"
#define RECIPE_PROCEDURES @"Procedures"
#define RECIPE_DIFFICULTY @"difficulty"
+ (NSURL *)URLforRecipes;
@end
