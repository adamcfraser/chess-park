//
//  Match.m
//  ChessPark
//
//  Created by Adam Fraser on 9/29/14.
//  Copyright (c) 2014 Adam Fraser. All rights reserved.
//

#import "Match.h"


#define kMatchDocType @"match"

@interface Match () {
    NSMutableArray* boardAsArray;
}

@end

@implementation Match {
    
    NSString *castleState;
    NSString *enPassantState;
    NSString *halfMoveClock;
    NSString *fullMoveNumber;
    NSString *postBoardInfo;
}

@dynamic name;
@dynamic boardState;
@dynamic status;
@dynamic ownerId;
@dynamic ownerColour;
@dynamic opponentId;
@dynamic lastMove;
@dynamic currentPlayerId;



static NSString *const InitialBoardState = @"rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1";
static NSString *const BoardFiles = @"ABCDEFGH";
static NSString *const BoardRows = @"12345678";
static NSString *const Pieces = @"RNBKQPrnbkqp";


+ (CBLQuery*) matchQuery: (CBLDatabase*)db {
    
    return [self matchQuery:db forStatus:@"active"];
    
}

+ (CBLQuery*) matchQuery: (CBLDatabase*)db
               forStatus: (NSString*) status {
  
    CBLView* view = [db viewNamed: [NSString stringWithFormat:@"%@%@", status, @"Matches"]];
    if (!view.mapBlock) {
        // define the view/mapblock the first time the view is created
        [view setMapBlock: MAPBLOCK({
            if ([doc[@"type"] isEqualToString: kMatchDocType]) {
                if ([doc[@"status"] isEqualToString: status]) {
                    NSString* name = doc[@"name"];
                    emit(@[name], doc);
                }
            }
        }) reduceBlock: nil version: @"3"];  // note: increment version when MAPBLOCK changes
    }
    
    return [view createQuery];
}

- (Match*) initInDatabase: (CBLDatabase*)database
                 withName: (NSString*)name
                  forUser: (NSString*)username
{
    self = [super initWithNewDocumentInDatabase: database];
    if (self) {
        [self setValue: kMatchDocType ofProperty: @"type"];
        self.name = name;
        self.ownerId = username;
        self.status= @"waiting";
        self.boardState = InitialBoardState;
    }
    return self;
}

- (void) updateMatch {

    self.boardState = [self getFENNotation];
    [self toggleCurrentPlayer];
    // Save changes:
    NSError* error;
    if (![self save: &error]) {
        NSLog(@"Save Error:%@", error.description);
    }
    
}

- (NSString* ) getFENNotation {
    
    NSMutableString* boardString = [NSMutableString stringWithCapacity:64];
    
    if (boardAsArray != nil) {
        for (int rowNum=0; rowNum < 8; rowNum++) {
            int emptyCount = 0;
            if (rowNum > 0) {
                [boardString appendString:@"/"];
            }
            for (int colNum=0; colNum <8; colNum++) {
                int arrayIndex = rowNum * 8 + colNum;
                
                NSString *charTrimmed = [boardAsArray[arrayIndex] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            
                if ([charTrimmed isEqualToString:@""]) {
                    emptyCount ++;
                } else {
                    if (emptyCount > 0) {
                        [boardString appendString:[NSString stringWithFormat:@"%d",emptyCount]];
                        emptyCount = 0;
                    }
                    [boardString appendString: charTrimmed];
                }
            }
            if (emptyCount > 0) {
                [boardString appendString:[NSString stringWithFormat:@"%d",emptyCount]];
            }
        }
    }
    [boardString appendString: postBoardInfo];
    return boardString;
}



- (NSMutableArray*) getBoardAsArray {
    
    //if (boardAsArray == nil) {
    
        NSLog(@"Converting board String to Array:  %@",self.boardState);
    
        boardAsArray = [[NSMutableArray alloc] init];
        NSString *boardChar = nil;
        int charIndex = 0;
        while (![@" " isEqual: boardChar]) {
            boardChar = [self getStringAtPosition:self.boardState atPosition:charIndex];
        
            if ([Pieces rangeOfString: boardChar].location != NSNotFound) {
                [boardAsArray addObject:boardChar];
            } else if ([@" " isEqual:boardChar]){
                break;
            } else {
                // assume it's a number
                int numEmpty = [boardChar intValue];
                for (int i=0; i<numEmpty; i++) {
                    [boardAsArray addObject:@" "];
                }
            }
            charIndex ++;
        }
        postBoardInfo = [self.boardState substringFromIndex:charIndex];
    //}
    
    return boardAsArray;
}

- (BOOL) validateMove: (NSString*) move
            error: (NSError**) outError {
    
    NSError* moveError = [NSError errorWithDomain:@"MatchMove.err" code:-1 userInfo:nil];
    
    // check for empty move
    if (move == nil || [move isEqual:@""] || [move rangeOfString:@"-"].location == NSNotFound) {
        
        if (outError) {
            *outError = moveError;
        }
        return NO;
    }
    
    // check for correct move syntax "xn-xn", x is file, n is row
    NSArray* positions = [move componentsSeparatedByString:@"-"];
    if (positions.count != 2) {
        if (outError) {
            *outError = moveError;
        }
        return NO;
    }
    
    int fromBoardIndex = [self getBoardArrayIndexFromLocation:positions[0]];
    int toBoardIndex = [self getBoardArrayIndexFromLocation:positions[1]];
    
    if (fromBoardIndex == -1 || toBoardIndex == -1) {
        if (outError) {
            *outError = moveError;
        }
        return NO;
    }

    boardAsArray[toBoardIndex] = boardAsArray[fromBoardIndex];
    boardAsArray[fromBoardIndex] = @" ";
    self.lastMove = move;
    return YES;
    
}

- (int) getBoardArrayIndexFromLocation:(NSString*) location {
    if (location.length != 2) {
        return -1;
    }
    NSString* file = [self getStringAtPosition:location atPosition:0];
    NSString* row = [self getStringAtPosition:location atPosition:1];
    
    if ([BoardFiles rangeOfString:file].location == NSNotFound || [BoardRows rangeOfString:row].location == NSNotFound) {
        return -1;
    }
    
    int fileNumber = (int)[BoardFiles rangeOfString:file].location;
    int rowNumber = (int)[BoardRows rangeOfString:row].location;
    
    return (7-rowNumber) * 8 + fileNumber;
}

- (NSString* ) getStringAtPosition: (NSString*) mystring
                        atPosition: (int) position {
    return [NSString stringWithFormat:@"%c",[mystring characterAtIndex:position]];
}

- (void) joinMatch:(NSString *)username {
    
    self.opponentId = username;
    self.status = @"active";
    self.currentPlayerId = username; // opponent goes first, since they are the one that starts the game
    // Save changes:
    NSError* error;
    if (![self save: &error]) {
    }
}

- (void) toggleCurrentPlayer {
    NSLog(@"Toggling Current player ID: %@,%@,%@", self.currentPlayerId, self.ownerId, self.opponentId);
    if ([self.currentPlayerId isEqualToString: self.ownerId]) {
        self.currentPlayerId = self.opponentId;
    } else {
        self.currentPlayerId = self.ownerId;
    }

}

@end

