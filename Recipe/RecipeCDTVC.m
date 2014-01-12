//
//  RecipeCDTVC.m
//  Recipe
//
//  Created by yuchiliu on 12/2/13.
//  Copyright (c) 2013 CS193P. All rights reserved.
//

#import "RecipeCDTVC.h"
#import "Recipe.h"
#import "RecipeViewController.h"

@interface RecipeCDTVC ()

@end

@implementation RecipeCDTVC

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Recipe Cell"];
    
    Recipe *recipe = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = recipe.title;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Difficulty Level:%@",recipe.difficulty];
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
}

#pragma mark - Navigation

- (void)prepareViewController:(id)vc
                     forSegue:(NSString *)segueIdentifer
                fromIndexPath:(NSIndexPath *)indexPath
{
    Recipe *recipe= [self.fetchedResultsController objectAtIndexPath:indexPath];
    recipe.lastviewed = [NSDate date];
    if ([vc isKindOfClass:[RecipeViewController class]]) {
        RecipeViewController *rvc = (RecipeViewController *)vc;
        rvc.recipe = recipe;
        rvc.title = recipe.title;
    }
}

// boilerplate
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = nil;
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        indexPath = [self.tableView indexPathForCell:sender];
    }
    [self prepareViewController:segue.destinationViewController
                       forSegue:segue.identifier
                  fromIndexPath:indexPath];
}

// boilerplate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id detailvc = [self.splitViewController.viewControllers lastObject];
    if ([detailvc isKindOfClass:[UINavigationController class]]) {
        detailvc = [((UINavigationController *)detailvc).viewControllers firstObject];
        [self prepareViewController:detailvc
                           forSegue:nil
                      fromIndexPath:indexPath];
    }
}



@end
