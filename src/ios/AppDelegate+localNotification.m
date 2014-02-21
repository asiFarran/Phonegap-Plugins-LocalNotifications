#import "AppDelegate+localNotification.h"
#import "LocalNotificationPlugin.h"
#import <objc/runtime.h>


@implementation AppDelegate (notification)


// The goal is to have a drop-in module that does not require the user to
// make any manual additions to the AppDelegate

// To do so we need to hook into the AppDelegate events and life cyle
// and we do so by creating a category class implementing only the functionailty relevant to this plugin

// The only way to allow SEVERAL plugins to use this method with colliding
// is to register static and unique event handlers that then use [[UIApplication sharedApplication] delegate]
// to gain access to the root controller and the actual plugin

// All variables and method names are postfixed with the plugin name to try and ensure they are unique // to prevent collision with other plugin handlers

static UILocalNotification *notificationPayload_localNotification;
static BOOL isColdStart_localNotification;

+ (void)load
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkForNotificationsOnStartup_localNotification:)
                                                 name:@"UIApplicationDidFinishLaunchingNotification" object:nil];
    
  
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActiveHandler_localNotification:)
                                                 name:@"UIApplicationDidBecomeActiveNotification" object:nil];
        
}

+ (void)checkForNotificationsOnStartup_localNotification:(NSNotification *)notification
{
    
	NSDictionary *launchOptions = [notification userInfo];
        
	if (launchOptions){
            
		notificationPayload_localNotification = [launchOptions objectForKey: @"UIApplicationLaunchOptionsLocalNotificationKey"];
            
        if(notificationPayload_localNotification){
        	isColdStart_localNotification = YES;
        }
	}
	
}


+ (void)applicationDidBecomeActiveHandler_localNotification:(NSNotification *)notification
{
    
	
	AppDelegate *delegate =  [[UIApplication sharedApplication] delegate];
        
	if (![delegate.viewController.webView isLoading] && notificationPayload_localNotification) {
		
		LocalNotificationPlugin *handler = [delegate getCommandInstance:@"LocalNotification"];
            
        handler.pendingNotification = notificationPayload_localNotification;
        notificationPayload_localNotification = nil;
            
        // on cold start the cordova view will not be ready to handle the event yet
        // so we don tinvoke it. It will call when its ready
        if(isColdStart_localNotification){
                
        	isColdStart_localNotification = NO; //reset flag so new incoming notifications can be passed directly to the handler
        }
        else{
        	handler performSelectorOnMainThread:@selector(notificationReceived) withObject:handler waitUntilDone:NO];        
        }
        
        delegate = nil;
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
        notificationPayload_localNotification = notification;
    }
}


- (id) getCommandInstance:(NSString*)className
{
	return [self.viewController getCommandInstance:className];
}

@end
