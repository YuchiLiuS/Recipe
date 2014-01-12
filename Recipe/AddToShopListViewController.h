//
//  AddToShopListViewController.h
//  Recipe
//
//  Created by yuchiliu on 12/5/13.
//  Copyright (c) 2013 CS193P. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddToShopListViewController : UITableViewController

@property (nonatomic, strong) NSArray *ingredients;
@property (nonatomic, strong) NSString *buyPlace;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@end
