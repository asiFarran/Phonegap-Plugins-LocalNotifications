package com.stratogos.cordova.localNotification;

import java.util.Date;
import java.util.Map;
import java.util.Set;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.util.Log;


public class AlarmRestoreOnBoot extends BroadcastReceiver {
	
	private AlarmHelper alarm = null;

	@Override
	public void onReceive(Context context, Intent intent) {
		
		alarm = new AlarmHelper(context);

		// Obtain alarm details form Shared Preferences
		final SharedPreferences alarmSettings = context.getSharedPreferences(
				LocalNotificationPlugin.PLUGIN_NAME, Context.MODE_PRIVATE);
		final Map<String, ?> allAlarms = alarmSettings.getAll();
		final Set<String> alarmIds = allAlarms.keySet();

		/*
		 * For each alarm, parse its alarm options and register is again with
		 * the Alarm Manager
		 */
		for (String alarmId : alarmIds) {
			try {
				this.processAlarm(new JSONArray(alarmSettings.getString(alarmId, "")));
			} catch (JSONException e) {
				Log.d(LocalNotificationPlugin.PLUGIN_NAME,
						"AlarmRestoreOnBoot: Error while restoring alarm details after reboot: "
								+ e.toString());
			}
		}
		
		Log.d(LocalNotificationPlugin.PLUGIN_NAME,
				"AlarmRestoreOnBoot: Successfully restored alarms upon reboot");
	}
	
	public boolean processAlarm(JSONArray args) throws JSONException {
		return this.add(args.getJSONObject(0));
	}
	
	public boolean add(JSONObject params) throws JSONException {
		Date date = new Date (params.getLong("date"));
		
		
		return alarm.addAlarm(date, params);		
	}

}
