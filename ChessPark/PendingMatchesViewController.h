//
//  PendingMatchesViewController.h
//  ChessPark
//
//  Created by Adam Fraser on 10/2/14.
//  Copyright (c) 2014 Adam Fraser. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Couchbaselite/CBLUITableSource.h>
#import "MatchesViewController.h"

@interface PendingMatchesViewController : MatchesViewController <CBLUITableDelegate>

// override for match type used by query definition
-(NSString*) getLocalMatchType;

@end
