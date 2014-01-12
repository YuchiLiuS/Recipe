//
//  FavoriteRecipeViewController.h
//  Recipe
//
//  Created by yuchiliu on 12/2/13.
//  Copyright (c) 2013 CS193P. All rights reserved.
//

#import "RecipeCDTVC.h"

@interface FavoriteRecipeViewController : RecipeCDTVC

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
