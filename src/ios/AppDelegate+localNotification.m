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

static char launchNotificationKey;
static char notificationColdStartKey;

@implementation AppDelegate (notification)

- (id) getCommandInstance:(NSString*)className
{
	return [self.viewController getCommandInstance:className];
}

// its dangerous to override a method from within a category.
// Instead we will use method swizzling. we set this up in the load call.
+ (void)load
{
    Method original, swizzled;

    original = class_getInstanceMethod(self, @selector(init));
    swizzled = class_getInstanceMethod(self, @selector(swizzled_init));
    method_exchangeImplementations(original, swizzled);
}

- (AppDelegate *)swizzled_init
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createNotificationChecker:)
                                                 name:@"UIApplicationDidFinishLaunchingNotification" object:nil];

	// This actually calls the original init method over in AppDelegate. Equivilent to calling super
	// on an overrided method, this is not recursive, although it appears that way. neat huh?
	return [self swizzled_init];
}

// This code will be called immediately after application:didFinishLaunchingWithOptions:. We need
// to process notifications in cold-start situations in which we WILL NOT invoke the handler on the webview
// as it might not be ready to respond yet. the notificationColdStart flag governs that
- (void)createNotificationChecker:(NSNotification *)notification
{

	if (notification)
	{
		NSDictionary *launchOptions = [notification userInfo];

		if (launchOptions){
			self.launchNotification = [launchOptions objectForKey: @"UIApplicationLaunchOptionsLocalNotificationKey"];
            self.notificationColdStart = YES;
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

    if (appState == UIApplicationStateActive) {
        LocalNotificationPlugin *handler = [self getCommandInstance:@"LocalNotificationPlugin"];
        handler.pendingNotification = notification;

        [handler notificationReceived];
    } else {
        //save it for later
        self.launchNotification = notification;
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {

    NSLog(@"active");

    //zero badge
    application.applicationIconBadgeNumber = 0;

    if (![self.viewController.webView isLoading] && self.launchNotification) {
        LocalNotificationPlugin *handler = [self getCommandInstance:@"LocalNotificationPlugin"];

        handler.pendingNotification = self.launchNotification;
        self.launchNotification = nil;

        if(self.notificationColdStart){
            self.notificationColdStart = NO; //rest flag so new incoming notifications can be passed directly to the handler
        }
        else{
            [handler performSelectorOnMainThread:@selector(notificationReceived) withObject:handler waitUntilDone:NO];
        }
    }
}





// The accessors use an Associative Reference since you can't define a iVar in a category
// http://developer.apple.com/library/ios/#documentation/cocoa/conceptual/objectivec/Chapters/ocAssociativeReferences.html
- (LocalNotificationPlugin  *)launchNotification
{
    return objc_getAssociatedObject(self, &launchNotificationKey);
}

- (void)setLaunchNotification:(UILocalNotification  *)aNotification
{

    objc_setAssociatedObject(self, &launchNotificationKey, aNotification, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL )notificationColdStart
{
    return [objc_getAssociatedObject(self, &notificationColdStartKey) boolValue];
}

- (void)setNotificationColdStart:(BOOL)aColdStart
{
    objc_setAssociatedObject(self, &notificationColdStartKey, [NSNumber numberWithBool:aColdStart], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}



@end