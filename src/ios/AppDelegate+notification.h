//
//  AppDelegate+notification.h
//  localnotification
//
//  Created by Robert Easterday on 10/26/12.
//
//

#import "AppDelegate.h"

@interface AppDelegate (notification)

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification  *)notifcation;
- (void)applicationDidBecomeActive:(UIApplication *)application;
- (id) getCommandInstance:(NSString*)className;


@property (nonatomic, retain) UILocalNotification *launchNotification;
@property BOOL notificationColdStart;

@end