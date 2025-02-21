import 'package:battery_health/BatteryUsagePage.dart';
import 'package:battery_health/battery_perfomance.dart';
import 'package:flutter/material.dart';
import 'package:battery_info/battery_info_plugin.dart';
import 'package:battery_info/model/android_battery_info.dart';
import 'package:battery_info/enums/charging_status.dart';

void main() {
  runApp(BatteryApp());
}

class BatteryApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.greenAccent,
      ),
      home: BatteryHomePage(),
    );
  }
}

class BatteryHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Battery Monitor ⚡"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildBatteryIndicator(),
            const SizedBox(height: 20),
            Expanded(child: _buildBatteryDetails()),
             const SizedBox(height: 20),
           _buildEnhancementsButton(context),
             const SizedBox(height: 20),
            _buildBatteryUsageButton(context),
          ],
        ),
      ),
    );
  }

   /// Battery Enhancements Button
  Widget _buildEnhancementsButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BatteryEnhancementsPage()),
        );
      },
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        backgroundColor: Colors.greenAccent, // Button color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        "🚀 Battery Enhancements",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

    /// Battery Usage Button
  Widget _buildBatteryUsageButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BatteryUsagePage()),
        );
      },
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        backgroundColor: Colors.greenAccent, // Button color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        "📊 Battery Usage",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  /// Battery Level Indicator UI
  Widget _buildBatteryIndicator() {
    return FutureBuilder<AndroidBatteryInfo?>(
      future: BatteryInfoPlugin().androidBatteryInfo,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          double batteryLevel = snapshot.data?.batteryLevel?.toDouble()??0.0;
          return Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 150,
                    width: 150,
                    child: CircularProgressIndicator(
                      value: batteryLevel / 100,
                      strokeWidth: 8,
                      backgroundColor: Colors.grey.shade800,
                      valueColor: AlwaysStoppedAnimation(
                        batteryLevel > 20 ? Colors.greenAccent : Colors.redAccent,
                      ),
                    ),
                  ),
                  Text(
                    "${batteryLevel.toInt()}%",
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                "Battery Health: ${snapshot.data?.health?.toUpperCase()}",
                style: const TextStyle(fontSize: 16, color: Colors.white70),
              ),
            ],
          );
        }
        return const CircularProgressIndicator();
      },
    );
  }

  /// Battery Details (Live Data)
  Widget _buildBatteryDetails() {
    return StreamBuilder<AndroidBatteryInfo?>(
      stream: BatteryInfoPlugin().androidBatteryInfoStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView(
            children: [
              _infoCard("🔌 Voltage", "${snapshot.data?.voltage} mV"),
              _infoCard("⚡ Charging", snapshot.data?.chargingStatus?.toString().split(".")[1]??""),
              _infoCard("🔋 Capacity", "${(snapshot.data?.batteryCapacity??1 / 1000000)} mAh"),
              _infoCard("⚙️ Technology", snapshot.data?.technology??""),
              _infoCard("🔘 Scale", "${snapshot.data?.scale}"),
              _infoCard("⚡ Remaining Energy", "${-(snapshot.data?.remainingEnergy??1 * 1.0E-9)} Wh"),
              _getChargeTime(snapshot.data!),
            ],
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  /// Battery Information Card UI
  Widget _infoCard(String title, String value) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.black45,
      child: ListTile(
        title: Text(title, style: const TextStyle(color: Colors.white70)),
        trailing: Text(value, style: const TextStyle(color: Colors.greenAccent, fontSize: 16)),
      ),
    );
  }

  /// Charge Time Remaining UI
  Widget _getChargeTime(AndroidBatteryInfo data) {
    String text;
    if (data.chargingStatus == ChargingStatus.Charging) {
      text = data.chargeTimeRemaining == -1
          ? "🔄 Calculating..."
          : "⏳ ${((data.chargeTimeRemaining??1 / 1000) / 60).truncate()} min left";
    } else {
      text = "🔋 Battery is full or unplugged";
    }
    return _infoCard("⏳ Charge Time Remaining", text);
  }
}
