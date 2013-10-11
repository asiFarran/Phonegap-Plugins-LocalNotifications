//
//  LocalNotification.m
//  HelloWorld
//
//  Created by yoyo on 8/28/13.
//
//
#import <Foundation/NSJSONSerialization.h>
#import "LocalNotificationPlugin.h"


@implementation LocalNotificationPlugin

@synthesize pendingNotification;

- (void)addNotification:(CDVInvokedUrlCommand*)command; {
    
    NSArray *arguments = command.arguments;
    NSDictionary *options = [arguments objectAtIndex:0];
    
    NSMutableDictionary *repeatDict = [[NSMutableDictionary alloc] init];
    [repeatDict setObject:[NSNumber numberWithInt:NSDayCalendarUnit] forKey:@"daily"];
    [repeatDict setObject:[NSNumber numberWithInt:NSWeekCalendarUnit] forKey:@"weekly"];
    [repeatDict setObject:[NSNumber numberWithInt:NSMonthCalendarUnit] forKey:@"monthly"];
    [repeatDict setObject:[NSNumber numberWithInt:NSYearCalendarUnit] forKey:@"yearly"];
    [repeatDict setObject:[NSNumber numberWithInt:0] forKey:@""];
    
    // notif settings
	double timestamp = [[options objectForKey:@"date"] doubleValue];
	NSString *msg = [options objectForKey:@"message"];
	NSString *action = [options objectForKey:@"action"];
	NSString *notificationId = [options objectForKey:@"id"];
    NSString *sound = [options objectForKey:@"sound"];
    NSString *onNotification = [options objectForKey:@"onNotification"];
    NSString *repeat = [options objectForKey:@"repeat"];
	NSInteger badge = [[options objectForKey:@"badge"] intValue];
	bool hasAction = ([[options objectForKey:@"hasAction"] intValue] == 1)?YES:NO;
    
	NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    
	UILocalNotification *notif = [[UILocalNotification alloc] init];
	notif.fireDate = date;
	notif.hasAction = hasAction;
	notif.timeZone = [NSTimeZone defaultTimeZone];
    notif.repeatInterval = [[repeatDict objectForKey: repeat] intValue];
    
	notif.alertBody = ([msg isEqualToString:@""])?nil:msg;
	notif.alertAction = action;
    
    notif.soundName = sound;
    notif.applicationIconBadgeNumber = badge;
    
	NSDictionary *userDict = [NSDictionary dictionaryWithObjectsAndKeys:notificationId,@"notificationId",onNotification,@"onNotification",[options objectForKey:@"userData"],@"userData",nil];
    
    notif.userInfo = userDict;
    
	[[UIApplication sharedApplication] scheduleLocalNotification:notif];
	NSLog(@"Notification Set: %@ (ID: %@, Badge: %i, sound: %@,onNotification: %@)", date, notificationId, badge, sound,onNotification);
}

- (void)cancelNotification:(CDVInvokedUrlCommand*)command; {
	NSString *notificationId = [command.arguments objectAtIndex:0];
	NSArray *notifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
	for (UILocalNotification *notification in notifications) {
		NSString *notId = [notification.userInfo objectForKey:@"notificationId"];
		if ([notificationId isEqualToString:notId]) {
			NSLog(@"Notification Canceled: %@", notificationId);
			[[UIApplication sharedApplication] cancelLocalNotification:notification];
		}
	}
}

- (void)cancelAllNotifications:(CDVInvokedUrlCommand*)command; {
	NSLog(@"All Notifications cancelled");
	[[UIApplication sharedApplication] cancelAllLocalNotifications];
}

- (void)pulsePendingNotification:(CDVInvokedUrlCommand*)command; {
    
    [self notificationReceived];
}

- (void)notificationReceived {
    
    
    if (pendingNotification)
    {
        BOOL appInForeground =  [[pendingNotification.userInfo objectForKey:@"appActiveWhenReceiving"] boolValue];
        NSDictionary *userData =  [pendingNotification.userInfo objectForKey:@"userData"];
        
        NSMutableDictionary* notification = [[NSMutableDictionary alloc] init];
        
        [notification setObject:[NSNumber numberWithBool:appInForeground] forKey:@"receivedWhileInForeground"];
        [notification setObject:[pendingNotification.userInfo objectForKey:@"notificationId"] forKey:@"id"];
        [notification setObject:userData forKey:@"data"];
          
        
        NSData *data = [NSJSONSerialization dataWithJSONObject:notification options:NSJSONWritingPrettyPrinted error:nil];
        NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        NSString *callbackFunc = [pendingNotification.userInfo objectForKey:@"onNotification"];
        
        NSString * jsCallBack = [NSString
                                 stringWithFormat:@"%@(%@)", callbackFunc,json];
        
        [self.webView stringByEvaluatingJavaScriptFromString:jsCallBack];
        
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
        
        self.pendingNotification = nil;
    }
}
@end
