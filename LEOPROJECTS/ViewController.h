//
//  ViewController.h
//  LEOPROJECTS
//
//  Created by LEO on 6/25/14.
//  Copyright (c) 2014 LEO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController : UIViewController <GKGameCenterControllerDelegate>
- (IBAction)openGameCenter;
@property (weak, nonatomic) IBOutlet UIButton *soundONOFF;
- (IBAction)checkSoundONOFF;
@property (weak, nonatomic) IBOutlet UILabel *score;
- (IBAction)rateIt;
@property (weak, nonatomic) IBOutlet UIButton *AdsButton;

@end
