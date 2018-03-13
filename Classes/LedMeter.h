//
//  LedMeter.h
//  iKITT
//
//  Created by ivo on 5/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LedMeter : UIView
{
	int value;
	int minValue;
	int maxValue;
}
@property (assign, readonly) int value;
@property (assign) int minValue;
@property (assign) int maxValue;

- (void)setValue:(int)newValue;

@end
