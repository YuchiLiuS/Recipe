//
//  FavoriteRecipeViewController.m
//  Recipe
//
//  Created by yuchiliu on 12/2/13.
//  Copyright (c) 2013 CS193P. All rights reserved.
//

#import "FavoriteRecipeViewController.h"
#import "RecipeDatabaseAvailability.h"
#import "Recipe+Create.h"
#import "RecipeViewController.h"

@interface FavoriteRecipeViewController ()

@end

@implementation FavoriteRecipeViewController

- (void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserverForName:RecipeDatabaseAvailabilityNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      self.managedObjectContext = note.userInfo[RecipeDatabaseAvailabilityContext];
                                                  }];
    self.title = @"Favorite";
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    [self setupFetchedResultsController];
}



- (void)setupFetchedResultsController
{
    NSManagedObjectContext *context = self.managedObjectContext;
    
    if (context) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Recipe"];
        request.predicate = [NSPredicate predicateWithFormat:@"isfavorite = 1"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"title"
                                                                  ascending:NO]];
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:context
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:nil];
    } else {
        self.fetchedResultsController = nil;
    }
}

- (void)prepareViewController:(id)vc
                     forSegue:(NSString *)segueIdentifer
                fromIndexPath:(NSIndexPath *)indexPath
{
    Recipe *recipe = [self.fetchedResultsController objectAtIndexPath:indexPath];
    recipe.lastviewed = [NSDate date];
    if ([vc isKindOfClass:[RecipeViewController class]]) {
        RecipeViewController *rvc = (RecipeViewController *)vc;
        rvc.recipe = recipe;
        rvc.title = recipe.title;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

//enables deleting favorite by swiping the tableview cell.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    Recipe *recipe = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if (editingStyle == UITableViewCellEditingStyleDelete){
        recipe.isfavorite = [NSNumber numberWithBool:NO];
    }
}

@end
