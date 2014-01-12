//
//  CustomColoredAccessory.h
//  Recipe
//
//  Created by yuchiliu on 12/2/13.
//  Copyright (c) 2013 CS193P. All rights reserved.
//  Reference www.cocoanetics.com/2010/10/custom-colored-disclosure-indicators.
//

#import <UIKit/UIKit.h>

@interface CustomColoredAccessory : UIControl

@property (nonatomic, retain) UIColor *accessoryColor;

+ (CustomColoredAccessory *)accessoryWithColor:(UIColor *)color;

@end
