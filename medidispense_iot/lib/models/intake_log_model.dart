import 'package:cloud_firestore/cloud_firestore.dart';

/// Status enum for medication intake log verified by IR Sensor
enum IntakeStatus { taken, missed }

/// Data model representing intake telemetry history log
class IntakeLogModel {
  final String id;
  final String medicineName;
  final int compartmentSlot;
  final DateTime timestamp;
  final IntakeStatus status; // TAKEN (verified by IR beam break) vs MISSED
  final String irSensorTelemetry;

  IntakeLogModel({
    required this.id,
    required this.medicineName,
    required this.compartmentSlot,
    required this.timestamp,
    required this.status,
    this.irSensorTelemetry = 'IR_BEAM_BREAK_OK',
  });

  /// Status helper strings
  String get statusText => status == IntakeStatus.taken ? 'TAKEN' : 'MISSED';
  bool get isTaken => status == IntakeStatus.taken;

  factory IntakeLogModel.fromMap(Map<String, dynamic> map, String docId) {
    final statusStr = (map['status'] as String? ?? 'TAKEN').toUpperCase();
    final intakeStatus = statusStr == 'MISSED' ? IntakeStatus.missed : IntakeStatus.taken;

    DateTime parseTime(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return IntakeLogModel(
      id: docId,
      medicineName: map['medicineName'] as String? ?? 'Medication',
      compartmentSlot: (map['compartmentSlot'] as num?)?.toInt() ?? 1,
      timestamp: parseTime(map['timestamp']),
      status: intakeStatus,
      irSensorTelemetry: map['irSensorTelemetry'] as String? ?? 'IR_BEAM_PASS',
    );
  }

  factory IntakeLogModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return IntakeLogModel.fromMap(data, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'medicineName': medicineName,
      'compartmentSlot': compartmentSlot,
      'timestamp': Timestamp.fromDate(timestamp),
      'status': statusText,
      'irSensorTelemetry': irSensorTelemetry,
    };
  }
}
