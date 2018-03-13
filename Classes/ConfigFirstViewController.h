//
//  ConfigFirstViewController.h
//  iKITT
//
//  Created by ivo on 3/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Settings;
@class ConfigSelectionViewController;

#define nameLabelTag 1
#define valueLabelTag 2
#define switchControlTag 3

@interface ConfigFirstViewController : UITableViewController {
	Settings *settings;
	NSArray *settingsList;	// Settings screen layout
	NSMutableArray *switchTags;
}

@property (retain, nonatomic) Settings *settings;
@property (retain, nonatomic) NSArray *settingsList;
@property (retain, nonatomic) NSMutableArray *switchTags;

@end
