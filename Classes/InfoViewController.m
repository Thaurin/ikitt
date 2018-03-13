//
//  InfoViewController.m
//  iKITT
//
//  Created by ivo on 4/14/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "InfoViewController.h"


@implementation InfoViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	UIImage *buttonBackgroundNormal = [UIImage imageNamed:@"grayButton.png"];
	UIImage *buttonBackgroundPressed = [UIImage imageNamed:@"blueButton.png"];

	UIImage *stretchableButtonNormal = [buttonBackgroundNormal stretchableImageWithLeftCapWidth:12 topCapHeight:0];
	[websiteButton setBackgroundImage:stretchableButtonNormal forState:UIControlStateNormal];

	UIImage *stretchableButtonPressed = [buttonBackgroundPressed stretchableImageWithLeftCapWidth:12 topCapHeight:0];
	[websiteButton setBackgroundImage:stretchableButtonPressed forState:UIControlStateHighlighted];
}

- (IBAction)doneButtonPressed:(id)sender
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"FlipInfo" object:nil];
}

- (IBAction)websiteButtonPressed
{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.mentation.nl/thanatist/"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
    [super dealloc];
}


@end
