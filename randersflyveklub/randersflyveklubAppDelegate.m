//
//  randersflyveklubAppDelegate.m
//  randersflyveklub
//
//  Created by Mercantec on 9/24/13.
//  Copyright (c) 2013 and3k5. All rights reserved.
//

#import "randersflyveklubAppDelegate.h"
#import <GoogleMaps/GoogleMaps.h>

@implementation randersflyveklubAppDelegate 


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"])
    {
        // app already launched
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"useinternet"];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"dragAutoupdate"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"weatherAutoupdate"];
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"updateInterval"];
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"updatecontactlimit"];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        // This is the first launch ever
        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Welcome" message:@"In order to make things work, this applications should be restarted!" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        //[alert show];
        
    }
    // Override point for customization after application launch.
    [GMSServices provideAPIKey:@"AIzaSyAqxKnD5jtjHroS-JvvD9OUQRXU7aDIIuE"];
    return YES;
}

- (void) applicationDidFinishLaunching:(UIApplication *)application {
     
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    NSLog(@"App wants to exit");
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
