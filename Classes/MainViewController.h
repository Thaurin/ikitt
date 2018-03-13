//
//  MainViewController.h
//  iKITT
//
//  Created by ivo on 4/9/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConfigFirstViewController.h"
#define degreesToRadian(x) (M_PI * (x) / 180.0)

@class Settings;
@class KittViewController;
@class DashViewController;
@class InfoViewController;
@class ConfigViewController;

@interface MainViewController : UIViewController {
	Settings *settings;
	KittViewController *kittViewController;
	DashViewController *dashViewController;
	InfoViewController *infoViewController;
	UINavigationController *settingsController;
}
@property (retain, nonatomic) Settings *settings;
@property (retain, nonatomic) KittViewController *kittViewController;
@property (retain, nonatomic) DashViewController *dashViewController;
@property (retain, nonatomic) InfoViewController *infoViewController;
@property (retain, nonatomic) UINavigationController *settingsController;

- (void)infoButtonPressed;
- (void)deviceIsShaking;

@end
