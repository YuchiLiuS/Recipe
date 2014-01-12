//
//  SearchRecipeViewController.h
//  Recipe
//
//  Created by yuchiliu on 12/3/13.
//  Copyright (c) 2013 CS193P. All rights reserved.
//

#import "CoreDataTableViewController.h"
#import "RecipeCDTVC.h"

@interface SearchRecipeViewController : RecipeCDTVC <UISearchBarDelegate, UISearchDisplayDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
