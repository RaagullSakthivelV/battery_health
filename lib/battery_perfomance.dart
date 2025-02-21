import 'package:flutter/material.dart';
import 'package:battery_info/battery_info_plugin.dart';
import 'package:battery_info/model/android_battery_info.dart';
import 'package:battery_info/enums/charging_status.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class BatteryEnhancementsPage extends StatefulWidget {
  @override
  _BatteryEnhancementsPageState createState() =>
      _BatteryEnhancementsPageState();
}

class _BatteryEnhancementsPageState extends State<BatteryEnhancementsPage> {
  FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool notificationsEnabled = true;
  bool powerSavingMode = false;

  @override
  void initState() {
    super.initState();
    _initNotifications();
  }

  void _initNotifications() {
    var androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    var initSettings = InitializationSettings(android: androidInit);
    notificationsPlugin.initialize(initSettings);
  }

  void _sendBatteryNotification(String message) async {
    var androidDetails = AndroidNotificationDetails(
      'battery_channel',
      'Battery Alerts',
      importance: Importance.high,
      priority: Priority.high,
    );
    var notificationDetails = NotificationDetails(android: androidDetails);
    await notificationsPlugin.show(0, "Battery Alert", message, notificationDetails);
  }

  Widget _buildNotificationToggle() {
    return SwitchListTile(
      title: Text("🔔 Enable Battery Notifications"),
      subtitle: Text("Receive alerts when battery is low or fully charged."),
      value: notificationsEnabled,
      onChanged: (value) {
        setState(() {
          notificationsEnabled = value;
        });
      },
    );
  }

  Widget _buildPowerSavingToggle() {
    return SwitchListTile(
      title: Text("⚡ Enable Power-Saving Mode"),
      subtitle: Text("Optimize battery life with smart recommendations."),
      value: powerSavingMode,
      onChanged: (value) {
        setState(() {
          powerSavingMode = value;
        });
      },
    );
  }

  Widget _buildBatteryInsights() {
    return FutureBuilder<AndroidBatteryInfo?>(
      future: BatteryInfoPlugin().androidBatteryInfo,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          String status = snapshot.data?.chargingStatus == ChargingStatus.Charging
              ? "Charging"
              : "Not Charging";

          if (notificationsEnabled) {
            if ((snapshot.data?.batteryLevel??0 )<= 20) {
              _sendBatteryNotification("Battery is low! Consider charging.");
            }
            if ((snapshot.data?.batteryLevel??0) == 100) {
              _sendBatteryNotification("Battery is fully charged!");
            }
          }

          return Column(
            children: [
              _infoCard("⚡ Battery Health", snapshot.data?.health?.toUpperCase()??""),
              _infoCard("🔋 Charging Status", status),
              _infoCard("🔄 Usage Insights", "Estimated battery life: 6h 45m"),
              _infoCard("💡 Power-Saving Tip", "Reduce screen brightness to save power"),
            ],
          );
        }
        return CircularProgressIndicator();
      },
    );
  }

  Widget _infoCard(String title, String value) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.black45,
      child: ListTile(
        title: Text(title, style: TextStyle(color: Colors.white70)),
        trailing: Text(value, style: TextStyle(color: Colors.greenAccent, fontSize: 16)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("🚀 Battery Enhancements")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildNotificationToggle(),
            _buildPowerSavingToggle(),
            SizedBox(height: 20),
            Expanded(child: _buildBatteryInsights()),
          ],
        ),
      ),
    );
  }
}
