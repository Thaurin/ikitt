//
//  iKITTAppDelegate.h
//  iKITT
//
//  Created by ivo on 3/22/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVAudioPlayer.h>

@class MainViewController;

static BOOL L0AccelerationIsShaking(UIAcceleration* last, UIAcceleration* current, double threshold) {
    double
    deltaX = fabs(last.x - current.x),
    deltaY = fabs(last.y - current.y),
    deltaZ = fabs(last.z - current.z);
    
    return
    (deltaX > threshold && deltaY > threshold) ||
    (deltaX > threshold && deltaZ > threshold) ||
    (deltaY > threshold && deltaZ > threshold);
}

@interface iKITTAppDelegate : NSObject <UIApplicationDelegate, UIAccelerometerDelegate>
{
    IBOutlet UIWindow *window;
    IBOutlet MainViewController *mainViewController;

	BOOL histeresisExcited;
    UIAcceleration* lastAcceleration;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) MainViewController *mainViewController;
@property(retain) UIAcceleration* lastAcceleration;

@end

