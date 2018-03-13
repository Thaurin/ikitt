//
//  DashViewController.h
//  iKITT
//
//  Created by ivo on 4/14/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIColor.h>
#import <AVFoundation/AVAudioPlayer.h>
#import "MyCLController.h"
#import "LedMeter.h"

#define kNumberOfLeds 33
#define kSpeedLabelFontSmall 1
#define kSpeedLabelFontLarge 2
#define kSpeedChangeInterval 0.05
#define kSpeedChangeSteps (1 / kSpeedChangeInterval)

@interface DashViewController : UIViewController <MyCLControllerDelegate>
{
	IBOutlet UIView *speedBackground;
	IBOutlet UILabel *speedLabel;
	IBOutlet UILabel *statusLabel;
	IBOutlet UIImageView *unitImageView;

	NSTimer	*timer;
	
	UIImage *ledOff;
	UIImage *ledOn;
	
	CGRect speedFrame;
	CGRect backgroundFrame;
	BOOL speedZoomed;
	BOOL metricEnabled;
	CLLocationSpeed currentSpeed;
	CLLocationSpeed newSpeed;
	NSString *previousSpeedString;
	
	NSTimeInterval intervalSize;
	int intervalCount;
	
	LedMeter *accuracyLedMeter;
	LedMeter *verticalAccuracyLedMeter;
	LedMeter *altitudeLedMeter;
	LedMeter *courseLedMeter;
}
@property (retain, nonatomic) UIView *speedBackground;
@property (retain, nonatomic) UILabel *speedLabel;
@property (retain, nonatomic) UILabel *statusLabel;
@property (retain, nonatomic) UIImageView *unitImageView;
@property (retain, nonatomic) NSTimer *timer;
@property (retain, nonatomic) UIImage *ledOff, *ledOn;
@property (assign) CLLocationSpeed currentSpeed;
@property (assign) CLLocationSpeed newSpeed;
@property (retain, nonatomic) NSString *previousSpeedString;

- (void)setSpeedLabelSize:(int)size;
- (void)updateUnitImage;
- (void)updateSpeedLabel;
- (void)updateRpm;

//- (IBAction)testButton;

@end
