package com.stratogos.cordova.localNotification;

import java.util.Date;
import java.util.Map;
import java.util.Set;

import org.json.JSONException;
import org.json.JSONObject;

import android.app.AlarmManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.util.Log;

public class AlarmHelper {

	private Context ctx;

	public AlarmHelper(Context context) {
		this.ctx = context;
	}
	
	public boolean addAlarm(Date date, JSONObject params) throws JSONException{
		
		String alarmId = LocalNotificationPlugin.PLUGIN_PREFIX + params.getString("id");
		
		final Intent intent = new Intent(this.ctx, AlarmReceiver.class);
		intent.setAction(alarmId);
		intent.putExtra(LocalNotificationPlugin.PLUGIN_NAME, params.toString());

		final PendingIntent sender = PendingIntent.getBroadcast(this.ctx, 0,intent, PendingIntent.FLAG_CANCEL_CURRENT);
		
		String repeat = params.getString("repeat");
		
		if(repeat.equalsIgnoreCase("daily")){
			getAlarmManager().setRepeating(AlarmManager.RTC_WAKEUP, date.getTime(),AlarmManager.INTERVAL_DAY, sender);
		}
		else if(repeat.equalsIgnoreCase("weekly")){
			getAlarmManager().setRepeating(AlarmManager.RTC_WAKEUP, date.getTime(),AlarmManager.INTERVAL_DAY * 7, sender);
		}
		else{ 
			getAlarmManager().set(AlarmManager.RTC_WAKEUP, date.getTime(), sender);
		}
		return true;
	}

	public boolean cancelAlarm(int id) {
		
		return cancelAlarm(LocalNotificationPlugin.PLUGIN_PREFIX + id);
	}
	
	public boolean cancelAll(SharedPreferences alarmSettings) {
		final Map<String, ?> allAlarms = alarmSettings.getAll();
		final Set<String> alarmIds = allAlarms.keySet();

		for (String alarmId : alarmIds) {
			Log.d(LocalNotificationPlugin.PLUGIN_NAME,
					"Canceling notification with id: " + alarmId);

			cancelAlarm(alarmId);
		}

		return true;
	}

	private boolean cancelAlarm(String alarmId) {
		
		final Intent intent = new Intent(this.ctx, AlarmReceiver.class);
		intent.setAction(alarmId);

		final PendingIntent pi = PendingIntent.getBroadcast(this.ctx, 0, intent, PendingIntent.FLAG_CANCEL_CURRENT);
		final AlarmManager am = getAlarmManager();

		try {
			am.cancel(pi);
		} catch (Exception e) {
			return false;
		}
		
		return true;
	}

	private AlarmManager getAlarmManager() {
		final AlarmManager am = (AlarmManager) this.ctx.getSystemService(Context.ALARM_SERVICE);

		return am;
	}
}
