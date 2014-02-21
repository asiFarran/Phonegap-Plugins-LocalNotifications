//
//  AppDelegate+localNotification.m
//
//
//  Created by Robert Easterday on 10/26/12.
//  Modifed by Asi Farran on 23/9/13
//

#import "AppDelegate+localNotification.h"
#import "LocalNotificationPlugin.h"
#import <objc/runtime.h>




@implementation AppDelegate (notification)

static UILocalNotification *launchNotification;
static BOOL notificationColdStart;

- (id) getCommandInstance:(NSString*)className
{
	return [self.viewController getCommandInstance:className];
}

+ (void)load
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkForNotification:)
                                                 name:@"UIApplicationDidFinishLaunchingNotification" object:nil];
}


+ (void)checkForNotification:(NSNotification *)notification
{
    
	if (notification)
	{
		NSDictionary *launchOptions = [notification userInfo];
        
		if (launchOptions){
			launchNotification = [launchOptions objectForKey: @"UIApplicationLaunchOptionsLocalNotificationKey"];
            notificationColdStart = YES;
        }
	}
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    NSLog(@"didReceiveNotification");
    
    
    // Get application state for iOS4.x+ devices, otherwise assume active
    UIApplicationState appState = UIApplicationStateActive;
    if ([application respondsToSelector:@selector(applicationState)]) {
        appState = application.applicationState;
    }
    
    // store the state of the application when the notification was received
    // in the notification itself
    NSMutableDictionary *dict = [notification.userInfo mutableCopy];
    [dict setObject:[NSNumber numberWithBool:(appState == UIApplicationStateActive)] forKey:@"appActiveWhenReceiving"];
    notification.userInfo = dict;
    
    
    if (appState == UIApplicationStateActive) {
        LocalNotificationPlugin *handler = [self getCommandInstance:@"LocalNotification"];
        handler.pendingNotification = notification;
        
        [handler notificationReceived];
    } else {
        //save it for later
        launchNotification = notification;
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    NSLog(@"active");
    
    //zero badge
    application.applicationIconBadgeNumber = 0;
    
    
    if (![self.viewController.webView isLoading] && launchNotification) {
        LocalNotificationPlugin *handler = [self getCommandInstance:@"LocalNotification"];
        
        handler.pendingNotification = launchNotification;
        launchNotification = nil;
        
        if(notificationColdStart){
            notificationColdStart = NO; //reset flag so new incoming notifications can be passed directly to the handler
        }
        else{
            [handler performSelectorOnMainThread:@selector(notificationReceived) withObject:handler waitUntilDone:NO];
        }
    }
}



@end
