//
//  AppDelegate.h
//  LEOPROJECTS
//
//  Created by LEO on 6/25/14.
//  Copyright (c) 2014 LEO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import "Promo.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property ( strong , nonatomic) GKLocalPlayer *localPlayer;
@property (strong, nonatomic) NSNumber *appID;
@property (strong, nonatomic) Promo *promo;
@end
