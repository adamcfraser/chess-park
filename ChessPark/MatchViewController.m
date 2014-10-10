//
//  MatchViewController.m
//  ChessPark
//
//  Created by Adam Fraser on 10/1/14.
//  Copyright (c) 2014 Adam Fraser. All rights reserved.
//

#import "MatchViewController.h"
#import "GridSquare.h"
#import "MatchesViewController.h"
#import <CouchbaseLite/CouchbaseLite.h>

@interface MatchViewController ()

@property (strong, nonatomic) IBOutlet UIView *boardView;
@property (strong, nonatomic) IBOutlet UILabel *matchNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *moveTextField;
@property (strong, nonatomic) IBOutlet UIButton *goButton;
@property (strong, nonatomic) IBOutlet UILabel *waitingTextField;
@property (strong, nonatomic) IBOutlet UIButton *doneButton;


@end

@implementation MatchViewController

{
    IBOutlet UILabel *opponentNameLabel;
    IBOutlet UILabel *ownerNameLabel;
    IBOutlet UITextView *boardStateTextView;
    IBOutlet UITextField *nameTextField;
    __weak IBOutlet UIButton *saveButton;
    IBOutlet UIScrollView *scrollView;
    IBOutlet UIView *activeGameActionView;
    
    NSString* firstMovePosition;
    NSString* secondMovePosition;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [_parentQuery addObserver:self forKeyPath:@"rows" options:0 context:NULL];
    
    _app = [[UIApplication sharedApplication] delegate];
    firstMovePosition = @"";
    secondMovePosition = @"";
    
    // Update the view.
    [self updateBoard];
    
    // Do any additional setup after loading the view.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_parentQuery removeObserver:self forKeyPath:@"rows"];
}

- (IBAction)doneClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)goClicked:(id)sender {


}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Manage Match
- (void)initMatch:(Match*)newMatch {
    if (_match != newMatch) {
        _match = newMatch;
    }
    
}
- (IBAction)goAction:(id)sender {
    
    //validate move
    NSError* moveError;
    if (![_match validateMove:_moveTextField.text error:&moveError]) {
        NSLog(@"Invalid move");
    } else {
        [_match updateMatch];
        [self updateBoard];
    }
    
    
    
}

- (void) updateBoard {
    self.navigationItem.title = _match.name;
    self.navigationItem.backBarButtonItem.style = UIBarButtonItemStylePlain;
    
    
    _matchNameTextField.text = _match.name;
    
    opponentNameLabel.text = _match.opponentId;
    ownerNameLabel.text = _match.ownerId;
    NSMutableArray *boardArray = [_match getBoardAsArray];
    int size = _boardView.bounds.size.width / 8;
    for (int row=0;row<=7;row++) {
        for (int col=0;col<=7;col++) {
            int x=col*size;
            int y=row*size;
            GridSquare *square = [[GridSquare alloc] initWithFrame:CGRectMake(x,y,size,size)];
            
            square.size = size;
            square.stringValue = [boardArray objectAtIndex:(row*8 + col)];
            [_boardView addSubview:square];
            if (((row + col) % 2) == 0) {
                square.colour = @"white";
            }
            square.row = row;
            square.column = col;
            
            UITapGestureRecognizer * tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSquareTap:)];
            [square addGestureRecognizer:tapRecognizer];
            square.userInteractionEnabled = YES;
            [square refresh];
        }
    }
    
    // show 'waiting' message if it's not user's turn
    self.waitingTextField.hidden = [_match.currentPlayerId isEqualToString: _app.username];
    
    // disabled initially, enabled based on tap
    self.moveTextField.enabled = false;
    self.goButton.enabled = false;
    
    [self initMovePositionText];
    
    
}


-(void)handleSquareTap:(UITapGestureRecognizer *)sender {
    
    // only accept taps if it's your turn
    if (![_match.currentPlayerId isEqualToString: _app.username]) {
        return;
    }
    
    //here you can use sender.view to get the touched view
    int column = [(GridSquare*)sender.view column];
    int row = [(GridSquare*)sender.view row];
    
    
    NSString* fileName = [NSString stringWithFormat:@"%c", column + 65];  //convert 0-7 to A-H
    
    NSString* tappedPosition = [NSString stringWithFormat:@"%@%d", fileName, 8 - row];
    
    if ([firstMovePosition isEqualToString:@""]) {
        // first position is empty, add this as the first position
        firstMovePosition = tappedPosition;
    } else if ([firstMovePosition isEqualToString:tappedPosition] && [secondMovePosition isEqualToString:@""]) {
        // first position was same as selected, no second position selected.  treat as unselect of first position
        firstMovePosition = @"";
    } else if ([secondMovePosition isEqualToString: @""]) {
        // first position is populated, treat as selection of second position
        secondMovePosition = tappedPosition;
    } else if ([secondMovePosition isEqualToString: tappedPosition]) {
        // second position was same as selected, treat as unselect of second position
        secondMovePosition = @"";
    }
    
    [self updateMovePositionText];
    
}

- (void) updateMovePositionText {
    
    NSString* movePositionText = firstMovePosition;
    
    if (![firstMovePosition isEqualToString:@""]) {
        movePositionText = [NSString stringWithFormat:@"%@-%@", firstMovePosition, secondMovePosition];
    }
    
    self.moveTextField.text = movePositionText;
    
    if (![secondMovePosition isEqualToString:@""]) {
        self.goButton.enabled = true;
    } else {
        self.goButton.enabled = false;
    }
}

-(void) initMovePositionText {
    firstMovePosition = @"";
    secondMovePosition = @"";
    [self updateMovePositionText];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    
    if (sender != saveButton) return;
    
    _match.name = nameTextField.text;
    
    NSError* error;
    if (![_match save: &error]) {
        UIAlertView* alert= [[UIAlertView alloc] initWithTitle:@"Error"
                                                       message:@"Unable to update match."
                                                      delegate:nil
                                             cancelButtonTitle:@"Ok"
                                             otherButtonTitles:nil];
        [alert show];
        return;
    }
    
}

#pragma mark - update board based on livequery

- (void) observeValueForKeyPath: (NSString*)keyPath
                       ofObject: (id)object
                         change: (NSDictionary*)change
                        context: (void*)context
{
    
    
    if ([object isMemberOfClass:[CBLLiveQuery class]]) {
        for (CBLQueryRow* row in ((CBLLiveQuery*)object).rows) {
            // update the UI
            if ([((Match*)row).document.documentID isEqualToString: _match.document.documentID]) {
                //_match = [Match modelForDocument: row.document];
                [self updateBoard];
            }
        }
    }
    
}


@end
