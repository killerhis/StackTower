//
//  AppDelegate.h
//  LEOPROJECTS
//
//  Created by LEO on 6/25/14.
//  Copyright (c) 2014 LEO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property ( strong , nonatomic) GKLocalPlayer *localPlayer;

@end
