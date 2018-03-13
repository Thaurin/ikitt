//
//  Settings.m
//  iKITT
//
//  Created by ivo on 3/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Settings.h"

@implementation Settings

@synthesize values;

- (id)init
{
	self = [super init];
	if (self != nil)
	{
		NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *userSettingsPath = [[pathArray objectAtIndex:0] stringByAppendingPathComponent:@"UserSettings.plist"];
		if ([[NSFileManager defaultManager] fileExistsAtPath:userSettingsPath])
		{
			self.values = [[NSMutableDictionary alloc] initWithContentsOfFile:userSettingsPath];
		}
		else
		{
			NSString *settingsPath = [[NSBundle mainBundle] pathForResource:@"Defaults" ofType:@"plist"];
			self.values = [[NSMutableDictionary alloc] initWithContentsOfFile:settingsPath];
		}
	}

	return self;
}

- (void)dealloc
{
	[values dealloc];
	[super dealloc];
}

- (void)writeSettings
{
	// FIX? reuse path stuff?
	NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *path = [[pathArray objectAtIndex:0] stringByAppendingPathComponent:@"UserSettings.plist"];
	[self.values writeToFile:path atomically:YES];
}

@end
