//
//  UserProfile.m
//  ChessPark
//
//  Created by Adam Fraser on 10/1/14.
//  Copyright (c) 2014 Adam Fraser. All rights reserved.
//

#import "UserProfile.h"

@implementation UserProfile


#define kUserProfileDocType @"userProfile"

@dynamic userId;
@dynamic wins;
@dynamic losses;
@dynamic draws;



- (instancetype) initProfileInDatabase: (CBLDatabase*)database
                 forUsername: (NSString*)name
{
    self = [super initWithNewDocumentInDatabase: database];
    if (self) {
        [self setValue: kUserProfileDocType ofProperty: @"type"];
        self.userId = name;
        self.wins = 0;
        self.losses = 0;
        self.draws = 0;
    }
    return self;
}


+ (CBLQuery*) userNameQuery: (CBLDatabase*)db
                    forUser: (NSString*)userid {
    CBLView* view = [db viewNamed: @"getUserProfileForUserId"];
    if (!view.mapBlock) {
        // define the view/mapblock the first time the view is created
        [view setMapBlock: MAPBLOCK({
            if ([doc[@"type"] isEqualToString: kUserProfileDocType]) {
                if ([doc[@"userId"] isEqualToString: userid]) {
                    NSString* userId = doc[@"userId"];
                    emit(@[userId], doc);
                }
            }
        }) reduceBlock: nil version: @"2"];  // note: increment version when MAPBLOCK changes
    }
    return [view createQuery];
}

@end
