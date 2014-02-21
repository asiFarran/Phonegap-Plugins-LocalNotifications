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

static UILocalNotification *localNotification;
static BOOL localNotificationColdStart;

- (id) getCommandInstance:(NSString*)className
{
	return [self.viewController getCommandInstance:className];
}

-(id) init{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActiveHandler:)
                                                name:@"UIApplicationDidBecomeActiveNotification" object:nil];
    
    self = [super init];
    return self;
}

+ (void)load
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkForLocalNotificationsOnStartup:)
                                                 name:@"UIApplicationDidFinishLaunchingNotification" object:nil];
    
    
}

+ (void)checkForLocalNotificationsOnStartup:(NSNotification *)notification
{
    
	if (notification)
	{
		NSDictionary *launchOptions = [notification userInfo];
        
		if (launchOptions){
			localNotification = [launchOptions objectForKey: @"UIApplicationLaunchOptionsLocalNotificationKey"];
            if(localNotification){
                localNotificationColdStart = YES;
            }
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
        localNotification = notification;
    }
}

- (void)applicationDidBecomeActiveHandler:(NSNotification *)notification {
    
    NSLog(@"local notification active");
    
    
    
    if (![self.viewController.webView isLoading] && localNotification) {
        LocalNotificationPlugin *handler = [self getCommandInstance:@"LocalNotification"];
        
        handler.pendingNotification = localNotification;
        localNotification = nil;
        
        if(localNotificationColdStart){
            localNotificationColdStart = NO; //reset flag so new incoming notifications can be passed directly to the handler
        }
        else{
            [handler performSelectorOnMainThread:@selector(notificationReceived) withObject:handler waitUntilDone:NO];
        }
    }
}



@end
