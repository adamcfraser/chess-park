 //
//  AppDelegate.m
//  ChessPark
//
//  Created by Adam Fraser on 9/26/14.
//  Copyright (c) 2014 Adam Fraser. All rights reserved.
//

#import "AppDelegate.h"
#import "Match.h"
#import "UserProfile.h"

#import "CouchbaseLite/CouchbaseLite.h"
#import "CouchbaseLite/CBLDocument.h"
#define kSyncProtocol @"http"
//#define kSyncHost @"127.0.0.1"
//#define kSyncHost @"10.17.55.218"
#define kSyncHost @"10.0.1.6"
#define kSyncPort @"4984"
#define kSyncURL kSyncProtocol @"://" kSyncHost @":" kSyncPort @"/chess-park"

#define kDatabaseName @"chess-park"
#define kCPUserName @"cpusername"

@implementation AppDelegate
{
    CBLReplication* push;
    CBLReplication* pull;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    CBLManager *manager = [CBLManager sharedInstance];
    NSError *error;
    self.database = [manager databaseNamed:kDatabaseName error:&error];
    if (error) {
        NSLog(@"error getting database %@",error);
        exit(-1);
    }
    
    
    // set up replication
    NSLog(@"Setting up replication to...%@", kSyncURL);
    
    NSURL* url = [NSURL URLWithString: kSyncURL];
    push = [self.database createPushReplication: url];
    pull = [self.database createPullReplication: url];
    push.continuous = pull.continuous = YES;
    
    
    _username = [[NSUserDefaults standardUserDefaults] objectForKey: kCPUserName];
    
    if (_username) {
        NSURLCredential *credential = [self retrieveCredentialFromStorage];
        if (credential != nil) {
            [self startReplicationUsingCredential:credential];
        } else {
            [self showLoginAlert];
        }
    } else {
        [self showLoginAlert];
    }
    
    return YES;
}

- (void) showLoginAlert {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login" message:@"Please login" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Login", nil];
    alert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    [alert show];
}

- (void) alertView:(UIAlertView *) alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        
        UITextField *username = [alertView textFieldAtIndex:0];
        NSLog(@"username: %@", username.text);
        
        UITextField *password = [alertView textFieldAtIndex:1];
        NSLog(@"password: %@", password.text);
        
        NSURLCredential* credential = [NSURLCredential credentialWithUser: username.text password: password.text persistence:NSURLCredentialPersistencePermanent];
        
        [self storeCredential: credential];
        [self startReplicationUsingCredential: credential];
    }
}


- (void) storeCredential:(NSURLCredential*)credential {
    
    // set user default
    [[NSUserDefaults standardUserDefaults] setObject:credential.user forKey:kCPUserName];
    
    // add to credential storage
    [[NSURLCredentialStorage sharedCredentialStorage] setCredential:credential forProtectionSpace:self.getProtectionSpace];
    
    
}

- (NSURLCredential*) retrieveCredentialFromStorage{
    
    if (!_username) {
        return nil;
    }
    
    NSDictionary *credentials = [[NSURLCredentialStorage sharedCredentialStorage] credentialsForProtectionSpace: self.getProtectionSpace];
    if (credentials.count > 0) {
        return [credentials objectForKey:_username];
    } else {
        return nil;
    }
    
}

- (NSURLProtectionSpace*) getProtectionSpace {
    
    NSURLProtectionSpace *protSpace = [[NSURLProtectionSpace alloc] initWithHost: kSyncHost
                                                                            port: [kSyncPort intValue]
                                                                        protocol: kSyncProtocol
                                                                           realm: nil
                                                            authenticationMethod: nil];
    return protSpace;
}

- (void) startReplicationUsingCredential:(NSURLCredential*)credential {
    
    
    push.credential = credential;
    pull.credential = credential;
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(replicationChanged:)
                                                 name: kCBLReplicationChangeNotification
                                               object: push];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(replicationChanged:)
                                                 name: kCBLReplicationChangeNotification
                                               object: pull];
    
    // check if a user profile doc exists
    CBLQuery *query =[UserProfile userNameQuery:self.database forUser:credential.user];
    
    NSError *error;
    CBLQueryEnumerator *result = [query run: &error];
    
    if (!error && result.count > 0) {
        _username = credential.user;
    }
    
    for (CBLQueryRow *row in result){
        NSLog(@"User name %@", row.value);
    }
    
    if (!_username) {
        // create user profile doc if it doesn't exist.
        
        UserProfile *profile = [[UserProfile alloc] initProfileInDatabase: _database forUsername: credential.user];
        _username = profile.userId;
        [profile save: &error];
    }
    /*
    [push stop];
    [pull stop];
     */
    [push start];
    [pull start];

}

- (void)replicationChanged:(NSNotificationCenter*)nc{
    
    
    NSError *error = nil;
    for (CBLReplication *rep in @[pull, push]) {
        
        CBLReplicationStatus status = rep.status;
        error = rep.lastError;
        
        if (error != nil && error.code == 401) {
            
            NSLog(@"Auth failure");
            UIAlertView* alert= [[UIAlertView alloc] initWithTitle:@"Login Error"
                                                           message:@"Unable to authenticate against Sync Gateway using provided credentials.  Replication stopped."
                                                          delegate:nil
                                                 cancelButtonTitle:@"Ok"
                                                 otherButtonTitles:nil];
            [alert show];

            if (_username) {
                
                // if we fail to authenticate as the user, delete the user profile from the DB
                
                [self removeUserProfileDocuments:_username];
                
                [[NSUserDefaults standardUserDefaults] removeObjectForKey: kCPUserName];
                
                _username = nil;
            }
           
            
            
            
            return;

        }
        
        
        switch(status)
        {
            case kCBLReplicationOffline:
                NSLog(@"Replication status 'Offline'");
                break;
            case kCBLReplicationActive:
                NSLog(@"Replication status 'Active'");
                NSLog(@"Changes count:%d", rep.changesCount);
                NSLog(@"Completed changes count:%d", rep.completedChangesCount);
                break;
            case kCBLReplicationIdle:
                NSLog(@"Replication status 'Idle'");
                break;
            case kCBLReplicationStopped:
                NSLog(@"Replication status 'Stopped'");
                break;
        }
    }
    
}

- (void) removeUserProfileDocuments:(NSString*) username {
    CBLQuery *query =[UserProfile userNameQuery:self.database forUser:username];
    
    NSError *error;
    CBLQueryEnumerator *result = [query run: &error];
    
    if (!error && result.count > 0) {
        for (CBLQueryRow *row in result){
            NSLog(@"User name %@", row.value);
            
            CBLDocument *doc = row.document;
            NSError *delError;
            if (![doc deleteDocument: &delError]) {
                NSLog(@"Unable to delete user profile document for user %@", username);
            }
        }
    }
}



- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
