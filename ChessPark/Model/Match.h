//
//  Match.h
//  ChessPark
//
//  Created by Adam Fraser on 9/29/14.
//  Copyright (c) 2014 Adam Fraser. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CouchbaseLite/CouchbaseLite.h>

@interface Match : CBLModel

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *boardState;
@property (nonatomic, copy) NSString *status;
@property (nonatomic, copy) NSString *ownerId;
@property (nonatomic, copy) NSString *ownerColour;
@property (nonatomic, copy) NSString *opponentId;
@property (nonatomic, copy) NSString *lastMove;
@property (nonatomic, copy) NSString *currentPlayerId; // whose turn is it?



+ (CBLQuery*) matchQuery: (CBLDatabase*)db;

+ (CBLQuery*) matchQuery: (CBLDatabase*)db
               forStatus: (NSString*) status;

- (instancetype) initInDatabase: (CBLDatabase*) database
                       withName: (NSString*)name
                        forUser: (NSString*)username;

- (NSMutableArray*) getBoardAsArray;

- (void) joinMatch: (NSString*) username;

- (void) updateMatch;


- (BOOL) validateMove: (NSString*) move
            error: (NSError**) outError;


@end
