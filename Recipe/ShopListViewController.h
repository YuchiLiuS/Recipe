//
//  ShopListViewController.h
//  Recipe
//
//  Created by yuchiliu on 12/5/13.
//  Copyright (c) 2013 CS193P. All rights reserved.
//

#import "CoreDataTableViewController.h"

@interface ShopListViewController : CoreDataTableViewController

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
