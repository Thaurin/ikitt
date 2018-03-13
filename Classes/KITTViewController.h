//
//  KittViewController.h
//  iKITT
//
//  Created by ivo on 3/22/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVAudioPlayer.h>

@interface KittViewController : UIViewController <AVAudioPlayerDelegate>
{
	NSArray *kittImages;
	NSArray *kittSounds;
	NSTimer	*timer;
	AVAudioPlayer *player;
	BOOL voiceBoxZoomed;
	CGRect voiceBoxFrame;
	UIImageView *logo;

	int lastRandomButton;
	int lastRandomPage;
	int introAnimationCount;
	int selectedPage;
	int lastPlayed;

	IBOutlet UIImageView *kittImage;

	IBOutlet UIImageView *buttonImageL1;
	IBOutlet UIImageView *buttonImageL2;
	IBOutlet UIImageView *buttonImageL3;
	IBOutlet UIImageView *buttonImageL4;
	IBOutlet UIImageView *buttonImageR1;
	IBOutlet UIImageView *buttonImageR2;
	IBOutlet UIImageView *buttonImageR3;
	IBOutlet UIImageView *buttonImageR4;
	
	IBOutlet UIButton *buttonL1;
	IBOutlet UIButton *buttonL2;
	IBOutlet UIButton *buttonL3;
	IBOutlet UIButton *buttonL4;
	IBOutlet UIButton *buttonR1;
	IBOutlet UIButton *buttonR2;
	IBOutlet UIButton *buttonR3;
	IBOutlet UIButton *buttonR4;
	
	IBOutlet UIImageView *redButtonImageView;
	IBOutlet UIImageView *yellowButtonImageView;
	IBOutlet UIImageView *blueButtonImageView;
	
	IBOutlet UIButton *infoButton;
	IBOutlet UIButton *configButton;
}
@property (retain, nonatomic) NSArray *kittImages;
@property (retain, nonatomic) NSArray *kittSounds;
@property (retain, nonatomic) NSTimer *timer;
@property (retain, nonatomic) UIImageView *logo;
@property (retain, nonatomic) UIImageView *kittImage;
@property (retain, nonatomic) AVAudioPlayer *player;
@property (retain, nonatomic) UIImageView *buttonImageL1;
@property (retain, nonatomic) UIImageView *buttonImageL2;
@property (retain, nonatomic) UIImageView *buttonImageL3;
@property (retain, nonatomic) UIImageView *buttonImageL4;
@property (retain, nonatomic) UIImageView *buttonImageR1;
@property (retain, nonatomic) UIImageView *buttonImageR2;
@property (retain, nonatomic) UIImageView *buttonImageR3;
@property (retain, nonatomic) UIImageView *buttonImageR4;
@property (retain, nonatomic) UIButton *buttonL1;
@property (retain, nonatomic) UIButton *buttonL2;
@property (retain, nonatomic) UIButton *buttonL3;
@property (retain, nonatomic) UIButton *buttonL4;
@property (retain, nonatomic) UIButton *buttonR1;
@property (retain, nonatomic) UIButton *buttonR2;
@property (retain, nonatomic) UIButton *buttonR3;
@property (retain, nonatomic) UIButton *buttonR4;
@property (retain, nonatomic) UIImageView *redButtonImageView;
@property (retain, nonatomic) UIImageView *yellowButtonImageView;
@property (retain, nonatomic) UIImageView *blueButtonImageView;
@property (retain, nonatomic) UIButton *infoButton;
@property (retain, nonatomic) UIButton *configButton;

- (void)playSample:(NSString *)resource ofType:(NSString *)type withMetering:(BOOL)meteringEnabled;
- (IBAction)buttonPressed:(id)sender;
- (IBAction)infoButtonPressed:(id)sender;
- (IBAction)configButtonPressed;
- (void)zoomKitt;
- (void)playRandom;
- (void)resetButtons;

@end
