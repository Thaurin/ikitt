//
//  ConfigSelectionViewController.h
//  iKITT
//
//  Created by ivo on 3/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Settings;


@interface ConfigSelectionViewController : UITableViewController {
	Settings *settings;
	NSArray *list;
	NSString *configKey;
	NSIndexPath *selectedIndexPath;
}

@property (nonatomic, retain) Settings *settings;
@property (nonatomic, retain) NSArray *list;
@property (nonatomic, retain) NSString *configKey;
@property (nonatomic, retain) NSIndexPath *selectedIndexPath;

@end
