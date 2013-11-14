package com.stratogos.cordova.localNotification;

import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.util.Log;

public class NotificationHandlerActivity extends Activity{

	private static String TAG = "NotificationHandlerActivity"; 
	
	/*
     * this activity will be started if the user touches a notification that we own. 
     * We send it's data off to the plugin for processing.
     * If needed, we boot up the main activity to kickstart the application. 
     * @see android.app.Activity#onCreate(android.os.Bundle)
     */
    @Override
    public void onCreate(Bundle savedInstanceState)
    {
            super.onCreate(savedInstanceState);
            Log.v(TAG, "onCreate");

            try {
				processNotificationBundle();
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}

            finish();

            if (LocalNotificationPlugin.isActive() == false) {
                    forceMainActivityReload();
            }
    }
    
    /**
     * Takes the pushBundle extras from the intent, 
     * and sends it through to the PushPlugin for processing.
     */
    private void processNotificationBundle() throws JSONException
    {
    		Bundle extras = getIntent().getExtras();
    		
            JSONObject params = new JSONObject(extras.getString(LocalNotificationPlugin.PLUGIN_NAME));

            String callback = params.getString("onNotification");
            JSONObject data = params.getJSONObject("userData");
            
            boolean appInForeground = LocalNotificationPlugin.isActive() && LocalNotificationPlugin.isInForeground();
            
            data.put("receivedWhileInForeground", appInForeground);
            
            LocalNotificationPlugin.notificationReceived(callback, data);
    }

    /**
     * Forces the main activity to re-launch if it's unloaded.
     */
    private void forceMainActivityReload()
    {
            PackageManager pm = getPackageManager();
            Intent launchIntent = pm.getLaunchIntentForPackage(getApplicationContext().getPackageName());                    
            startActivity(launchIntent);
    }

    
}
