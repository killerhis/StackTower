//
//  GameViewController.m
//  LEOPROJECTS
//
//  Created by LEO on 6/26/14.
//  Copyright (c) 2014 LEO. All rights reserved.
//

#define MAIN_WIDTH  self.view.frame.size.width
#define MAIN_HEIGHT self.view.frame.size.height
#define IS_IPAD UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad


#import "GameViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "defined.h"
#import "UIView+Hierarchy.h"
#import "Helper.h"


#import "Chartboost.h"
#import "CBNewsfeed.h"
#import "CBPostInstallAnalyticsTracker.h"

AVAudioPlayer  *SpectacularAudio;
AVAudioPlayer  *BrickAudio;
AVAudioPlayer  *MainAudio;

@interface GameViewController ()
@property ( nonatomic , strong )  id displayLink;
@property ( nonatomic , assign ) float vx;
@property ( nonatomic , assign ) float vy;
@property ( nonatomic , assign ) float friction;
@property ( nonatomic , assign ) bool upNow;
@property ( nonatomic , assign ) bool allowedToStart;
@property ( nonatomic , assign ) float power;
@property ( nonatomic , assign ) int score;
@property ( nonatomic , strong ) AVAudioPlayer  *pop;
@property ( nonatomic , strong ) AVAudioPlayer  *boob;

@property ( nonatomic , assign ) bool HasItSound;
@property ( nonatomic , assign ) bool typeOfBlock;


@property (strong, nonatomic)  NSString *defaultBlockName;
@property (strong, nonatomic)  NSString *movingBlockName;
@property ( nonatomic , assign ) int iPadMulti;


@property (strong, nonatomic)  UIImageView *resBlock;

@property ( nonatomic , strong ) NSMutableArray *collection;

@property (strong, nonatomic)  NSString *deviceType;



@end

@implementation GameViewController


-(void) checkDeviceTypeIsiPadOrIphone
{
    if ( IS_IPAD)
    {
        NSLog(@"an iPad Deviced has been detected");
        
        _vx = 0;
        _vy = 0;
        _friction = 0.95;
        _power = 3;
        _score = 0;
        _allowedToStart = YES;
        
        _defaultBlockName = @"defBlock_iPad";
        _movingBlockName = @"block_iPad";
        _iPadMulti = 2;
        [_ScoreText setFont:[UIFont fontWithName:@"Minecrafter" size:80]];
        
        _deviceType = @"iPad";
        
        _typeOfBlock = NO;
    } else
    {
        NSLog(@"an iPhone/iPod Deviced has been detected");
        
        
        _vx = 0;
        _vy = 0;
        _friction = 0.95;
        _power = 1.5;
        _score = 0;
        _iPadMulti = 1;
        
        _allowedToStart = YES;
        _defaultBlockName = @"defBlock_iPhone";
        _movingBlockName = @"block_iPhone";
        
        [_ScoreText setFont:[UIFont fontWithName:@"Minecrafter" size:30]];
        _deviceType = @"iPhone";
        
        _typeOfBlock = NO;
        
    }
    
    _power*=-1;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // GA
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"GameScene"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    tracker.allowIDFACollection = NO;
    
    [self checkDeviceTypeIsiPadOrIphone];
    srand( (unsigned int) time(NULL) );
    
    
    _collection = [[NSMutableArray alloc] init];
    
    
    [self prepareBlocks];
    
    
    
    
    if ( [[[NSUserDefaults standardUserDefaults] stringForKey:@"soundsStatuss"] intValue] == 0 ){
        _HasItSound = YES;
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"po" ofType:@"mp3"];
        
        _pop =[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:NULL];
        
        [_pop.delegate self];
        [_pop prepareToPlay];
        
        path = [[NSBundle mainBundle] pathForResource:@"boob" ofType:@"mp3"];
        
        _boob =[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:NULL];
        
        [_boob.delegate self];
        [_boob prepareToPlay];
        
        
        
    }
    
    
    Helper *hlp = [[Helper alloc] init];
    BOOL status = [[hlp getStringFromFile:@"settings.plist" What:@"ADS"] boolValue];
    if (! status)
    {
        NSLog(@"there is ADS =  %i",status);
        [self adMobSetup];
        [self.adBanner setHidden:NO];
        //[_iAdBannerView setHidden:YES];
    }
    
    if ( _allowedToStart)
    {
        [self startLoop];
        _allowedToStart = !_allowedToStart;
    }
    
    
    
}

-(void) prepareBlocks
{
    [_collection removeAllObjects];
    
    
    UIImageView *default_Block = [[UIImageView alloc] initWithImage:[UIImage imageNamed:_defaultBlockName]] ;
    [default_Block setCenter:CGPointMake(MAIN_WIDTH/2, MAIN_HEIGHT - (150*_iPadMulti))];
    [self.view addSubview:default_Block];
    
    
    [default_Block setImage:[UIImage imageNamed:_defaultBlockName]];
    
    [default_Block setTag:1];
    
    UIImageView *Moving_Block = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 171 * _iPadMulti, 30*_iPadMulti)];
    [Moving_Block setCenter:CGPointMake(default_Block.center.x  ,  default_Block.center.y - default_Block.frame.size.height/2 - (Moving_Block.frame.size.height/2))];
    [self.view addSubview:Moving_Block];
    
    [Moving_Block setImage:[UIImage imageNamed:_movingBlockName]];
    
    [Moving_Block setTag:1];
    
    
    [_collection addObject:default_Block];
    [_collection addObject:Moving_Block];
    
}

-(void) setValues
{
    _vx = 0;
    _vy = 0;
    _friction = 0.94;
    _power = .1;
    _score = 0;
    _allowedToStart = YES;
    
}

-(void) startLoop

{
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(MainLoop)];
    [_displayLink setFrameInterval:1];
    [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}


-(void) MainLoop
{
    UIImageView *one = [_collection lastObject];
    
    UIImageView *sec = [_collection firstObject];
    
    
    if ( one.frame.size.width < 4*_iPadMulti) {
        [self GameOver];
    }
    
    
    if ( sec.center.x < one.center.x)
    {
        
        [_resBlock setFrame:CGRectMake(0, 0,  one.center.x - sec.center.x , 30 *_iPadMulti)];
        
        [_resBlock setCenter:CGPointMake( one.center.x + (_resBlock.frame.size.width*1.2)  , sec.center.y - sec.frame.size.height)];
        
    }     else{
        
        [_resBlock setFrame:CGRectMake(0, 0,  one.center.x - sec.center.x , 30*_iPadMulti)];
        
        [_resBlock setCenter:CGPointMake( one.center.x - (_resBlock.frame.size.width*1.2)  , sec.center.y - sec.frame.size.height)];
        
        
    }
    
    
    if ( one.center.x < one.frame.size.width/2  )
    {
        //[self earthquake:self.view];
        _power*=-1;
        
    }
    
    if (  one.center.x > MAIN_WIDTH - one.frame.size.width/2 )
    {
        // [self earthquake:self.view];
        _power*=-1;
        
        
        
        
    }
    
    
    
    if(_upNow) {
        _vx -= .2*_iPadMulti;
    }
    
    
    
    _vx += .7*_iPadMulti;
    
    _vx *= _friction;
    
    one.center = CGPointMake(one.center.x + _power, one.center.y );

}

-(void) ResetEveryThings
{
    // GA
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"GameScene"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    tracker.allowIDFACollection = NO;
    
    UIImageView *one = [_collection lastObject];
    
    one.center = CGPointMake(MAIN_WIDTH / 2, MAIN_HEIGHT/2);
    
    
    NSArray *tempToGetObj = self.view.subviews;
    
    for ( UIImageView *obs in tempToGetObj)
    {
        if ([obs isKindOfClass:[UIImageView class]] && obs.tag == 1 )
        {
            [obs removeFromSuperview];
        }
    }
    
    
    
    
    _score = 0;
    [_ScoreText setText:@"0"];
    _allowedToStart = YES;
    _typeOfBlock = NO;
    
    if ( IS_IPAD) {
        _vx = 0;
        _vy = 0;
        _friction = 0.95;
        _power = 3;
    } else {
        _vx = 0;
        _vy = 0;
        _friction = 0.94;
        _power = 1.5;
    }

    
    [_ScoreText sendToBack];
    [_ScoreText bringOneLevelUp];
    
    
    [self prepareBlocks];
    
    
    
    Helper *hlp = [[Helper alloc] init];
    BOOL status = [[hlp getStringFromFile:@"settings.plist" What:@"ADS"] boolValue];
    if (! status)
    {
        
        //[_iAdBannerView setHidden:YES];
        [self.adBanner setHidden:NO];
        [self.adBanner bringToFront];
        
        
    }
    [_GameOverView setHidden:YES];
    
    if ( _allowedToStart)
    {
        [self startLoop];
        _allowedToStart = !_allowedToStart;
    }
    
}

-(void) GameOver
{
    // GA
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"GameOverScene"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    tracker.allowIDFACollection = NO;
    
    [_displayLink invalidate];
    [_GameOverView setHidden:NO];
    [_GameOverView bringToFront];
    NSLog(@"GameOver has been occured");
    
    [self reportHighScore:_score forLeaderboardId:k_game_center_domain];
    
    if ( [[[NSUserDefaults standardUserDefaults] stringForKey:@"score"] intValue] <_score ){
        
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:_score] forKey:@"score"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
    
    
    
    
    Helper *hlp = [[Helper alloc] init];
    BOOL status = [[hlp getStringFromFile:@"settings.plist" What:@"ADS"] boolValue];
    if (! status)
    {
        [[Chartboost sharedChartboost] showInterstitial:CBLocationHomeScreen];
        
        //[_iAdBannerView bringToFront];
        //[_iAdBannerView setHidden:NO];
        //[self.adBanner setHidden:YES];
        [self.adBanner setHidden:NO];
        
        
    }
    
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    
    _upNow = NO;
    
    if ( _allowedToStart)
    {
        [self startLoop];
        _allowedToStart = !_allowedToStart;
    }
    [_GameOverView bringToFront];
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.adBanner bringToFront];
    _upNow = YES;
    
    //if ( _HasItSound) {    [_pop play];}
    
    if (_GameOverView.hidden == YES)
    {
        
        UIImageView *one = [_collection lastObject];
        UIImageView *two = [_collection objectAtIndex:_collection.count - 2];
        
        
        
        
        two.tag = 1;
        one.tag = 1;
        if ( two.center.x < one.center.x)
        {
            
            _resBlock = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0,  one.center.x - two.center.x , 30*_iPadMulti)];
            [_resBlock setCenter:CGPointMake( one.center.x + _resBlock.center.x + _resBlock.frame.size.width  , two.center.y - two.frame.size.height)];
            [_resBlock setBackgroundColor:[UIColor yellowColor]];
            
        }     else{
            
            _resBlock = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, two.center.x - one.center.x  , 30*_iPadMulti)];
            [_resBlock setCenter:CGPointMake( two.center.x - _resBlock.center.x +_resBlock.frame.size.width  , two.center.y - two.frame.size.height)];
            [_resBlock setBackgroundColor:[UIColor yellowColor]];
            
            
        }
        
        if (_resBlock.frame.size.width > one.frame.size.width)
        {
            [self GameOver];
            NSLog(@"GameOver has been occurd becuase becuase of ><");
            
        }
        
        
        
        
        CGPoint loc = one.center;
        
        
        if ( two.center.x > one.center.x)
        {
            [one setFrame:CGRectMake(one.center.x , one.center.y, one.frame.size.width - _resBlock.frame.size.width, 30*_iPadMulti)];
            [one setCenter:CGPointMake(loc.x + (_resBlock.frame.size.width/2), loc.y)];
            NSLog(@" Temp > temp2");
            
            UIImageView *tt = [[UIImageView alloc] initWithFrame:_resBlock.frame];
            [tt setImage:one.image];
            [self.view addSubview:tt];
            [tt setAlpha:.7];
            
            [tt setCenter:one.center];
            [tt setCenter:CGPointMake(tt.center.x - ( one.frame.size.width/2) -( _resBlock.frame.size.width/2), one.center.y)];
            
            
            [UIView animateWithDuration:1.0  delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^
             {
                 
                 [tt setCenter:CGPointMake(tt.center.x , tt.center.y + MAIN_HEIGHT)];
                 tt.transform = CGAffineTransformMakeRotation(180 / M_PI * 90);
                 
             }
                             completion:^(BOOL finished){
                                 
                                 
                                 [tt removeFromSuperview];
                                 
                             }];
            
            
        } else
        {
            [one setFrame:CGRectMake(one.center.x , one.center.y, one.frame.size.width - _resBlock.frame.size.width, 30*_iPadMulti)];
            [one setCenter:CGPointMake(loc.x - (_resBlock.frame.size.width/2), loc.y)];
            NSLog(@" Temp < temp2");
            
            
            
            UIImageView *tt = [[UIImageView alloc] initWithFrame:_resBlock.frame];
            [tt setImage:one.image];
            [self.view addSubview:tt];
            [tt setAlpha:.7];
            [tt setCenter:one.center];
            [tt setCenter:CGPointMake(tt.center.x + ( one.frame.size.width/2) +( _resBlock.frame.size.width/2), one.center.y)];
            
            
            [UIView animateWithDuration:1.0  delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^
             {
                 
                 [tt setCenter:CGPointMake(tt.center.x , tt.center.y + MAIN_HEIGHT)];
                 tt.transform = CGAffineTransformMakeRotation(180 / M_PI * 90);
                 
             }
                             completion:^(BOOL finished){
                                 
                                 
                                 [tt removeFromSuperview];
                                 
                             }];
            
            
        }
        
        
        
        if (!_allowedToStart)
        {
            
            [self checkQuality:_resBlock];
        }
        
        
        _typeOfBlock = !_typeOfBlock;
        
        if (!_typeOfBlock)
        {
            [one setImage:nil];
            [one setImage:[UIImage imageNamed:[NSString stringWithFormat:@"block2_%@",_deviceType]]];
            
            //           [one setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Block_iPhone"]]];
            NSLog(@"ONE");
        }
        
        if ( !_allowedToStart)
        {
            UIImageView * temps = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, one.frame.size.width, 30*_iPadMulti)];
            
            if ([self getRandomNumberBetween:1 maxNumber:8] > 4 )
            {
                //[temps setCenter:CGPointMake(MAIN_WIDTH - temps.frame.size.width , one.center.y - one.frame.size.height)];
                [temps setCenter:CGPointMake(MAIN_WIDTH - temps.frame.size.width/2 , one.center.y - one.frame.size.height)];
                
            } else
            {
                //[temps setCenter:CGPointMake( temps.frame.size.width , one.center.y - one.frame.size.height)];
                [temps setCenter:CGPointMake( temps.frame.size.width/2 , one.center.y - one.frame.size.height)];
                
            }
            
            
            
            [temps setImage:[UIImage imageNamed:_movingBlockName]];
            [temps setTag:1];
            
            
            
            [self.view addSubview:temps];
            [_collection addObject:temps];
            
            
            _score++;
            [_ScoreText setText:[NSString stringWithFormat:@"%i",_score]];
            
            [self nextLevel];
            
            if  ( one.center.y < MAIN_HEIGHT / 3)
            {
                [self scrollDown];
            }
        }
    }
    
    
}



-(void) checkQuality:(UIImageView*) img
{
    NSLog(@"check quality");
    
    if ( _GameOverView.hidden == YES)
    {
        
        if (img.frame.size.width <= 5 && img.frame.size.width >= 0)
        {
            NSLog(@"Spectacular");
            
            UIImageView *tt = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"spectacular_%@",_deviceType]]];
            tt.alpha = 0.0;
            [self.view addSubview:tt];
            //[tt setCenter:CGPointMake(MAIN_WIDTH/2, -200)];
            [tt setCenter:CGPointMake(MAIN_WIDTH/2, (tt.frame.size.height*2))];
            
            [self playSpectacularAudio];
            
            [UIView animateWithDuration:.1  delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^
             {
                 
                 //[tt setCenter:CGPointMake(tt.center.x , (tt.frame.size.height*2) )];
                 tt.alpha = 1.0;
                 
             }
                             completion:^(BOOL finished){
                                 
                                 
                                 [UIView animateWithDuration:.9  delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^
                                  {
                                      tt.alpha = 0.0;
                                      //[tt setCenter:CGPointMake(tt.center.x , -(tt.frame.size.height*2) )];
                                      
                                  }
                                                  completion:^(BOOL finished){
                                                      
                                                      
                                                      [tt removeFromSuperview];
                                                      
                                                  }];
                                 
                             }];
            
            
            
            
        } else if ( img.frame.size.width <= 20 && img.frame.size.width >= 6)
        {
            UIImageView *tt = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"amazing_%@",_deviceType]]];
            tt.alpha = 0.0;
            [self.view addSubview:tt];
            //[tt setCenter:CGPointMake(MAIN_WIDTH/2, -200)];
            [tt setCenter:CGPointMake(MAIN_WIDTH/2, (tt.frame.size.height*2))];
            
            [self playBrickAudio];
            
            [UIView animateWithDuration:.1  delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^
             {
                 tt.alpha = 1.0;
                 //[tt setCenter:CGPointMake(tt.center.x , (tt.frame.size.height*2) )];
                 
             }
                             completion:^(BOOL finished){
                                 
                                 
                                 [UIView animateWithDuration:.9  delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^
                                  {
                                      tt.alpha = 0.0;
                                      //[tt setCenter:CGPointMake(tt.center.x , -(tt.frame.size.height*2) )];
                                      
                                  }
                                                  completion:^(BOOL finished){
                                                      
                                                      
                                                      [tt removeFromSuperview];
                                                      
                                                  }];
                                 
                             }];
            
        }else if ( img.frame.size.width <= 30 && img.frame.size.width >= 21)
        {
            UIImageView *tt = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"good_%@",_deviceType]]];
            tt.alpha = 0.0;
            [self.view addSubview:tt];
            //[tt setCenter:CGPointMake(MAIN_WIDTH/2, -200)];
            [tt setCenter:CGPointMake(MAIN_WIDTH/2, (tt.frame.size.height*2))];
            
            [self playBrickAudio];
            
            [UIView animateWithDuration:.1  delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^
             {
                 tt.alpha = 1.0;
                 //[tt setCenter:CGPointMake(tt.center.x , (tt.frame.size.height*2) )];
                 
             }
                             completion:^(BOOL finished){
                                 
                                 
                                 [UIView animateWithDuration:.9  delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^
                                  {
                                      tt.alpha = 0.0;
                                      //[tt setCenter:CGPointMake(tt.center.x , -(tt.frame.size.height*2) )];
                                      
                                  }
                                                  completion:^(BOOL finished){
                                                      
                                                      
                                                      [tt removeFromSuperview];
                                                      
                                                  }];
                                 
                             }];
            
        } else {
            [self playBrickAudio];
        }
        
    }
}

-(void) scrollDown
{
    [UIView animateWithDuration:.3  delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^
     {
         for ( int i = 0 ; i < _collection.count ;i++)
         {
             [[_collection objectAtIndex:i] setCenter:CGPointMake([[_collection objectAtIndex:i] center].x, [[_collection objectAtIndex:i] center].y + (30*_iPadMulti))];
         }
     }
                     completion:^(BOOL finished){ }];
}

- (void)earthquake:(UIView*)itemView
{
    
    CGFloat t = 4.0;
    
    CGAffineTransform leftQuake  = CGAffineTransformTranslate(CGAffineTransformIdentity, t, -t);
    CGAffineTransform rightQuake = CGAffineTransformTranslate(CGAffineTransformIdentity, -t, t);
    
    itemView.transform = leftQuake;  // starting point
    
    [UIView beginAnimations:@"earthquake" context:(__bridge void *)(itemView)];
    [UIView setAnimationRepeatAutoreverses:YES]; // important
    [UIView setAnimationRepeatCount:3];
    [UIView setAnimationDuration:0.05];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(earthquakeEnded:finished:context:)];
    
    itemView.transform = rightQuake; // end here & auto-reverse
    
    [UIView commitAnimations];
    
    
    
    
}

- (void)earthquakeEnded:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    if ([finished boolValue])
    {
        UIView* item = (__bridge UIView *)context;
        item.transform = CGAffineTransformIdentity;
    }
}


- (IBAction)PlayIt {
    
    [self ResetEveryThings];
    
}

- (IBAction)CloseIt {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)ShareIt {
    
    NSString * text = [NSString stringWithFormat:@"My time Is %li In jump", (long)_score];
    UIImage * image = [UIImage imageNamed:@"rc.png"];
    NSArray * activityItems = @[text, image];
    UIActivityViewController * avc = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    avc.excludedActivityTypes = @[ UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll];
    
    [self presentViewController:avc animated:YES completion:nil];
    
    
}

- (void) reportHighScore:(NSInteger) highScore forLeaderboardId:(NSString*) leaderboardId {
    if ([GKLocalPlayer localPlayer].isAuthenticated) {
        GKScore* scores = [[GKScore alloc] initWithLeaderboardIdentifier:leaderboardId];
        scores.value = highScore;
        [GKScore reportScores:@[scores] withCompletionHandler:^(NSError *error) {
            if (error) {
                NSLog(@"error: %@", error);
            }
        }];
    }
}

- (NSInteger)getRandomNumberBetween:(NSInteger)min maxNumber:(NSInteger)max
{
    return min + arc4random() % (max - min + 1);
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationMaskPortrait );
}

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}


- (void) adMobSetup
{
    NSLog(@"AdMob has been requested");
    
    CGPoint origin = CGPointMake(0.0,
                                 self.view.frame.size.height -
                                 CGSizeFromGADAdSize(kGADAdSizeSmartBannerPortrait).height);
    
    // Use predefined GADAdSize constants to define the GADBannerView.
    self.adBanner = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait origin:origin];
    
    self.adBanner.adUnitID = k_adMob_ID;
    self.adBanner.delegate = self;
    self.adBanner.rootViewController = self;
    [self.view addSubview:self.adBanner];
    [self.adBanner loadRequest:[self request]];
    
}
- (GADRequest *)request {
    GADRequest *request = [GADRequest request];
    
    // Make the request for a test ad. Put in an identifier for the simulator as well as any devices
    // you want to receive test ads.
    
    // comment this line when you add your sign and want to upload on the appstore
    request.testDevices = @[GAD_SIMULATOR_ID];
    return request;
}


- (void)adViewDidReceiveAd:(GADBannerView *)adView {
    NSLog(@"Received ad successfully");
}

- (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"Failed to receive ad with error: %@", [error localizedFailureReason]);
}

-(void) viewDidAppear:(BOOL)animated
{
    Helper *hlp = [[Helper alloc] init];
    BOOL status = [[hlp getStringFromFile:@"settings.plist" What:@"ADS"] boolValue];
    if (! status)
    {
        
        [self.adBanner loadRequest:[self request]];
    }
}

- (IBAction)rateIt {
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:k_OPEN_LINK_FOR_RATING]];
}

- (void)playBrickAudio
{
    NSLog(@"*** PLAY BRICK SOUND ***");
    
    if (_HasItSound) {
        NSInteger number = [self getRandomNumberBetween:1 maxNumber:3];
        NSString *soundFileName = [NSString stringWithFormat:@"brick%li", (long)number];
        
        NSString *path = [[NSBundle mainBundle] pathForResource:soundFileName ofType:@"mp3"];
        
        BrickAudio =[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:NULL];
        
        [BrickAudio.delegate self];
        [BrickAudio play];
    }
}

- (void)playSpectacularAudio
{
    if (_HasItSound) {
        NSInteger number = [self getRandomNumberBetween:1 maxNumber:4];
        NSString *soundFileName = [NSString stringWithFormat:@"sound%li", (long)number];
        
        NSString *path = [[NSBundle mainBundle] pathForResource:soundFileName ofType:@"mp3"];
        
        SpectacularAudio =[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:NULL];
        
        [SpectacularAudio.delegate self];
        [SpectacularAudio play];
    }
}

- (void)nextLevel
{
    if (_score % 4 == 0) {
        
        if (_power >= 0) {
            _power = _power + (0.3*_iPadMulti);
        } else {
            _power = _power - (0.3*_iPadMulti);
        }
        
    }
}

@end
