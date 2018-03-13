//
//  DashViewController.m
//  iKITT
//
//  Created by ivo on 4/14/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DashViewController.h"

@implementation DashViewController

@synthesize speedBackground, speedLabel, statusLabel, unitImageView, timer, ledOff, ledOn, currentSpeed, newSpeed, previousSpeedString;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib
- (void)viewDidLoad
{
	[super viewDidLoad];
	[self setSpeedLabelSize:kSpeedLabelFontSmall];

	metricEnabled = YES;
	speedLabel.text = @"000";
	speedLabel.contentMode = UIViewContentModeScaleToFill;
	[self updateUnitImage];

	ledOff = [UIImage imageNamed:@"led_off.png"];
	ledOn = [UIImage imageNamed:@"led_on3.png"];

	speedFrame = speedLabel.frame;	// Remember initial frame from IB
	backgroundFrame = speedBackground.frame;	// Remember initial frame from IB
	speedZoomed = NO;

	// Led meter views
	accuracyLedMeter = [[LedMeter alloc] initWithFrame:CGRectMake(30, 235, 150, 5)];
	accuracyLedMeter.minValue = 0;
	accuracyLedMeter.maxValue = 50;

	verticalAccuracyLedMeter = [[LedMeter alloc] initWithFrame:CGRectMake(300, 235, 150, 5)];
	verticalAccuracyLedMeter.minValue = 0;
	verticalAccuracyLedMeter.maxValue = 50;

	altitudeLedMeter = [[LedMeter alloc] initWithFrame:CGRectMake(30, 275, 150, 5)];
	altitudeLedMeter.minValue = 0;
	altitudeLedMeter.maxValue = 300;

	courseLedMeter = [[LedMeter alloc] initWithFrame:CGRectMake(300, 275, 150, 5)];
	courseLedMeter.minValue = 0;
	courseLedMeter.maxValue = 359;

	[self.view insertSubview:accuracyLedMeter atIndex:1];
	[self.view insertSubview:verticalAccuracyLedMeter atIndex:1];
	[self.view insertSubview:altitudeLedMeter atIndex:1];
	[self.view insertSubview:courseLedMeter atIndex:1];
	
	[MyCLController sharedInstance].delegate = self;
	[MyCLController sharedInstance].locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	[MyCLController sharedInstance].locationManager.distanceFilter = kCLDistanceFilterNone;
	[[MyCLController sharedInstance].locationManager startUpdatingLocation];

	// test values/screenshots
//	currentSpeed = 40;
//	[self updateSpeed];
//	accuracyLedMeter.value = 40;
//	verticalAccuracyLedMeter.value = 10;
//	altitudeLedMeter.value = 50;
//	courseLedMeter.value = 140;	
//	statusLabel.text = @"";
}

//- (IBAction)testButton
//{
//	[accuracyLedMeter setValue:random() % 100];
//	[verticalAccuracyLedMeter setValue:random() % 20];
//	[altitudeLedMeter setValue:random() % 100];
//	[courseLedMeter setValue:random() % 359];
//	self.currentSpeed = random() % 50;
//	[self updateSpeedLabel];
//	[self updateRpm];
//}

- (void)updateSpeedLabel
{
	previousSpeedString = speedLabel.text;
	speedLabel.text = [NSString stringWithFormat:@"%03.0f", metricEnabled ?
					   [self currentSpeed] * 3.6 :
					   [self currentSpeed] * 2.23693629];
}

- (void)updateRpm
{
	int nrOfLeds = (self.currentSpeed * kNumberOfLeds) / 60;	// 216 km/h max

	for (int i=1; i <= kNumberOfLeds; i++)
	{
		UIImageView *ledView = (UIImageView *)[self.view viewWithTag:i];
		
		if (i <= nrOfLeds)
		{
			ledView.image = ledOn;
		}
		else
		{
			ledView.image = ledOff;
		}
	}
}

- (void)updateUnitImage
{
	unitImageView.image = metricEnabled ? [UIImage imageNamed:@"kmh.png"] : [UIImage imageNamed:@"mph.png"];
}

- (void)updateSpeed
{
	if (intervalCount < kSpeedChangeSteps)
	{
		self.currentSpeed += intervalSize;
		intervalCount++;
	}
	else
	{
		self.currentSpeed = self.newSpeed;
		[timer invalidate];
		timer = nil;
	}

	[self updateSpeedLabel];
	[self updateRpm];
}

- (void)newLocationUpdate:(CLLocation *)newLocation withOldLocation:(CLLocation *)oldLocation
{
	if (oldLocation != nil)
	{
		if  (!signbit(newLocation.speed))
		{

	// test code, not using the speed property
//	if (newLocation.horizontalAccuracy <= 25)
//	{
//		NSTimeInterval difference = [[newLocation timestamp] timeIntervalSinceDate:[oldLocation timestamp]];
//		double tempDistance = [newLocation getDistanceFrom:oldLocation];
//		self.newSpeed = abs(tempDistance/difference);
//	}

			self.newSpeed = newLocation.speed;

			if (timer != nil)
			{
				[timer invalidate];
				timer = nil;
			}

			//NSTimeInterval difference = abs(self.newSpeed - self.currentSpeed);
			intervalCount = 0;
			intervalSize = (self.newSpeed - self.currentSpeed) / kSpeedChangeSteps;
			//intervalSize = difference / kSpeedChangeSteps;
			timer = [NSTimer scheduledTimerWithTimeInterval:kSpeedChangeInterval target:self
								selector:@selector(updateSpeed) userInfo:nil repeats:YES];
		}

		accuracyLedMeter.value = (accuracyLedMeter.maxValue - newLocation.horizontalAccuracy);
		newLocation.verticalAccuracy >= 0 ?
			verticalAccuracyLedMeter.value = (verticalAccuracyLedMeter.maxValue - newLocation.verticalAccuracy) :
			0;
		courseLedMeter.value = newLocation.course;
		altitudeLedMeter.value = newLocation.altitude;	// needs accuracy to be useful

		if (newLocation.horizontalAccuracy <= 25 || newLocation.speed > 0)
		{
			self.statusLabel.text = @"";
			self.statusLabel.hidden = YES;
		}
	}
}

- (void)newError:(NSString *)text
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"GPS Error" message:text delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
	[alert show];
	[alert release];
	
	self.statusLabel.text = @"";
	self.statusLabel.hidden = YES;
}

- (void)setSpeedLabelSize:(int)size
{
	switch(size)
	{
		case kSpeedLabelFontSmall:
			speedLabel.font = [UIFont fontWithName:@"DBLCDTempBlack" size:65];
			break;
		case kSpeedLabelFontLarge:
			speedLabel.font = [UIFont fontWithName:@"DBLCDTempBlack" size:225];
			break;
		default:
			break;
	}
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [[event allTouches] anyObject];
	NSUInteger tapCount = [touch tapCount];
	
	if ((touch.view == self.speedLabel || touch.view == self.speedBackground) && tapCount == 2)
	{
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.3];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];

		speedLabel.frame = speedLabel.bounds = speedZoomed ? speedFrame :
			CGRectMake(
					   0, 0, [[UIScreen mainScreen] bounds].size.height,
					   [[UIScreen mainScreen] bounds].size.width);
		speedBackground.frame = speedBackground.bounds = speedZoomed ? backgroundFrame : 
			CGRectMake(
					   0, 0, [[UIScreen mainScreen] bounds].size.height,
					   [[UIScreen mainScreen] bounds].size.width);
		if (speedZoomed) [self setSpeedLabelSize:kSpeedLabelFontSmall];
		else [self setSpeedLabelSize:kSpeedLabelFontLarge];

		[UIView commitAnimations];
		speedZoomed = !speedZoomed;
	}
	else if (touch.view == self.unitImageView)
	{
		metricEnabled = !metricEnabled;
		[self updateUnitImage];
		[self updateSpeedLabel];
	}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview

    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[speedBackground release];
	[speedLabel release];
	[statusLabel release];
	[unitImageView release];
	[timer release];
	[ledOff release];
	[ledOn release];
	[previousSpeedString release];
    [super dealloc];
}


@end
