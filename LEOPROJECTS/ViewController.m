//
//  ViewController.m
//  LEOPROJECTS
//
//  Created by LEO on 6/25/14.
//  Copyright (c) 2014 LEO. All rights reserved.
//

#import "ViewController.h"
#import "Helper.h"
#import "defined.h"
#define IS_IPAD UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad

AVAudioPlayer  *MainAudio;

@interface ViewController ()

@end

@implementation ViewController
bool firstOne = YES;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // GA
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"StartScene"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    tracker.allowIDFACollection = NO;
    
    Helper * DataBaseHelper = [[Helper alloc] init];
    [DataBaseHelper makeFileWithName:@"settings.plist" andWriteToIt:[DataBaseHelper settings]];

        if ( IS_IPAD)
        {
            NSLog(@"an iPad Deviced has been detected");
                        [_score setFont:[UIFont fontWithName:@"Minecrafter" size:80]];
            
            
        } else
        {
            NSLog(@"an iPhone/iPod Deviced has been detected");
            
            
                      [_score setFont:[UIFont fontWithName:@"Minecrafter" size:30]];
        }

    
    [_score setText: [[NSUserDefaults standardUserDefaults] stringForKey:@"score"]];

    
    if ( firstOne )
    {
        //NSString *path = [[NSBundle mainBundle] pathForResource:@"MainMusic" ofType:@"mp3"];
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Music2" ofType:@"mp3"];
        
        MainAudio =[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:NULL];
        
        MainAudio.numberOfLoops = -1;
        [MainAudio.delegate self];
        [MainAudio play];
        firstOne = NO;
        NSLog(@"First One");
        
    }
    
    
    if ( [[[NSUserDefaults standardUserDefaults] stringForKey:@"soundsStatuss"] intValue] == 0 ){
        
        [_soundONOFF setAlpha:1];
        
    } else if ( [[[NSUserDefaults standardUserDefaults] stringForKey:@"soundsStatuss"] intValue] == 1 )
    {
        [_soundONOFF setAlpha:.5];
        [MainAudio setVolume:0.0];
    }


	// Do any additional setup after loading the view, typically from a nib.
}

-(void) viewDidAppear:(BOOL)animated
{
    [_score setText: [[NSUserDefaults standardUserDefaults] stringForKey:@"score"]];
    
    Helper *hlp = [[Helper alloc] init];
    int saved =   [[hlp getStringFromFile:@"settings.plist" What:@"ADS"] intValue];
    
    
    if (saved)
    {
        
        [_AdsButton setEnabled:NO];
        
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)openGameCenter {
    GKGameCenterViewController  *gameCenterController = [[GKGameCenterViewController alloc] init];
    if ( gameCenterController != nil)
    {
        gameCenterController.viewState = GKGameCenterViewControllerStateLeaderboards;
        gameCenterController.gameCenterDelegate = self;
        
        UIViewController *vc = self.view.window.rootViewController;
        [vc presentViewController: gameCenterController animated: YES completion:nil];
    }

    
}

-(void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    [gameCenterViewController dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)checkSoundONOFF {
    
    
    if ( [[[NSUserDefaults standardUserDefaults] stringForKey:@"soundsStatuss"] intValue] == 0 ){
        
        [_soundONOFF setAlpha:.5];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:1] forKey:@"soundsStatuss"];
        [MainAudio setVolume:0.0];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
    else if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"soundsStatuss"] intValue] == 1)
    {
        [_soundONOFF setAlpha:1];
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:0] forKey:@"soundsStatuss"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [MainAudio setVolume:1.0];
        
    }

    
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationMaskPortrait );
}

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}
- (IBAction)rateIt {
     [[UIApplication sharedApplication] openURL:[NSURL URLWithString:k_OPEN_LINK_FOR_RATING]];
}
@end
