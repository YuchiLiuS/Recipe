//
//  SearchRecipeViewController.m
//  Recipe
//
//  Created by yuchiliu on 12/3/13.
//  Copyright (c) 2013 CS193P. All rights reserved.
//

#import "SearchRecipeViewController.h"
#import "RecipeDataBaseAvailability.h"
#import "RecipeViewController.h"

@interface SearchRecipeViewController ()

@end

@implementation SearchRecipeViewController


#pragma mark - filterSearch
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Recipe"];
    request.predicate = [NSPredicate predicateWithFormat:@"title contains[c] %@", searchText];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"title"
                                                             ascending:YES
                                                              selector:@selector(localizedStandardCompare:)]];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];

}

#pragma mark - UISearchDisplayController delegate methods
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller
shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.navigationController popToRootViewControllerAnimated:YES];
    self.fetchedResultsController = nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = nil;
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        indexPath = [self.searchDisplayController.searchResultsTableView indexPathForCell:sender];
    }
    [self prepareViewController:segue.destinationViewController
                       forSegue:segue.identifier
                  fromIndexPath:indexPath];
}
#pragma mark - View Controller Lifecycle
- (void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserverForName:RecipeDatabaseAvailabilityNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      self.managedObjectContext = note.userInfo[RecipeDatabaseAvailabilityContext];
                                                  }];
    self.title = @"Search";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.searchDisplayController.searchResultsTableView.backgroundColor = [UIColor colorWithRed:250/255.0 green:184/255.0 blue:117/255.0 alpha:1];
}
@end
