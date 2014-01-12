//
//  CookStyle+Create.h
//  Recipe
//
//  Created by yuchiliu on 12/1/13.
//  Copyright (c) 2013 CS193P. All rights reserved.
//

#import "CookStyle.h"

@interface CookStyle (Create)

+ (CookStyle *)cookStyleWithName:(NSString *)name
                inManagedObjectContext:(NSManagedObjectContext *)context;

@end
