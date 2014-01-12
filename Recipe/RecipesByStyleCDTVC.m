//
//  RecipesByStyleCDTVC.m
//  Recipe
//
//  Created by yuchiliu on 12/1/13.
//  Copyright (c) 2013 CS193P. All rights reserved.
//

#import "RecipesByStyleCDTVC.h"

@interface RecipesByStyleCDTVC ()

@end

@implementation RecipesByStyleCDTVC

- (void)setCookStyle:(CookStyle *)cookStyle
{
    _cookStyle = cookStyle;
    self.title = cookStyle.name;
    [self setupFetchedResultsController];
}

- (void)setupFetchedResultsController
{
    NSManagedObjectContext *context = self.cookStyle.managedObjectContext;
    
    if (context) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Recipe"];
        request.predicate = [NSPredicate predicateWithFormat:@"whichStyle = %@", self.cookStyle];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"title"
                                                                  ascending:YES
                                                                   selector:@selector(localizedStandardCompare:)]];
        
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:context
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:nil];
    } else {
        self.fetchedResultsController = nil;
    }
}

@end
