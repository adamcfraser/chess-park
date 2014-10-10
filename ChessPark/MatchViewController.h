//
//  MatchViewController.h
//  ChessPark
//
//  Created by Adam Fraser on 10/1/14.
//  Copyright (c) 2014 Adam Fraser. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Match.h"
#import "AppDelegate.h"

@interface MatchViewController : UIViewController

@property (strong, nonatomic) Match *match;
@property (strong, nonatomic) AppDelegate *app;
@property (strong, nonatomic) CBLLiveQuery *parentQuery;

- (void) initMatch:(Match *)match;

- (void) updateBoard;

@end
