import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BatteryUsagePage extends StatefulWidget {
  @override
  _BatteryUsagePageState createState() => _BatteryUsagePageState();
}

class _BatteryUsagePageState extends State<BatteryUsagePage> {
  // Create a MethodChannel to communicate with native Android code
  static const platform = MethodChannel('battery_usage');
  
  // Store battery usage data
  List<Map<String, dynamic>> batteryUsageData = [];

  @override
  void initState() {
    super.initState();
    // Fetch battery usage data when the page is initialized
    _fetchBatteryUsage();
  }

  // Method to fetch battery usage data from native Android code
  Future<void> _fetchBatteryUsage() async {
    try {
      // Call the native method to fetch the battery usage data
      final List<dynamic> result = await platform.invokeMethod('getBatteryUsage');
      
      // Update the state to display the data
      setState(() {
        batteryUsageData = result.map((data) => Map<String, dynamic>.from(data)).toList();
      });
    } on PlatformException catch (e) {
      print("Failed to get battery usage: ${e.message}");
    }
  }

  // Method to open the Usage Access settings if the permission is not granted
  Future<void> _openUsageAccessSettings() async {
    try {
      await platform.invokeMethod('openUsageAccessSettings');
    } on PlatformException catch (e) {
      print("Failed to open settings: ${e.message}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("📊 Battery Usage Per App")),
      body: batteryUsageData.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("🔒 Grant Usage Access"),
                  ElevatedButton(
                    onPressed: _openUsageAccessSettings,
                    child: Text("Open Settings"),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: batteryUsageData.length,
              itemBuilder: (context, index) {
                final app = batteryUsageData[index];
                return Card(
                  elevation: 3,
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    leading: Icon(Icons.battery_alert, color: Colors.greenAccent),
                    title: Text(app['packageName']),
                    subtitle: Text("Usage: ${app['usageTime']} sec"),
                  ),
                );
              },
            ),
    );
  }
}
