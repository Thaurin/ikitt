//
//  MainViewController.m
//  iKITT
//
//  Created by ivo on 4/9/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Settings.h"
#import "MainViewController.h"
#import "KittViewController.h"
#import "DashViewController.h"
#import "InfoViewController.h"

@implementation MainViewController
@synthesize settings;
@synthesize kittViewController;
@synthesize dashViewController;
@synthesize infoViewController;
@synthesize settingsController;

- (void)viewDidLoad
{
	[super viewDidLoad];
	KittViewController *viewController =
		[[KittViewController alloc] initWithNibName:@"KittViewController" bundle:nil];
	self.kittViewController = viewController;
	[self.view insertSubview:self.kittViewController.view atIndex:0];
	[viewController release];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(infoButtonPressed) name:@"FlipInfo" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingsButtonPressed) name:@"FlipConfig" object:nil];
}

- (void)willAnimateFirstHalfOfRotationToInterfaceOrientation:
(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	switch (toInterfaceOrientation)
	{
		case UIInterfaceOrientationPortrait:
			[dashViewController.view removeFromSuperview];
			if (kittViewController == nil)
			{
				KittViewController *viewController =
				[[KittViewController alloc] initWithNibName:@"KittViewController" bundle:nil];
				self.kittViewController = viewController;
				[viewController release];
			}

			[kittViewController resetButtons];
			[self.view insertSubview:kittViewController.view atIndex:0];
			[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
			break;
		case UIInterfaceOrientationLandscapeLeft:
		case UIInterfaceOrientationLandscapeRight:
			[kittViewController.view removeFromSuperview];
			if (dashViewController == nil)
			{
				DashViewController *viewController =
					[[DashViewController alloc] initWithNibName:@"DashViewController" bundle:nil];
				self.dashViewController = viewController;
				[viewController release];
			}
			[self.view insertSubview:self.dashViewController.view atIndex:0];

			[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
			break;
		default:
			break;
	}
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// return YES;
	return (interfaceOrientation == UIInterfaceOrientationPortrait ||
			interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
			interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (void)infoButtonPressed
{
	if (infoViewController == nil)
	{
		InfoViewController *viewController =
		[[InfoViewController alloc] initWithNibName:@"InfoViewController" bundle:nil];
		self.infoViewController = viewController;
		[viewController release];
	}

	[UIView beginAnimations:@"InfoViewFlip" context:nil];
	[UIView setAnimationDuration:.50];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	
	UIViewController *coming = nil;
	UIViewController *going = nil;
	UIViewAnimationTransition transition;
	
	BOOL toInfo = (self.infoViewController.view.superview == nil);
	coming = toInfo ? (UIViewController *)self.infoViewController : (UIViewController *)self.kittViewController;
	going = toInfo ? (UIViewController *)self.kittViewController : (UIViewController *)self.infoViewController;
	transition = toInfo ? UIViewAnimationTransitionFlipFromLeft : UIViewAnimationTransitionFlipFromRight;

	[UIView setAnimationTransition:transition forView:self.view cache:YES];
	
	[coming viewWillAppear:YES];
	[going viewWillDisappear:YES];
	
	[going.view removeFromSuperview];
	[self.view insertSubview:coming.view atIndex:0];
	
	[coming viewDidAppear:YES];
	[going viewDidDisappear:YES];
	
	[UIView commitAnimations];
}

- (void)settingsButtonPressed
{
	if (settingsController == nil)
	{
		ConfigFirstViewController *firstViewController = [[ConfigFirstViewController alloc] init];
		firstViewController.settings = self.settings;

		UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc]
										  initWithTitle:@"Back"
										  style: UIBarButtonItemStyleBordered
										  target: self
										  action: @selector(settingsButtonPressed)];
		firstViewController.navigationItem.leftBarButtonItem = barButtonItem;
		
		UINavigationController *navController =
			[[UINavigationController alloc] initWithRootViewController:firstViewController];
		navController.navigationBar.barStyle = UIBarStyleBlack;
		self.settingsController = navController;

		[firstViewController release];
		[barButtonItem release];
		[navController release];
	}

	// Flip views
	[UIView beginAnimations:@"SettingsViewFlip" context:nil];
	[UIView setAnimationDuration:.50];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	
	UIViewController *coming = nil;
	UIViewController *going = nil;
	UIViewAnimationTransition transition;
	
	BOOL toSettings = (self.settingsController.view.superview == nil);
	coming = toSettings ? (UIViewController *)self.settingsController : (UIViewController *)self.kittViewController;
	going = toSettings ? (UIViewController *)self.kittViewController : (UIViewController *)self.settingsController;
	transition = toSettings ? UIViewAnimationTransitionFlipFromLeft : UIViewAnimationTransitionFlipFromRight;
	
	[UIView setAnimationTransition:transition forView:self.view cache:YES];
	
	[coming viewWillAppear:YES];
	[going viewWillDisappear:YES];
	
	[going.view removeFromSuperview];
	[self.view insertSubview:coming.view atIndex:0];
	
	[coming viewDidAppear:YES];
	[going viewDidDisappear:YES];
	
	[UIView commitAnimations];
}

- (void)deviceIsShaking
{
	[kittViewController playSample:@"turboboost" ofType:@"wav" withMetering:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)dealloc {
	[settings dealloc];
	[kittViewController release];
	[dashViewController release];
	[infoViewController release];
    [super dealloc];
}

@end
