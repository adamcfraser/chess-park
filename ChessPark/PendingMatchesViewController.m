//
//  PendingMatchesViewController.m
//  ChessPark
//
//  Created by Adam Fraser on 10/2/14.
//  Copyright (c) 2014 Adam Fraser. All rights reserved.
//

#import "PendingMatchesViewController.h"
#import "Match.h"

@interface PendingMatchesViewController () {

    Match *selectedMatch;
    
}
@end

@implementation PendingMatchesViewController

static int const CREATE_ALERT_TAG = 1;
static int const JOIN_ALERT_TAG = 2;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                               target:self
                                                                               action:@selector(createNewMatch:)];
    
    self.navigationItem.rightBarButtonItem = addButton;
}

// Handles a command to create a new match
- (IBAction) createNewMatch: (id)sender {
    UIAlertView* alert= [[UIAlertView alloc] initWithTitle:@"New Match"
                                                   message:@"Name:"
                                                  delegate:self
                                         cancelButtonTitle:@"Cancel"
                                         otherButtonTitles:@"Create", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.tag = CREATE_ALERT_TAG;
    [alert show];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSString*) getLocalMatchType {
    return @"waiting";
}

//todo call this from the table view
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    CBLQueryRow *row = [self.dataSource rowAtIndex:indexPath.row];
    Match* match = [Match modelForDocument:row.document];
    
    if ([match.ownerId isEqualToString: self.app.username]) {
        // this is my own game - can't join
        NSLog(@"Can't join your own match");
        return;
    } else {
        NSString *joinMessage = [NSString stringWithFormat:@"Do you want to join match %@?", match.name];
        UIAlertView* alert= [[UIAlertView alloc] initWithTitle:@"Join Match"
                                                       message:joinMessage
                                                      delegate:self
                                             cancelButtonTitle:@"Cancel"
                                             otherButtonTitles:@"Join", nil];
        alert.tag = JOIN_ALERT_TAG;
        alert.alertViewStyle = UIAlertViewStyleDefault;
        selectedMatch= match;
        [alert show];
        
    }
    
    
    
}

// Completion routine for the new match alert.
- (void)alertView:(UIAlertView *)alert didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    switch(alert.tag) {
        case CREATE_ALERT_TAG:
            if (buttonIndex > 0) {
                NSString* name = [alert textFieldAtIndex: 0].text;
                if (name.length > 0) {
                    [self createMatchWithName: name];
                }
            }
            break;
        case JOIN_ALERT_TAG:
            if (buttonIndex > 0) {
                [selectedMatch joinMatch:self.app.username];
            }
    
    }
   
}

- (void)couchTableSource:(CBLUITableSource*)source
             willUseCell:(UITableViewCell*)cell
                  forRow:(CBLQueryRow*)row
{
    
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.textLabel.font = [UIFont fontWithName: @"Helvetica" size:20.0];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    
}
 


@end
