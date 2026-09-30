import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/schedule_model.dart';
import '../models/telemetry_model.dart';
import '../models/intake_log_model.dart';

/// Firebase Firestore Service handling real-time IoT Telemetry streams and Schedule CRUD
class FirestoreService {
  // Singleton Pattern
  static final FirestoreService instance = FirestoreService._internal();
  FirestoreService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Path Constants
  static const String devicePath = 'devices/ESP32_DISPENSER_01';
  static const String schedulesCollection = 'schedules';
  static const String logsCollection = 'intake_logs';

  /// Stream real-time connection status & telemetry of ESP32 board
  Stream<DeviceTelemetryModel> streamDeviceTelemetry() {
    try {
      return _db.doc(devicePath).snapshots().map((snapshot) {
        if (snapshot.exists && snapshot.data() != null) {
          return DeviceTelemetryModel.fromFirestore(snapshot);
        }
        // Fallback default online model if doc hasn't been created yet
        return DeviceTelemetryModel.initialMock();
      }).handleError((error) {
        debugPrint("Firestore Telemetry Stream Error: $error");
        return DeviceTelemetryModel.initialMock();
      });
    } catch (e) {
      debugPrint("Firebase stream init exception: $e");
      return Stream.value(DeviceTelemetryModel.initialMock());
    }
  }

  /// Stream real-time active medication schedules
  Stream<List<ScheduleModel>> streamSchedules() {
    try {
      return _db
          .collection(schedulesCollection)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((querySnapshot) {
        return querySnapshot.docs
            .map((doc) => ScheduleModel.fromFirestore(doc))
            .toList();
      }).handleError((error) {
        debugPrint("Firestore Schedules Stream Error: $error");
        return _getMockSchedules();
      });
    } catch (e) {
      debugPrint("Firebase stream init exception: $e");
      return Stream.value(_getMockSchedules());
    }
  }

  /// Stream real-time intake telemetry logs (verified by IR Sensor)
  Stream<List<IntakeLogModel>> streamIntakeLogs() {
    try {
      return _db
          .collection(logsCollection)
          .orderBy('timestamp', descending: true)
          .limit(20)
          .snapshots()
          .map((querySnapshot) {
        return querySnapshot.docs
            .map((doc) => IntakeLogModel.fromFirestore(doc))
            .toList();
      }).handleError((error) {
        debugPrint("Firestore Logs Stream Error: $error");
        return _getMockIntakeLogs();
      });
    } catch (e) {
      debugPrint("Firebase stream init exception: $e");
      return Stream.value(_getMockIntakeLogs());
    }
  }

  /// Add a new dosage schedule to Firestore & sync with ESP32
  Future<void> addSchedule(ScheduleModel schedule) async {
    try {
      final docRef = _db.collection(schedulesCollection).doc();
      final payload = schedule.copyWith(id: docRef.id).toMap();
      await docRef.set(payload);

      // Sync command to ESP32: Format SET:Slot:HH:mm
      final syncString = "SET:${schedule.compartmentSlot}:${schedule.targetTime}";
      
      await _db.doc(devicePath).set({
        'lastScheduleUpdate': FieldValue.serverTimestamp(),
        'syncCommand': syncString,
        'activeCount': FieldValue.increment(1),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Error adding schedule: $e");
      rethrow;
    }
  }

  /// Delete an existing medication schedule
  Future<void> deleteSchedule(String scheduleId) async {
    try {
      await _db.collection(schedulesCollection).doc(scheduleId).delete();
      
      await _db.doc(devicePath).set({
        'lastScheduleUpdate': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Error deleting schedule $scheduleId: $e");
      rethrow;
    }
  }

  /// Trigger immediate "Test Dispense" command to ESP32 via Firestore
  Future<void> triggerTestDispense({
    required int compartmentSlot,
    required String medicineName,
    String? scheduleId,
  }) async {
    try {
      final now = DateTime.now();

      // 1. Send hardware payload to ESP32 board path (String format as requested)
      // Format DISPENSE:Slot
      final commandStr = "DISPENSE:$compartmentSlot";

      await _db.doc(devicePath).set({
        'command': commandStr,
        'targetSlot': compartmentSlot,
        'medicineName': medicineName,
        'commandTimestamp': FieldValue.serverTimestamp(),
        'status': 'PENDING_DISPENSE',
      }, SetOptions(merge: true));

      // 2. Decrement stock if scheduleId is provided
      if (scheduleId != null && scheduleId.isNotEmpty && !scheduleId.startsWith('mock_')) {
        await _db.collection(schedulesCollection).doc(scheduleId).update({
          'stockCount': FieldValue.increment(-1),
        });
      }

      // 3. Create instant intake log entry (IR sensor verified simulation)
      final logRef = _db.collection(logsCollection).doc();
      await logRef.set({
        'medicineName': medicineName,
        'compartmentSlot': compartmentSlot,
        'timestamp': Timestamp.fromDate(now),
        'status': 'TAKEN',
        'irSensorTelemetry': 'IR_BEAM_BREAK_CONFIRMED',
      });
    } catch (e) {
      debugPrint("Error triggering test dispense: $e");
      rethrow;
    }
  }

  /// Simulate a hardware failure
  Future<void> simulateHardwareError({required String errorType}) async {
    try {
      await _db.doc(devicePath).set({
        'lastError': errorType,
        'errorTimestamp': FieldValue.serverTimestamp(),
        'isOnline': true,
        'status': 'HARDWARE_FAULT',
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Error simulating hardware fault: $e");
    }
  }

  /// Update device connectivity
  Future<void> updateDeviceConnectivity(bool isOnline) async {
    try {
      await _db.doc(devicePath).set({
        'isOnline': isOnline,
        'lastSeen': FieldValue.serverTimestamp(),
        'status': isOnline ? 'READY' : 'DISCONNECTED',
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Error updating connectivity: $e");
    }
  }

  // --- Fallback Mock Data ---
  List<ScheduleModel> _getMockSchedules() {
    return [
      ScheduleModel(
        id: 'mock_1',
        medicineName: 'Amoxicillin 500mg',
        dosage: '1 Capsule',
        targetTime: '08:00',
        compartmentSlot: 1,
        stockCount: 8,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      ScheduleModel(
        id: 'mock_2',
        medicineName: 'Metformin 850mg',
        dosage: '1 Tablet',
        targetTime: '13:00',
        compartmentSlot: 2,
        stockCount: 2,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }

  List<IntakeLogModel> _getMockIntakeLogs() {
    final now = DateTime.now();
    return [
      IntakeLogModel(
        id: 'log_1',
        medicineName: 'Amoxicillin 500mg',
        compartmentSlot: 1,
        timestamp: now.subtract(const Duration(hours: 2)),
        status: IntakeStatus.taken,
      ),
    ];
  }
}
