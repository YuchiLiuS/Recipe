//
//  Recipe Fetcher.m
//  Recipe
//
//  Created by yuchiliu on 12/1/13.
//  Copyright (c) 2013 CS193P. All rights reserved.
//

#import "RecipeFetcher.h"

@implementation RecipeFetcher

#define getDataURL @"http://www.stanford.edu/~yuchiliu/cgi-bin/193Base/fetchbook.php"

+ (NSURL *)URLforRecipes
{
    NSURL * url = [NSURL URLWithString:getDataURL];
    return url;
}

@end
