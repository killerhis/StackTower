//
//  GameViewController.h
//  LEOPROJECTS
//
//  Created by LEO on 6/26/14.
//  Copyright (c) 2014 LEO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import <AVFoundation/AVFoundation.h>

#import "GADBannerView.h"
#import "GADRequest.h"
@class GADBannerView;
@class GADRequest;

@interface GameViewController : UIViewController <GADBannerViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *GameOverView;
- (IBAction)PlayIt;
- (IBAction)CloseIt;
- (IBAction)ShareIt;
@property(nonatomic, strong) GADBannerView *adBanner;

- (GADRequest *)request;

//@property (weak, nonatomic) IBOutlet ADBannerView *iAdBannerView;

@property (weak, nonatomic) IBOutlet UILabel *ScoreText;

@end
