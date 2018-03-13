//
//  KittViewController.m
//  iKITT
//
//  Created by ivo on 3/22/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "KittViewController.h"
#import "LedMeter.h"

@implementation KittViewController

@synthesize kittImages, kittSounds, logo, kittImage, timer;
@synthesize player;
@synthesize buttonImageL1, buttonImageL2, buttonImageL3, buttonImageL4;
@synthesize buttonImageR1, buttonImageR2, buttonImageR3, buttonImageR4;
@synthesize buttonL1, buttonL2, buttonL3, buttonL4;
@synthesize buttonR1, buttonR2, buttonR3, buttonR4;
@synthesize infoButton, configButton;
@synthesize redButtonImageView, yellowButtonImageView, blueButtonImageView;

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.kittImages = [NSArray arrayWithObjects:
						   [UIImage imageNamed:@"voicebox0.png"],
						   [UIImage imageNamed:@"voicebox1.png"],
						   [UIImage imageNamed:@"voicebox2.png"],
						   [UIImage imageNamed:@"voicebox3.png"],
						   [UIImage imageNamed:@"voicebox4.png"],
						   [UIImage imageNamed:@"voicebox5.png"],
						   [UIImage imageNamed:@"voicebox6.png"],
						   nil];

	selectedPage = 1;

	voiceBoxZoomed = NO;
	voiceBoxFrame = kittImage.frame;	// Remember initial frame from IB
	kittImage.contentMode = UIViewContentModeScaleToFill;
	srandom(time(NULL));

	// Make info button more tappable
	infoButton.frame = CGRectMake(275, 435, 30, 30);

	infoButton.alpha = 0.0;
	infoButton.userInteractionEnabled = NO;
	configButton.alpha = 0.0;
	configButton.userInteractionEnabled = NO;
	redButtonImageView.userInteractionEnabled = NO;
	yellowButtonImageView.userInteractionEnabled = NO;
	blueButtonImageView.userInteractionEnabled = NO;

	// Start off first-time animation
	introAnimationCount = 0;
	timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self		//0.65 target:self
										   selector:@selector(introAnimation) userInfo:nil repeats:YES];
}

- (void)introAnimation
{
	switch (introAnimationCount)
	{
		case 0:
			[self playSample:@"startup" ofType:@"wav" withMetering:NO];
			buttonImageL1.hidden = buttonImageR1.hidden = NO;
			break;
		case 1:
			buttonImageL2.hidden = buttonImageR2.hidden = NO;
			break;
		case 2:
			buttonImageL3.hidden = buttonImageR3.hidden = NO;
			break;
		case 3:
			buttonImageL4.hidden = buttonImageR4.hidden = NO;
			break;
		case 4:	// Logo animation
			logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo.png"]];
			logo.frame = CGRectMake(101, -22, 120, 22);
			logo.alpha = 0;
			infoButton.alpha = 0;
			configButton.alpha = 0.0;
			[self.view insertSubview:logo belowSubview:kittImage];

			[UIView beginAnimations:@"logoAnimation" context:nil];
			[UIView setAnimationDelegate:self];
			[UIView setAnimationDidStopSelector:@selector(introAnimationDidStop)];
			[UIView setAnimationDuration:0.75];
			[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
			logo.frame = CGRectMake(101, 47, 120, 22);
			logo.alpha = 1.0;
			infoButton.alpha = 0.25;
			configButton.alpha = 0.25;
			redButtonImageView.alpha = 1.0;
			[UIView commitAnimations];

			[timer invalidate];
			timer = nil;
			break;
		default:
			break;
	}

	introAnimationCount++;
}

- (void)introAnimationDidStop
{
	buttonL1.enabled = buttonL2.enabled = buttonL3.enabled = buttonL4.enabled = YES;
	buttonR1.enabled = buttonR2.enabled = buttonR3.enabled = buttonR4.enabled = YES;
	infoButton.userInteractionEnabled = YES;
	configButton.userInteractionEnabled = YES;

	redButtonImageView.userInteractionEnabled = YES;
	yellowButtonImageView.userInteractionEnabled = YES;
	blueButtonImageView.userInteractionEnabled = YES;

	redButtonImageView.alpha = 1.0;
	yellowButtonImageView.alpha = 0.02;
	blueButtonImageView.alpha = 0.02;
}

- (void)resetButtons
{
	buttonImageL1.hidden = NO;
	buttonImageL2.hidden = NO;
	buttonImageL3.hidden = NO;
	buttonImageL4.hidden = NO;
	buttonImageR1.hidden = NO;
	buttonImageR2.hidden = NO;
	buttonImageR3.hidden = NO;
	buttonImageR4.hidden = NO;
}

- (void)playSample:(NSString *)resource ofType:(NSString *)type withMetering:(BOOL)meteringEnabled
{
	NSString *path = [[NSBundle mainBundle] pathForResource:resource ofType:type];
	[player stop];
	[player release];
	player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:nil];
	[player setDelegate:self];
	[player setMeteringEnabled: meteringEnabled];

	[player play];

	if (meteringEnabled)
	{
		if (timer != nil)
		{
			[timer invalidate];
		}
		timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self
										   selector:@selector(updateVisualisation) userInfo:nil repeats:YES];
	}
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)thePlayer successfully:(BOOL)flag
{
	self.resetButtons;
	[timer invalidate];
	timer = nil;
}

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
	self.resetButtons;
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
	[self audioPlayerDecodeErrorDidOccur:nil error:nil];
}

- (IBAction)buttonPressed:(id)sender
{
	UIButton *button = (UIButton *)sender;
	self.resetButtons;

	if (player.playing && lastPlayed == button.tag)
	{
		[player stop];
		return;
	}

	UIButton *tappedButtonImage = (UIButton*)[self.view viewWithTag:(button.tag + 10)];
	tappedButtonImage.hidden = YES;
	lastPlayed = button.tag;

	NSString *sampleName = [NSString stringWithFormat:@"kitt%d-%d", selectedPage, button.tag];
	[self playSample:sampleName ofType:@"wav" withMetering:YES];
}

- (void)updateVisualisation
{
	[player updateMeters];
	float averagePower = [player averagePowerForChannel:0];
	
	int lowerCutOffValue = 140;
	//int upperCutOffValue = 158;
	int maxPower = 160;
	
	int power = ((int)averagePower) + maxPower;
	power = (power < lowerCutOffValue ? lowerCutOffValue : power) - lowerCutOffValue;
	int imageIndex = ([kittImages count] * power) / (maxPower - lowerCutOffValue);
//	NSLog([NSString stringWithFormat:@"imageIndex is: %d", imageIndex]);
	
	UIImage *image = [self.kittImages objectAtIndex:imageIndex];
	kittImage.image = image;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [[event allTouches] anyObject];
	NSUInteger tapCount = [touch tapCount];
	NSString *resourceString;

	if (touch.view == kittImage)
	{
		switch(tapCount)
		{
			case 1:
				[self performSelector:@selector(playRandom) withObject:nil afterDelay:.4];
				break;
			case 2:
				[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(playRandom) object:nil];
				[self zoomKitt];
				break;
			default:
				break;
		}
		return;
	}
	else if (touch.view == redButtonImageView)
	{
		redButtonImageView.alpha = 1.0;
		yellowButtonImageView.alpha = 0.02;
		blueButtonImageView.alpha = 0.02;
		resourceString = @"beep1";
		selectedPage = 1;
	}
	else if (touch.view == yellowButtonImageView)
	{
		redButtonImageView.alpha = 0.02;
		yellowButtonImageView.alpha = 1.0;
		blueButtonImageView.alpha = 0.02;
		resourceString = @"beep2";
		selectedPage = 2;
	}
	else if (touch.view == blueButtonImageView)
	{
		redButtonImageView.alpha = 0.02;
		yellowButtonImageView.alpha = 0.02;
		blueButtonImageView.alpha = 1.0;
		resourceString = @"beep3";
		selectedPage = 3;
	}
	else
	{
		return;		// Not in one of the buttons
	}

	[self resetButtons];
	[self playSample:resourceString ofType:@"wav" withMetering:NO];
}

- (void)playRandom
{
	// rewrite
	int randomButton = lastRandomButton;
	while (randomButton == lastRandomButton)
	{
		randomButton = (random() % 8) + 1;
	}

	int randomPage = lastRandomPage;
	while (randomPage == lastRandomPage)
	{
		randomPage = (random() % 3) + 1;
	}

	NSString *randomSample = [NSString stringWithFormat:@"kitt%d-%d", randomPage, randomButton		];

	//	[self playSample:[kittSounds objectAtIndex:randomIndex] ofType:@"wav" withMetering: YES];
	[self playSample:randomSample ofType:@"wav" withMetering:YES];
	lastRandomButton = randomButton;
	lastRandomPage = randomPage;
}

- (void)zoomKitt
{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.3];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];

	kittImage.frame = kittImage.bounds = voiceBoxZoomed ? voiceBoxFrame : CGRectMake(
		0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);

	[UIView commitAnimations];
	voiceBoxZoomed = !voiceBoxZoomed;
}

- (IBAction)infoButtonPressed:(id)sender
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"FlipInfo" object:nil];
}

- (IBAction)configButtonPressed
{
//	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"test" message:@"test" delegate:nil cancelButtonTitle:@"test" otherButtonTitles:nil];
//		[alert show];
//		[alert release];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"FlipConfig" object:nil];
}

- (void)didReceiveMemoryWarning
{
	// Commenting out fixes bug, but it's not quite te right thing to do, yeah?
    //[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview

    // Release anything that's not essential, such as cached data
}

- (void)dealloc
{
	[kittImages release];
	[kittSounds release];
	[timer release];
	[player release];
	[logo release];
	[kittImage release];
	[buttonImageL1 release];
	[buttonImageL2 release];
	[buttonImageL3 release];
	[buttonImageL4 release];
	[buttonImageR1 release];
	[buttonImageR2 release];
	[buttonImageR3 release];
	[buttonImageR4 release];
	[redButtonImageView release];
	[yellowButtonImageView release];
	[blueButtonImageView release];
	[infoButton release];
	[configButton release];
    [super dealloc];
}

@end
