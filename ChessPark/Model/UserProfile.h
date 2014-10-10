//
//  UserProfile.h
//  ChessPark
//
//  Created by Adam Fraser on 10/1/14.
//  Copyright (c) 2014 Adam Fraser. All rights reserved.
//

#import <CouchbaseLite/CouchbaseLite.h>

@interface UserProfile : CBLModel

@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSNumber *wins;
@property (nonatomic, copy) NSNumber *losses;
@property (nonatomic, copy) NSNumber *draws;


- (instancetype) initProfileInDatabase: (CBLDatabase*) database
                           forUsername: (NSString*)name;


+ (CBLQuery*) userNameQuery: (CBLDatabase*)db
                    forUser: (NSString*) userid;

@end
