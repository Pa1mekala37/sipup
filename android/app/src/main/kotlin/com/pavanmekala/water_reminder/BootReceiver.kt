package com.pavanmekala.water_reminder

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import androidx.work.Constraints
import androidx.work.ExistingWorkPolicy
import androidx.work.NetworkType
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.WorkManager
import be.tramckrijte.workmanager.BackgroundWorker

/**
 * Reschedules all notifications after device reboot.
 * WorkManager ensures reminders are restored even in Doze mode.
 */
class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val validActions = setOf(
            Intent.ACTION_BOOT_COMPLETED,
            Intent.ACTION_LOCKED_BOOT_COMPLETED,
            Intent.ACTION_MY_PACKAGE_REPLACED
        )
        if (intent.action !in validActions) return

        // Enqueue a one-time WorkManager task to reschedule all reminders
        val workRequest = OneTimeWorkRequestBuilder<BackgroundWorker>()
            .setInputData(
                androidx.work.Data.Builder()
                    .putString("be.tramckrijte.workmanager.DART_TASK", "reschedule_reminders")
                    .putBoolean("be.tramckrijte.workmanager.IS_IN_DEBUG_MODE", false)
                    .build()
            )
            .setConstraints(
                Constraints.Builder()
                    .setRequiredNetworkType(NetworkType.NOT_REQUIRED)
                    .build()
            )
            .build()

        WorkManager.getInstance(context).enqueueUniqueWork(
            "reschedule_on_boot",
            ExistingWorkPolicy.REPLACE,
            workRequest
        )
    }
}
