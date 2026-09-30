import 'dart:async';
import 'package:flutter/material.dart';
import 'firestore_service.dart';
import '../models/telemetry_model.dart';

/// Simulation Service for ESP32 DevKit v1 Hardware Components
/// Manages the state of Servo (GPIO 18), IR Sensor (GPIO 4), and Alerts (GPIO 5/2)
class HardwareService extends ChangeNotifier {
  // Singleton
  static final HardwareService instance = HardwareService._internal();
  HardwareService._internal();

  final FirestoreService _firestore = FirestoreService.instance;

  // Simulation State
  bool _isSimulationMode = false;
  bool get isSimulationMode => _isSimulationMode;

  // Hardware Status
  String _servoStatus = 'IDLE (GPIO 18)';
  String _irSensorStatus = 'WAITING (GPIO 4)';
  bool _isBuzzerActive = false;
  bool _isLedActive = false;
  List<String> _hardwareLogs = [];

  String get servoStatus => _servoStatus;
  String get irSensorStatus => _irSensorStatus;
  bool get isBuzzerActive => _isBuzzerActive;
  bool get isLedActive => _isLedActive;
  List<String> get hardwareLogs => _hardwareLogs;

  void toggleSimulationMode(bool value) {
    _isSimulationMode = value;
    _addLog("Simulation Mode: ${value ? 'ENABLED' : 'DISABLED'}");
    
    // Automatically set device online in Firestore when simulation starts
    if (value) {
      _firestore.streamDeviceTelemetry().first.then((t) {
        _firestore.triggerTestDispense(compartmentSlot: 0, medicineName: 'SIMULATION_LINK');
      });
    }

    notifyListeners();
  }

  void _addLog(String message) {
    final timestamp = DateTime.now().toString().split(' ')[1].split('.')[0];
    _hardwareLogs.insert(0, "[$timestamp] $message");
    if (_hardwareLogs.length > 50) _hardwareLogs.removeLast();
    notifyListeners();
  }

  /// Simulates the physical hardware dispense cycle:
  /// 1. Servo rotates (GPIO 18)
  /// 2. IR Sensor detects pill drop (GPIO 4)
  /// 3. Buzzer/LED confirmation (GPIO 5/2)
  Future<void> simulateDispenseCycle(int slot, String medicine) async {
    if (!_isSimulationMode) return;

    _addLog("Starting dispense cycle for $medicine (Slot $slot)");
    
    // 1. Servo Activation
    _servoStatus = 'ROTATING 90°...';
    _isLedActive = true;
    _addLog("GPIO 18: PWM High - Rotating Servo");
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 800));

    // 2. IR Sensor Detection
    _servoStatus = 'RETURNING...';
    _irSensorStatus = 'PILL DETECTED!';
    _addLog("GPIO 4: Logic LOW - IR Beam Broken (Pill Passed)");
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));

    // 3. Feedback Alert
    _servoStatus = 'IDLE';
    _isBuzzerActive = true;
    _addLog("GPIO 5: Buzzer ON - Dispense Confirmed");
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 1000));

    // Reset
    _isBuzzerActive = false;
    _isLedActive = false;
    _irSensorStatus = 'WAITING';
    _addLog("Dispense cycle complete. System Ready.");
    notifyListeners();

    // Sync with Firestore (Mocking hardware-to-cloud update)
    await _firestore.triggerTestDispense(
      compartmentSlot: slot,
      medicineName: medicine,
    );
  }

  void toggleBuzzer(bool active) {
    _isBuzzerActive = active;
    _addLog("GPIO 5: Buzzer ${active ? 'ON' : 'OFF'}");
    notifyListeners();
  }

  void toggleLed(bool active) {
    _isLedActive = active;
    _addLog("GPIO 2: Status LED ${active ? 'ON' : 'OFF'}");
    notifyListeners();
  }

  void clearLogs() {
    _hardwareLogs.clear();
    notifyListeners();
  }
}
