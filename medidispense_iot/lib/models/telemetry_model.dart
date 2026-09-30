import 'package:cloud_firestore/cloud_firestore.dart';

/// Data model representing ESP32 Hardware Telemetry status
class DeviceTelemetryModel {
  final String deviceId;
  final bool isOnline;
  final int wifiRssi; // WiFi Signal Strength (dBm)
  final DateTime lastSeen;
  final int batteryPercent;
  final String firmwareVersion;
  final int? pendingDispenseSlot;

  DeviceTelemetryModel({
    required this.deviceId,
    required this.isOnline,
    this.wifiRssi = -65,
    DateTime? lastSeen,
    this.batteryPercent = 98,
    this.firmwareVersion = 'v2.1.4-IoT',
    this.pendingDispenseSlot,
  }) : lastSeen = lastSeen ?? DateTime.now();

  /// Create model from Firestore DocumentSnapshot or Map
  factory DeviceTelemetryModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parseDateTime(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return DeviceTelemetryModel(
      deviceId: docId,
      isOnline: map['isOnline'] as bool? ?? false,
      wifiRssi: (map['wifiRssi'] as num?)?.toInt() ?? -65,
      lastSeen: parseDateTime(map['lastSeen']),
      batteryPercent: (map['batteryPercent'] as num?)?.toInt() ?? 95,
      firmwareVersion: map['firmwareVersion'] as String? ?? 'v2.1.0-IoT',
      pendingDispenseSlot: (map['pendingDispenseSlot'] as num?)?.toInt(),
    );
  }

  factory DeviceTelemetryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return DeviceTelemetryModel.fromMap(data, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'isOnline': isOnline,
      'wifiRssi': wifiRssi,
      'lastSeen': Timestamp.fromDate(lastSeen),
      'batteryPercent': batteryPercent,
      'firmwareVersion': firmwareVersion,
      'pendingDispenseSlot': pendingDispenseSlot,
    };
  }

  /// Initial fallback telemetry for initial loading / simulation
  factory DeviceTelemetryModel.initialMock() {
    return DeviceTelemetryModel(
      deviceId: 'ESP32_DISPENSER_01',
      isOnline: true,
      wifiRssi: -58,
      lastSeen: DateTime.now(),
      batteryPercent: 96,
      firmwareVersion: 'v2.4-CYBER',
    );
  }
}
