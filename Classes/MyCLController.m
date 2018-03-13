//
//  MyCLController.m
//  iKITT
//
//  Created by ivo on 4/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MyCLController.h"

static MyCLController *sharedCLDelegate = nil;

@implementation MyCLController
@synthesize locationManager;
@synthesize delegate;

- (id) init {
	self = [super init];
	if (self != nil) {
		self.locationManager = [[[CLLocationManager alloc] init] autorelease];
		self.locationManager.delegate = self; // Tells the location manager to send updates to this object
	}
	return self;
}

// Called when the location is updated
- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation	
{
	if (signbit(newLocation.horizontalAccuracy))
	{
		// Negative accuracy means an invalid or unavailable measurement
		//[self.delegate newStatusUpdate:@"Latitude / Longitude unavailable"];
	}
	else
	{
		// Skip first two measurements
		if (updateCount < 2)
		{
			updateCount++;
			
		}
		else
		{
			[self.delegate newLocationUpdate:newLocation withOldLocation:oldLocation];
		}
	}
}

// Called when there is an error getting the location
- (void)locationManager:(CLLocationManager *)manager
	   didFailWithError:(NSError *)error
{
	NSString *errorString;
	
	if ([error domain] == kCLErrorDomain) {
		
		// We handle CoreLocation-related errors here
		
		switch ([error code]) {
				// This error code is usually returned whenever user taps "Don't Allow" in response to
				// being told your app wants to access the current location. Once this happens, you cannot
				// attempt to get the location again until the app has quit and relaunched.
				//
				// "Don't Allow" on two successive app launches is the same as saying "never allow". The user
				// can reset this for all apps by going to Settings > General > Reset > Reset Location Warnings.

			case kCLErrorDenied:
				errorString = [NSString stringWithString:@"Your location could not be determined."];
				break;
				
				// This error code is usually returned whenever the device has no data or WiFi connectivity,
				// or when the location cannot be determined for some other reason.
				//
				// CoreLocation will keep trying, so you can keep waiting, or prompt the user.
				//
			case kCLErrorLocationUnknown:
				//errorString = [NSString stringWithString:@"Your location could not be determined."];
				break;
				
				// We shouldn't ever get an unknown error code, but just in case...
				//
			default:
				errorString = [NSString stringWithString:@"Unknown location error."];
				break;
		}
	} else {
		// We handle all non-CoreLocation errors here
		// (we depend on localizedDescription for localization)
		//[errorString appendFormat:@"Error domain: \"%@\"  Error code: %d\n", [error domain], [error code]];
		//errorString = [NSString stringWithFormat:@"Description: \"%@\"\n", [error localizedDescription]];
		errorString = [NSString stringWithString:@"Unknown location error."];
	}

	// Send the update to our delegate
	[self.delegate newError:errorString];
}

#pragma mark ---- singleton object methods ----

// See "Creating a Singleton Instance" in the Cocoa Fundamentals Guide for more info

+ (MyCLController *)sharedInstance {
    @synchronized(self) {
        if (sharedCLDelegate == nil) {
            [[self alloc] init]; // assignment not done here
        }
    }
    return sharedCLDelegate;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedCLDelegate == nil) {
            sharedCLDelegate = [super allocWithZone:zone];
            return sharedCLDelegate;  // assignment and return on first allocation
        }
    }
    return nil; // on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain {
    return self;
}

- (unsigned)retainCount {
    return UINT_MAX;  // denotes an object that cannot be released
}

- (void)release {
    //do nothing
}

- (id)autorelease {
    return self;
}

@end
