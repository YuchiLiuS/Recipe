//
//  RecentRecipeViewController.m
//  Recipe
//
//  Created by yuchiliu on 12/2/13.
//  Copyright (c) 2013 CS193P. All rights reserved.
//

#import "RecentRecipeViewController.h"
#import "RecipeDatabaseAvailability.h"
#import "Recipe+Create.h"
#import "RecipeViewController.h"

@interface RecentRecipeViewController ()

@end

@implementation RecentRecipeViewController

- (void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserverForName:RecipeDatabaseAvailabilityNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      self.managedObjectContext = note.userInfo[RecipeDatabaseAvailabilityContext];
                                                  }];
    self.title = @"Recent";
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    [self setupFetchedResultsController];
}


#define RECENTLIMIT 20

- (void)setupFetchedResultsController
{
    NSManagedObjectContext *context = self.managedObjectContext;
    
    if (context) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Recipe"];
        request.predicate = [NSPredicate predicateWithFormat:@"lastviewed != nil"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"lastviewed"
                                                                  ascending:NO]];
        request.fetchLimit = RECENTLIMIT;
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


@end
