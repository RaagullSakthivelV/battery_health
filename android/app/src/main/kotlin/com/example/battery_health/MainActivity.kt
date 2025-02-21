package com.example.battery_health

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Context
import android.app.usage.UsageStatsManager
import android.content.Intent
import android.provider.Settings
import java.util.Calendar


class MainActivity : FlutterActivity() {
    private val CHANNEL = "battery_usage"  // Define the channel name
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Set up the MethodChannel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getBatteryUsage") {
                val batteryUsage = getBatteryUsageStats()
                result.success(batteryUsage)
            } else if (call.method == "openUsageAccessSettings") {
                openUsageAccessSettings()
                result.success(true)
            } else {
                result.notImplemented()  // Handle unimplemented methods
            }
        }
    }

    // Function to get battery usage stats from Android
    private fun getBatteryUsageStats(): List<Map<String, Any>> {
        val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val calendar = Calendar.getInstance()
        calendar.add(Calendar.DAY_OF_MONTH, -1)  // Set time range to the last 24 hours
        val usageStatsList = usageStatsManager.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY,
            calendar.timeInMillis,
            System.currentTimeMillis()
        )

        val appUsageData = mutableListOf<Map<String, Any>>()

        // Loop through each app's usage stats and add it to the list
        for (usageStats in usageStatsList) {
            val packageName = usageStats.packageName
            val totalTimeInForeground = usageStats.totalTimeInForeground / 1000  // Convert to seconds
            if (totalTimeInForeground > 0) {
                appUsageData.add(
                    mapOf(
                        "packageName" to packageName,
                        "usageTime" to totalTimeInForeground
                    )
                )
            }
        }

        // Sort the list by usage time in descending order
        return appUsageData.sortedByDescending { it["usageTime"] as Long }
    }

    // Function to open the Usage Access settings page
    private fun openUsageAccessSettings() {
        val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
        startActivity(intent)
    }
}
