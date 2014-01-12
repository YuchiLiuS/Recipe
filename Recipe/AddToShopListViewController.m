//
//  AddToShopListViewController.m
//  Recipe
//
//  Created by yuchiliu on 12/5/13.
//  Copyright (c) 2013 CS193P. All rights reserved.
//

#import "AddToShopListViewController.h"
#import "RecipeDataBaseAvailability.h"
#import "ShopItem+Create.h"
#import "ShopListViewController.h"

@interface AddToShopListViewController ()
@property (nonatomic, strong) NSMutableArray *selectedArray;
@end

@implementation AddToShopListViewController

#pragma mark - Lazy instantiation

-(NSMutableArray*)selectedArray
{
    if (!_selectedArray) {
        _selectedArray = [[NSMutableArray alloc] init];
    }
    return _selectedArray;
}

#pragma mark - LifeCycle
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Add To Shop List";
    self.selectedArray = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.ingredients count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Shop Item Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    NSString *ingredient = [[self.ingredients objectAtIndex:indexPath.row] objectForKey:@"Item"];
    cell.textLabel.text = ingredient;
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *ingredient = [[self.ingredients objectAtIndex:indexPath.row] objectForKey:@"Item"];
    if (cell.accessoryType == UITableViewCellAccessoryNone){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.selectedArray addObject:ingredient];
    }else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [self.selectedArray removeObject:ingredient];
    }
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Show Shop List"])
    {
        NSManagedObjectContext *context = self.managedObjectContext;
        if (context) {
            for (NSString *ingredientname in self.selectedArray ){
                [ShopItem shopItemWithNamePlace:ingredientname
                                       buyPlace:self.buyPlace
                         inManagedObjectContext:context];
            }
        }
        if ([segue.destinationViewController isKindOfClass:[ShopListViewController class]]) {
            ShopListViewController  *slvc = (ShopListViewController *)segue.destinationViewController;
            slvc.managedObjectContext = self.managedObjectContext;
        }
    }
}

@end
