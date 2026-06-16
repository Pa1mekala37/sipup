package com.pavanmekala.water_reminder

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.app.NotificationManager

/**
 * Handles notification action buttons (Drank, Snooze, Skip)
 * without requiring the app to be open.
 */
class NotificationActionReceiver : BroadcastReceiver() {

    companion object {
        const val ACTION_DRANK = "com.pavanmekala.water_reminder.ACTION_DRANK"
        const val ACTION_SNOOZE = "com.pavanmekala.water_reminder.ACTION_SNOOZE"
        const val ACTION_SKIP = "com.pavanmekala.water_reminder.ACTION_SKIP"
        const val EXTRA_NOTIFICATION_ID = "notification_id"
    }

    override fun onReceive(context: Context, intent: Intent) {
        val notificationId = intent.getIntExtra(EXTRA_NOTIFICATION_ID, -1)
        val notificationManager =
            context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        when (intent.action) {
            ACTION_DRANK -> {
                // Dismiss the notification — Flutter side handles the log via
                // flutter_local_notifications callback when app is open,
                // or WorkManager on next sync
                if (notificationId >= 0) {
                    notificationManager.cancel(notificationId)
                }
            }
            ACTION_SNOOZE -> {
                if (notificationId >= 0) {
                    notificationManager.cancel(notificationId)
                }
                // Snooze scheduling is handled by flutter_local_notifications
                // on the next foreground open or via WorkManager task
            }
            ACTION_SKIP -> {
                if (notificationId >= 0) {
                    notificationManager.cancel(notificationId)
                }
            }
        }
    }
}
