//
//  ActiveGamesViewController.m
//  ChessPark
//
//  Created by Adam Fraser on 9/29/14.
//  Copyright (c) 2014 Adam Fraser. All rights reserved.
//

#import "AppDelegate.h"
#import "MatchesViewController.h"
#import "MatchViewController.h"
#import "Match.h"
#import <CouchbaseLite/CouchbaseLite.h>

@interface MatchesViewController () {
    CBLDatabase *database;
}
@end

@implementation MatchesViewController
{
    IBOutlet UITableView *tableView;
    IBOutlet UITabBarItem *pendingTabItem;
    CBLLiveQuery *query;
    MatchViewController *activeMatchViewController;

}


- (void)viewDidLoad {
    [super viewDidLoad];
   
    _app = [[UIApplication sharedApplication] delegate];
    database = _app.database;
    
    NSAssert(_dataSource, @"_dataSource not connected");
    
    // set up match query
    query =[Match matchQuery:database forStatus:self.getLocalMatchType].asLiveQuery;
    
    _dataSource.query= query;
    _dataSource.labelProperty = @"name";
    
}

// Queries all matches
- (IBAction) queryAllMatches: (id)sender {
    
    //CBLQuery* query = [database createAllDocumentsQuery];
    
    CBLQuery* allMatchQuery = [Match matchQuery: database forStatus: self.getLocalMatchType];
    NSError *error;
    CBLQueryEnumerator *rowEnum = [allMatchQuery run: &error];
    for (CBLQueryRow* row in rowEnum) {
        NSLog(@"Doc ID=%@ %@", row.key, row.value);
    }
    
}

// Completion routine for the new-list alert.
- (void)alertView:(UIAlertView *)alert didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex > 0) {
        NSString* name = [alert textFieldAtIndex: 0].text;
        if (name.length > 0) {
            [self createMatchWithName: name];
        }
    }
}

// Create match
- (Match *)createMatchWithName:(NSString*)name {
    Match *match = [[Match alloc] initInDatabase: database withName: name forUser: _app.username];
    
    NSError* error;
    if (![match save: &error]) {
        UIAlertView* alert= [[UIAlertView alloc] initWithTitle:@"Error"
                                                       message:@"Cannot create a new match."
                                                      delegate:nil
                                             cancelButtonTitle:@"Ok"
                                             otherButtonTitles:nil];
        [alert show];
        return nil;
    }
    
    return match;
}

//todo call this from the table view
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"showMatch" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showMatch"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        CBLQueryRow *row = [self.dataSource rowAtIndex:indexPath.row];
        Match* match = [Match modelForDocument: row.document];
        activeMatchViewController = (MatchViewController *)[segue destinationViewController];
        [activeMatchViewController initMatch:match];
        activeMatchViewController.parentQuery = query;
        // liveQuery
        
        self.navigationItem.backBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    }
}

- (IBAction)unwindToMatchList:(UIStoryboardSegue *)segue
{
    [query removeObserver:activeMatchViewController forKeyPath:@"rows"];
    
}

-(NSString*) getLocalMatchType {
    return @"active";
}

- (void)couchTableSource:(CBLUITableSource*)source
             willUseCell:(UITableViewCell*)cell
                  forRow:(CBLQueryRow*)row
{
    
    Match* match = [Match modelForDocument: row.document];
    
    if ([match.currentPlayerId isEqualToString: self.app.username]) {
        // set 'your turn'/'their turn' icons here
        [cell setBackgroundColor:[UIColor lightGrayColor]];
        cell.detailTextLabel.text = @"Waiting for opponent";
    
    } else {
        [cell setBackgroundColor:[UIColor clearColor]];
        cell.detailTextLabel.text = @"Your Turn";
    }
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
        
    cell.textLabel.font = [UIFont fontWithName: @"Helvetica" size:20.0];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    /*
    if (match.document.documentID == activeMatchViewController.match.document.documentID) {
        [activeMatchViewController updateBoard];
    }
     */
    
    
}


@end
