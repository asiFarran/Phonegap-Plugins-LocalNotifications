package com.stratogos.cordova.localNotification;

import org.json.JSONException;
import org.json.JSONObject;
import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.support.v4.app.NotificationCompat;

public class AlarmReceiver extends BroadcastReceiver {

	@Override
	public void onReceive(Context context, Intent intent)  {

		try {
			
			String json = intent.getExtras().getString(LocalNotificationPlugin.PLUGIN_NAME);
			
			JSONObject params = new JSONObject(json);			
			
			final int id = params.getInt("id");
			
			final NotificationManager notificationMgr = 
					(NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);

			final Intent notificationIntent = new Intent(context, NotificationHandlerActivity.class).putExtra(LocalNotificationPlugin.PLUGIN_NAME, json);					
			final PendingIntent contentIntent = PendingIntent.getActivity(context, 0, notificationIntent, PendingIntent.FLAG_UPDATE_CURRENT);

			NotificationCompat.Builder mBuilder =
				    new NotificationCompat.Builder(context)
					    .setSmallIcon(context.getApplicationInfo().icon)
					    .setContentTitle(params.getString("title"))
					    .setContentText(params.getString("message"))				    
					    .setDefaults(Notification.DEFAULT_ALL)
					    .setContentIntent(contentIntent)
					    .setAutoCancel(true);

			notificationMgr.notify(id, mBuilder.build());
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
}
	
