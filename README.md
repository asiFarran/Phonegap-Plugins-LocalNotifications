# Phonegap-Plugins-LocalNotifications

> Local Notification for iOS and Android adapted for cordova/phongap 3 


## Installation:

    phonegap local plugin add https://github.com/asiFarran/Phonegap-Plugins-LocalNotifications.git



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
    


in iOS if the notification arrived when your app was closed and the app was launched from the notification itself (cold start) the notification callback would NOT be called even though the notification data is available.

you can work around it by doing the following on your app startup:

    // this will fire the callback handler if we've got a waiting notification
     function onDeviceReady() {    	
		window.plugin.localNotification.pulsePendingNotification(); 
	}
    
