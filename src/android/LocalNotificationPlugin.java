package com.stratogos.cordova.localNotification;

import java.util.Date;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.content.Context;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.util.Log;


public class LocalNotificationPlugin extends CordovaPlugin {

	public static final String TAG = "LocalNotificationPlugin";
	
	private static CordovaWebView gWebView;
	private static String gCachedNotificationCallback = null;	
	
	public static final String PLUGIN_NAME = "LocalNotification";
	public static final String PLUGIN_PREFIX = "LocalNotification_";


	private AlarmHelper alarm = null;

	@Override
	public boolean execute(String action, JSONArray args,
			CallbackContext callbackContext) throws JSONException {
		
		gWebView = this.webView;
		
		boolean success = false;

		alarm = new AlarmHelper(this.cordova.getActivity().getBaseContext());
		
		Log.d(PLUGIN_NAME, "Plugin execute called with action: " + action);
		
		if (action.equalsIgnoreCase("addNotification")) {
			
			JSONObject params = args.getJSONObject(0);
			int id = params.getInt("id");
			
			persistAlarm(id, args);
			
			Log.d(PLUGIN_NAME, "Add Notification with Id: " + id);

			success = this.add(params);
		} else if (action.equalsIgnoreCase("cancelNotification")) {
			unpersistAlarm(args.getInt(0));
			
			Log.d(PLUGIN_NAME, "Cancel Notification with Id: " + args.getInt(0));

			success = this.cancel(args.getInt(0));
		} else if (action.equalsIgnoreCase("cancelAllNotifications")) {
			unpersistAlarmAll();

			success = this.cancelAll();
		}
		else if (action.equalsIgnoreCase("pulsePendingNotification")) {			

			success = this.pulsePendingNotification();
		}
		if (success) {
			callbackContext.success();
		}

		return success;
	}

	private boolean add(JSONObject params) throws JSONException {
		
		Date date = new Date (params.getLong("date"));
				
		return alarm.addAlarm(date, params);		
	}

	private boolean cancel(int id) {
		Log.d(PLUGIN_NAME, "cancel Notification with id: " + id);

		boolean result = alarm.cancelAlarm(id);

		return result;
	}

	private boolean cancelAll() {
		Log.d(PLUGIN_NAME,
				"cancelAllNotifications: cancelling all events for this application");
		/*
		 * Android can only unregister a specific alarm. There is no such thing
		 * as cancelAll. Therefore we rely on the Shared Preferences which holds
		 * all our alarms to loop through these alarms and unregister them one
		 * by one.
		 */

		
		final SharedPreferences alarmSettings = this.cordova.getActivity().getBaseContext().getSharedPreferences(
				PLUGIN_NAME, Context.MODE_PRIVATE);
		
		final boolean result = alarm.cancelAll(alarmSettings);

		return result;
	}

	private boolean pulsePendingNotification(){
		
		if(gCachedNotificationCallback != null){
			sendJavascript(gCachedNotificationCallback);
			gCachedNotificationCallback = null;
		}
		
		return true;
	}
	
	private boolean persistAlarm(int id, JSONArray args) {
		
		
		final Editor alarmSettingsEditor = this.cordova.getActivity().getBaseContext().getSharedPreferences(
				PLUGIN_NAME, Context.MODE_PRIVATE).edit();

		alarmSettingsEditor.putString(PLUGIN_PREFIX + id, args.toString());

		return alarmSettingsEditor.commit();
	}
	

	private boolean unpersistAlarm(int id) {
		
		
		final Editor alarmSettingsEditor = this.cordova.getActivity().getBaseContext().getSharedPreferences(
				PLUGIN_NAME, Context.MODE_PRIVATE).edit();

		alarmSettingsEditor.remove(PLUGIN_PREFIX + id);

		return alarmSettingsEditor.commit();
	}

	private boolean unpersistAlarmAll() {
				
		final Editor alarmSettingsEditor = this.cordova.getActivity().getBaseContext().getSharedPreferences(
				PLUGIN_NAME, Context.MODE_PRIVATE).edit();

		alarmSettingsEditor.clear();

		return alarmSettingsEditor.commit();
	}
	
	public static boolean isActive()
    {
            return gWebView != null;
    }

	public static void notificationReceived(String callback, JSONObject data) {
		
            String notificationCallback = "javascript:" + callback + "(" + data.toString() + ")";
            Log.v(TAG, "sendJavascript: " + notificationCallback);

            if (callback != null) {
            		if(isActive()){
            			sendJavascript(notificationCallback); 
            		}else{
            			gCachedNotificationCallback = notificationCallback;
            		}
                    
            }
    }
	
	private static void sendJavascript(String script){
		gWebView.sendJavascript(script); 
	}

}
