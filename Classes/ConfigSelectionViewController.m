//
//  ConfigSelectionViewController.m
//  iKITT
//
//  Created by ivo on 3/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ConfigSelectionViewController.h"
#import "Settings.h"

@implementation ConfigSelectionViewController

@synthesize settings;
@synthesize list, configKey, selectedIndexPath;

- (void)viewWillAppear:(BOOL)animated
{
//	NSLog(@"sel count: %d, first sel: %@", [list count], [list objectAtIndex:0]);
}

- (void)dealloc
{
	[settings release];
	[list release];
	[configKey release];
	[selectedIndexPath release];
	[super dealloc];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [list count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *ConfigSelectionIdentifier = @"ConfigSelectionIdentifier";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: ConfigSelectionIdentifier];
	
	if (cell == nil) {
		cell = [[[UITableViewCell alloc]
				 initWithStyle:UITableViewCellStyleDefault
				 reuseIdentifier: ConfigSelectionIdentifier] autorelease];
	}
	
	NSUInteger row = [indexPath row];
	NSUInteger selectedRow = [selectedIndexPath row];

	cell.textLabel.text = [list objectAtIndex:row];
	cell.accessoryType = (row == selectedRow && selectedIndexPath != nil) ?
		UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSUInteger row = [indexPath row];
	NSUInteger oldRow = (selectedIndexPath != nil) ? [selectedIndexPath row] : -1;

	if (row != oldRow)
	{
		UITableViewCell *newCell = [tableView cellForRowAtIndexPath: indexPath];
		UITableViewCell *oldCell = [tableView cellForRowAtIndexPath: selectedIndexPath];

		newCell.accessoryType = UITableViewCellAccessoryCheckmark;
		oldCell.accessoryType = UITableViewCellAccessoryNone;

		selectedIndexPath = indexPath;

		// FIX ME: change value in settings, doesn't save
		NSString *valueString = [NSString stringWithFormat:@"%d", row];
		[settings.values setValue:valueString forKey:configKey];

		[settings writeSettings];
	}
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
