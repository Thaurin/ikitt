//
//  MyCLController.h
//  iKITT
//
//  Created by ivo on 4/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@protocol MyCLControllerDelegate <NSObject>
@required
- (void)newLocationUpdate:(CLLocation *)newLocation withOldLocation:(CLLocation *)oldLocation;
- (void)newError:(NSString *)text;
@end

@interface MyCLController : NSObject <CLLocationManagerDelegate> {
	CLLocationManager *locationManager;
	id delegate;
	int updateCount;
}
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) id <MyCLControllerDelegate> delegate;

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation;
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error;

+ (MyCLController *)sharedInstance;

@end
