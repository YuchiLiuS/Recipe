//
//  CustomColoredAccessory.m
//  Recipe
//
//  Created by yuchiliu on 12/2/13.
//  Copyright (c) 2013 CS193P. All rights reserved.
//  Reference www.cocoanetics.com/2010/10/custom-colored-disclosure-indicators.
//

#import "CustomColoredAccessory.h"

@implementation CustomColoredAccessory

- (void)setup
{
    self.backgroundColor = nil;
    self.opaque = NO;
}

- (void)awakeFromNib
{
    [self setup];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

+ (CustomColoredAccessory *)accessoryWithColor:(UIColor *)color
{
	CustomColoredAccessory *cca = [[CustomColoredAccessory alloc] initWithFrame:CGRectMake(0, 0, 12.0, 15.0)];
	cca.accessoryColor = color;
    
	return cca;
}

- (void)drawRect:(CGRect)rect
{
	// (x,y) is the tip of the arrow
	CGFloat x = CGRectGetMaxX(self.bounds)-3.0;;
	CGFloat y = CGRectGetMidY(self.bounds);
	const CGFloat R = 4.5;
	CGContextRef ctxt = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctxt);
	CGContextMoveToPoint(ctxt, x-R, y-R);
	CGContextAddLineToPoint(ctxt, x, y);
	CGContextAddLineToPoint(ctxt, x-R, y+R);
	CGContextSetLineCap(ctxt, kCGLineCapSquare);
	CGContextSetLineJoin(ctxt, kCGLineJoinMiter);
	CGContextSetLineWidth(ctxt, 3);
    [self.accessoryColor setStroke];
	CGContextStrokePath(ctxt);
    CGContextRestoreGState(UIGraphicsGetCurrentContext());
}

- (UIColor *)accessoryColor
{
	if (!_accessoryColor)
	{
		return [UIColor blackColor];
	}
    
	return _accessoryColor;
}

@end
