//
//  InfoViewController.h
//  iKITT
//
//  Created by ivo on 4/14/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InfoViewController : UIViewController {
	IBOutlet UIButton *websiteButton;
}

- (IBAction)doneButtonPressed:(id)sender;
- (IBAction)websiteButtonPressed;

@end
