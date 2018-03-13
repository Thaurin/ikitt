//
//  iKITTAppDelegate.m
//  iKITT
//
//  Created by ivo on 3/22/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "iKITTAppDelegate.h"
#import "MainViewController.h"
#import "Settings.h"

@implementation iKITTAppDelegate

@synthesize window;
@synthesize mainViewController;
@synthesize lastAcceleration;

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
	mainViewController.settings = [[Settings alloc] init];

	[UIAccelerometer sharedAccelerometer].delegate = self;
    [window addSubview:mainViewController.view];
    [window makeKeyAndVisible];
}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
	UIViewController *controller = (UIViewController *)mainViewController.kittViewController;
	if (controller.view.superview == nil) return;	// only respond if on voicebox screen

    if (self.lastAcceleration)
	{
        if (!histeresisExcited && L0AccelerationIsShaking(self.lastAcceleration, acceleration, 1.4))
		{
            histeresisExcited = YES;
			[mainViewController deviceIsShaking];
        }
		else if (histeresisExcited && !L0AccelerationIsShaking(self.lastAcceleration, acceleration, 0.4))
		{
            histeresisExcited = NO;
        }
    }
	
    self.lastAcceleration = acceleration;
}

- (void)dealloc {
    [mainViewController release];
	[lastAcceleration release];
    [window release];
    [super dealloc];
}


@end
