//
//  CustomAnnotation.h
//  Recipe
//
//  Created by yuchiliu on 12/4/13.
//  Copyright (c) 2013 CS193P. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface CustomAnnotation : MKPointAnnotation

@property (strong,nonatomic) MKMapItem *mapItem;

@end
