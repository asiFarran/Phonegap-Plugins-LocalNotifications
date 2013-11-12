# Phonegap-Plugins-LocalNotifications

> Local Notification for iOS and Android adapted for cordova/phongap 3 


## Installation:

    phonegap local plugin add https://github.com/asiFarran/Phonegap-Plugins-LocalNotifications.git

On iOS the plugin uses method swizzling on AppDelegate to hook into the app lifecyle and avoid making manual changes to the main AppDelegate code. This solution has been adopted from the code for the <a target='_blank' href='https://github.com/phonegap-build/PushPlugin'>PushNotification plugin </a>

## Usage:

The plugin creates the object window.plugin.localNotification

    
To add a notification: 
	    
    window.plugin.localNotification.add({
       date: new Date(),
       message: 'my message',
       hasAction: true,
       action: 'View',
       badge: 0,
       id: 6,
       sound:'',
       onNotification: 'myHandlerName',
       userData: {
            customVar: 'val',
            customVar2: 6
       }
    });
	

The notification callback fundtion receives an notification object containg the id and any optional userData provided when the notification was set.

e.g (based on the above)
    
     function notificationHandler(notification){
        notification.id == 6;
        notification.customVar == 'val';
        notification.customVar2 == 6;
     }
     


To remove a notification: 
        
    window.plugin.localNotification.clear(id);
    
To remove all notifications: 
        
    window.plugin.localNotification.clearAll();
    


In iOS if the notification arrived when your app was closed and the app was launched from the notification itself (cold start) the notification callback would NOT be called even though the notification data is available.

You can work around it by doing the following on your app startup:

    // this will fire the callback handler if we've got a waiting notification
     function onDeviceReady() {    	
		window.plugin.localNotification.pulsePendingNotification(); 
	}
    
The above could also be made to fire automaticaly but then we might run into issues where the callback handler is not yet ready to handle the notification (or does not yet exist), hence the responsibility for the call remains with the application.
The same behavior was set for Android to ensure plugin usage and expectations are identical on both platforms

