//
//  CookStyleViewController.m
//  Recipe
//
//  Created by yuchiliu on 12/1/13.
//  Copyright (c) 2013 CS193P. All rights reserved.
//

#import "CookStyleViewController.h"
#import "CookStyle.h"
#import "RecipeDataBaseAvailability.h"
#import "RecipesByStyleCDTVC.h"
#import "CustomColoredAccessory.h"
@interface CookStyleViewController ()

@end

@implementation CookStyleViewController

- (void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserverForName:RecipeDatabaseAvailabilityNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      self.managedObjectContext = note.userInfo[RecipeDatabaseAvailabilityContext];
                                                  }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"CookBook";
}
- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CookStyle"];
    request.predicate = nil;
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name"
                                                              ascending:YES
                                                               selector:@selector(localizedStandardCompare:)]];
    
    
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CookStyle Cell"];
    
    CookStyle *cookStyle = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = cookStyle.name;
    cell.accessoryView = [CustomColoredAccessory accessoryWithColor:[UIColor blackColor]];
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
}

#pragma mark - Navigation

- (void)prepareViewController:(id)vc forSegue:(NSString *)segueIdentifer fromIndexPath:(NSIndexPath *)indexPath
{
    CookStyle *cookStyle = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if ([vc isKindOfClass:[RecipesByStyleCDTVC class]]) {
        RecipesByStyleCDTVC *recipecdtvc = (RecipesByStyleCDTVC *)vc;
        recipecdtvc.cookStyle = cookStyle;
    }
}

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

@end
