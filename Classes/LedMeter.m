//
//  LedMeter.m
//  iKITT
//
//  Created by ivo on 5/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "LedMeter.h"

#define kNumberOfLeds 12
#define kLedHeight 5
#define kLedSpacing 2

@implementation LedMeter

@synthesize value, minValue, maxValue;

- (void)setValue:(int)newValue
{
	if (newValue > maxValue) value = maxValue;
	else if (newValue < minValue) value = minValue;
	else value = newValue;

	[self setNeedsDisplay];
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
	{
		value = 0;
		minValue = 0;
		maxValue = 100;

		self.opaque = NO;
    }

    return self;
}

- (void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	int ledWidth = self.frame.size.width / (kNumberOfLeds + kLedSpacing);

	for (int i=0; i < kNumberOfLeds; i++)
	{
		int currentValue = (value * kNumberOfLeds) / maxValue;
		if (i < currentValue)
		{
			[[UIColor colorWithRed:0.18 green:0.55 blue:0.0 alpha:1.0] set];
		}
		else
		{
			[[UIColor colorWithRed:0.55 green:0.0 blue:0.0 alpha:1.0] set];
		}

		CGRect square = CGRectMake(i * (ledWidth + kLedSpacing), 0, ledWidth, kLedHeight);
		CGContextFillRect(context, square);
	}
}


- (void)dealloc
{
    [super dealloc];
}


@end
