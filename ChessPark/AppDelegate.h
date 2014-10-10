//
//  AppDelegate.h
//  ChessPark
//
//  Created by Adam Fraser on 9/26/14.
//  Copyright (c) 2014 Adam Fraser. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CouchbaseLite/CouchbaseLite.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) CBLDatabase *database;
@property (strong, nonatomic) NSString *username;

- (void) startReplicationUsingCredential: (NSURLCredential*) credential;

@end

