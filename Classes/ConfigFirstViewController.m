//
//  ConfigFirstViewController.m
//  iKITT
//
//  Created by ivo on 3/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Settings.h"
#import "ConfigFirstViewController.h"
#import "ConfigSelectionViewController.h"

@implementation ConfigFirstViewController

@synthesize settings, settingsList, switchTags;

- (id)init
{
	self = [super initWithStyle:UITableViewStyleGrouped];
	if (self != nil)
	{
		self.title = @"Settings";
	}
	return self;
}

- (void)viewDidLoad
{
	NSString *settingsPath = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"plist"];
	NSDictionary *dictionary = [[NSDictionary alloc] initWithContentsOfFile:settingsPath];
	self.settingsList = [dictionary objectForKey:@"Settings"];
	switchTags = [[NSMutableArray alloc] init];
	[dictionary release];
}

- (void)viewWillAppear:(BOOL)animated
{
	[[self tableView] reloadData];
}

- (void)dealloc
{
	[settings release];
	[settingsList release];
	[switchTags release];
	[super dealloc];
}

- (NSArray *)rowsForSection:(NSInteger)section
{
	NSDictionary *sectionDictionary = [self.settingsList objectAtIndex:section];
	return [sectionDictionary objectForKey:@"SectionRows"];
}

- (NSString *)nameForSection:(NSInteger)section
{
	NSDictionary *sectionDictionary = [self.settingsList objectAtIndex:section];
	return [sectionDictionary objectForKey:@"SectionName"];
}

- (NSString *)typeForSection:(NSInteger)section row:(NSInteger)row
{
	NSDictionary *rowDictionary = [[self rowsForSection:section] objectAtIndex:row];
	return [rowDictionary objectForKey:@"Type"];
}

- (NSString *)titleForSection:(NSInteger)section row:(NSInteger)row
{
	NSDictionary *rowDictionary = [[self rowsForSection:section] objectAtIndex:row];
	return [rowDictionary objectForKey:@"Title"];
}

- (NSString *)keyForSection:(NSInteger)section row:(NSInteger)row
{
	NSDictionary *rowDictionary = [[self rowsForSection:section] objectAtIndex:row];
	return [rowDictionary objectForKey:@"Key"];
}

- (NSArray *)itemsForSection:(NSInteger)section row:(NSInteger)row
{
	NSDictionary *rowDictionary = [[self rowsForSection:section] objectAtIndex:row];
	return [rowDictionary objectForKey:@"Items"];
}

#pragma mark UITableViewController/Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [self.settingsList count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [[self rowsForSection:section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return [self nameForSection:section];
}

- (UITableViewCell *)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell;
	NSUInteger section = [indexPath section];
	NSUInteger row = [indexPath row];

	NSString *type = [self typeForSection:section row:row];
	NSString *title = [self titleForSection:section row:row];
	NSString *key = [self keyForSection:section row:row];

//	NSLog(@"type: %@, title: %@", type, title);

	NSString *idString = [type isEqualToString:@"List"] ? @"LabelTableIdentifier" : @"SwitchTableIdentifier";
	cell = [tableView dequeueReusableCellWithIdentifier:idString];
	
	if (cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero
									   reuseIdentifier: idString] autorelease];
		
		CGRect nameLabelRect = CGRectMake(10, 14, 185, 17);
		UILabel *nameLabel = [[UILabel alloc] initWithFrame:nameLabelRect];
		nameLabel.font = [UIFont boldSystemFontOfSize:16];
		nameLabel.tag = nameLabelTag;
		[cell.contentView addSubview:nameLabel];
		[nameLabel release];
		
		if ([type isEqualToString:@"List"])	// add value label
		{
			CGRect valueRect = CGRectMake(185, 14, 90, 17);
			UILabel *valueLabel = [[UILabel alloc] initWithFrame:valueRect];
			valueLabel.textAlignment = UITextAlignmentRight;
			valueLabel.font = [UIFont systemFontOfSize:15];
			valueLabel.tag = valueLabelTag;
			valueLabel.textColor = [UIColor colorWithRed:0 green:0 blue:0.5 alpha:1];
			[cell.contentView addSubview:valueLabel];
			[valueLabel release];
			
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
		else	// add switch
		{
			CGRect switchRect = CGRectMake(200, 9, 80, 15);
			UISwitch *switchControl = [[UISwitch alloc] initWithFrame:switchRect];
			[switchControl addTarget:self
							  action:@selector(switchChanged:)
						   forControlEvents:UIControlEventValueChanged];
			switchControl.tag = switchControlTag;
			[cell.contentView addSubview:switchControl];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			[switchControl release];
		}
		
	}
	
	UILabel *nameLabel = (UILabel *)[cell.contentView viewWithTag:nameLabelTag];
	NSString *value = [settings.values objectForKey:key];

	if ([type isEqualToString:@"List"])	// add value label
	{
		UILabel *valueLabel = (UILabel *)[cell.contentView viewWithTag:valueLabelTag];
		
		nameLabel.text = title;
		valueLabel = (UILabel *)[cell.contentView viewWithTag:valueLabelTag];

		NSArray *listItems = [self itemsForSection:section row:row];
		valueLabel.text = [listItems objectAtIndex:[value intValue]];
	}
	else
	{
		UISwitch *switchControl = (UISwitch *)[cell.contentView viewWithTag:switchControlTag];

		// FIXME: tag is used for other stfuf, conflicts!! (see above)
		// Get tag for config key and/or add config key to list
		int tag;
		for (tag=0; tag < [switchTags count]; tag++)
		{
			if ([[switchTags objectAtIndex:tag] isEqualToString:key]) break;
		}
		if (tag >= [switchTags count]) [switchTags addObject:key];
		switchControl.tag = tag;

		nameLabel.text = title;
		BOOL state = value == @"0" ? NO : YES;
		[switchControl setOn:state animated:NO];
	}

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSUInteger section = [indexPath section];
	NSUInteger row = [indexPath row];

	NSString *type = [self typeForSection:section row:row];
	if ([type isEqualToString:@"Switch"])
	{
		return;
	}
	
	ConfigSelectionViewController *selectionController =
		[[ConfigSelectionViewController alloc] initWithStyle:UITableViewStyleGrouped];

	NSString *title = [self titleForSection:section row:row];
	NSString *key = [self keyForSection:section row:row];

	NSArray *listItems = [self itemsForSection:section row:row];

	selectionController.configKey = key;
	selectionController.title = title;
	selectionController.list = listItems;
	selectionController.settings = self.settings;

	NSString *value = [settings.values objectForKey:key];
	NSUInteger indexArray[] = {0, [value intValue]};
	selectionController.selectedIndexPath = [NSIndexPath indexPathWithIndexes:indexArray length:2];

	[self.navigationController pushViewController:selectionController animated:YES];
	
	[selectionController release];
}

- (void)switchChanged:(id)sender
{
	UISwitch *mySwitch = (UISwitch *)sender;

	// TODO: determine which configKey needs to change!

	NSString *key = [switchTags objectAtIndex:mySwitch.tag];
	NSString *value = mySwitch.on == NO ? @"0" : @"1";
	[settings.values setValue:value forKey:key];
	[settings writeSettings];
}

@end
