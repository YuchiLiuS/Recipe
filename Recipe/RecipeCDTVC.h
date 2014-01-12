//
//  RecipeCDTVC.h
//  Recipe
//
//  Created by yuchiliu on 12/2/13.
//  Copyright (c) 2013 CS193P. All rights reserved.
//

#import "CoreDataTableViewController.h"

@interface RecipeCDTVC : CoreDataTableViewController

- (void)prepareViewController:(id)vc
                     forSegue:(NSString *)segueIdentifer
                fromIndexPath:(NSIndexPath *)indexPath;
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender;

@end
