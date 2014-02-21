//
//  AppDelegate+localNotification.h
//  localnotification
//
//  Created by Robert Easterday on 10/26/12.
//  Modifed by Asi Farran on 23/9/13
//

#import "AppDelegate.h"

@interface AppDelegate (notification)

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification  *)notifcation;
- (void)applicationDidBecomeActive:(UIApplication *)application;
- (id) getCommandInstance:(NSString*)className;

@end