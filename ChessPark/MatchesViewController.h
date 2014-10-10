//
//  ActiveGamesViewController.h
//  ChessPark
//
//  Created by Adam Fraser on 9/29/14.
//  Copyright (c) 2014 Adam Fraser. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Couchbaselite/CBLUITableSource.h>
#import "AppDelegate.h"
#import "Match.h"

@interface MatchesViewController : UITableViewController <CBLUITableDelegate>

@property (nonatomic) IBOutlet CBLUITableSource* dataSource;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) AppDelegate *app;



- (IBAction)unwindToMatchList:(UIStoryboardSegue *)segue;

// define match type used by query definition
-(NSString*) getLocalMatchType;

// creates match
-(Match *)createMatchWithName:(NSString*)name;

@end
