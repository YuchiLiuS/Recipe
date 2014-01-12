//
//  MusicViewController.m
//  Recipe
//
//  Created by yuchiliu on 12/7/13.
//  Copyright (c) 2013 CS193P. All rights reserved.
// Reference apple's iPod Library access Programming document.
//

#import "MusicViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <MediaPlayer/MediaPlayer.h>

@interface MusicViewController () <MPMediaPickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (strong, nonatomic) MPMusicPlayerController *musicPlayer;
@property (weak, nonatomic) IBOutlet UILabel *musicTitleLabel;

@end

@implementation MusicViewController

-(void)setRoundedView:(UIImageView *)roundedView
{
    CGPoint oldCenter = roundedView.center;
    CGFloat diameter = roundedView.frame.size.width;
    CGRect newFrame = CGRectMake(roundedView.frame.origin.x, roundedView.frame.origin.y, diameter, diameter);
    roundedView.frame = newFrame;
    roundedView.layer.cornerRadius = diameter / 2.0;
    roundedView.center = oldCenter;
    roundedView.clipsToBounds = YES;
}

//Befor deallocation, unregister for notifications and turn them off.
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self
													name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification
												  object: self.musicPlayer];
	
	[[NSNotificationCenter defaultCenter] removeObserver: self
													name: MPMusicPlayerControllerPlaybackStateDidChangeNotification
												  object: self.musicPlayer];
    
    [self.musicPlayer endGeneratingPlaybackNotifications];
    
}


#pragma mark - Media Picker

- (IBAction)selectMusic:(id)sender {
    MPMediaPickerController *mediaPicker = [[MPMediaPickerController alloc] initWithMediaTypes: MPMediaTypeAny];
    
    mediaPicker.delegate = self;
    mediaPicker.allowsPickingMultipleItems = YES;
    mediaPicker.prompt = NSLocalizedString(@"Add songs to play", "Prompt in media item picker");
    [self presentViewController:mediaPicker animated:YES completion:nil];
}

- (void) mediaPicker: (MPMediaPickerController *) mediaPicker didPickMediaItems: (MPMediaItemCollection *) mediaItemCollection
{
    if (mediaItemCollection) {
        
        [self.musicPlayer setQueueWithItemCollection: mediaItemCollection];
        [self.musicPlayer play];
    }
    
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void) mediaPickerDidCancel: (MPMediaPickerController *) mediaPicker
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Media Playback
- (void) registerForMediaPlayerNotifications {
    
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
	[notificationCenter addObserver: self
						   selector: @selector (handle_NowPlayingItemChanged:)
							   name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification
							 object: self.musicPlayer];
	
	[notificationCenter addObserver: self
						   selector: @selector (handle_PlaybackStateChanged:)
							   name: MPMusicPlayerControllerPlaybackStateDidChangeNotification
							 object: self.musicPlayer];
    
	[self.musicPlayer beginGeneratingPlaybackNotifications];
}

- (void) handle_NowPlayingItemChanged: (id) notification
{
    MPMediaItem *currentItem = [self.musicPlayer nowPlayingItem];
    UIImage *artworkImage = [UIImage imageNamed:@"colorful_note.png"];
    MPMediaItemArtwork *artwork = [currentItem valueForProperty: MPMediaItemPropertyArtwork];
    if (artwork) {
        artworkImage = [artwork imageWithSize:CGSizeMake(self.imageView.frame.size.width, self.imageView.frame.size.width)];
    }
    self.imageView.image = artworkImage;
    NSString *title = [currentItem valueForProperty:MPMediaItemPropertyTitle];
    if (title) {
        self.musicTitleLabel.text = title;
    } else{
        self.musicTitleLabel.text = @"Unknown title";
    }
}

- (void) handle_PlaybackStateChanged: (id) notification
{
    MPMusicPlaybackState playbackState = [self.musicPlayer playbackState];
    if (playbackState == MPMusicPlaybackStatePaused) {
        [self.playButton setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
        
        
	} else if (playbackState == MPMusicPlaybackStatePlaying) {
        [self.playButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
        
	} else if (playbackState == MPMusicPlaybackStateStopped) {
        [self.playButton setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
		[self.musicPlayer stop];
        
	}
}

#pragma mark - Control
- (IBAction)playPause:(id)sender {
    if ([self.musicPlayer playbackState] == MPMusicPlaybackStatePlaying) {
        [self.musicPlayer pause];
    } else {
        [self.musicPlayer play];
    }
}

- (IBAction)lastMusic:(id)sender {
    [self.musicPlayer skipToPreviousItem];
    
}

- (IBAction)nextMusic:(id)sender {
    [self.musicPlayer skipToNextItem];
}





#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self setRoundedView:self.imageView];
    self.musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
    self.musicPlayer.repeatMode = MPMusicRepeatModeAll;
    if ([self.musicPlayer playbackState] == MPMusicPlaybackStatePlaying){
        [self.playButton setImage:[UIImage imageNamed:@"pause" ] forState:UIControlStateNormal];
    }else{
        [self.playButton setImage:[UIImage imageNamed:@"play" ] forState:UIControlStateNormal];
    }
    [self registerForMediaPlayerNotifications];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}
@end
