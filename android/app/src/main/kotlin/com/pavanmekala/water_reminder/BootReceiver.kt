package com.pavanmekala.water_reminder

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        // flutter_local_notifications registers its own ScheduledNotificationBootReceiver
        // which reschedules all pending alarms after device reboot automatically.
        // No additional action required here.
    }
}
