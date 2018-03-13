//
//  Settings.h
//  iKITT
//
//  Created by ivo on 3/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Settings : NSObject {
	NSDictionary *values;
}

@property (retain, nonatomic) NSDictionary *values;

- (void)writeSettings;

@end
