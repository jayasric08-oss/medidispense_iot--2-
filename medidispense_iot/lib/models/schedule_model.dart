import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Data model representing an active pill dispense schedule
class ScheduleModel {
  final String id;
  final String medicineName;
  final String dosage;
  final String targetTime; // Stored as "HH:mm" 24h format for ESP32 sync (e.g. "08:30", "20:00")
  final int compartmentSlot; // Compartment 1, 2, 3, or 4
  final bool isActive;
  final DateTime createdAt;
  
  // Inventory Tracking fields
  final int stockCount;
  final int lowStockThreshold;

  ScheduleModel({
    required this.id,
    required this.medicineName,
    required this.dosage,
    required this.targetTime,
    required this.compartmentSlot,
    this.isActive = true,
    this.stockCount = 10,
    this.lowStockThreshold = 3,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Convert TimeOfDay to standard HH:mm string format
  static String formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Format HH:mm string to user-friendly 12-hour AM/PM string
  String get displayTime {
    try {
      final parts = targetTime.split(':');
      if (parts.length != 2) return targetTime;
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final tod = TimeOfDay(hour: hour, minute: minute);
      final hour12 = tod.hourOfPeriod == 0 ? 12 : tod.hourOfPeriod;
      final period = tod.period == DayPeriod.am ? 'AM' : 'PM';
      final minStr = tod.minute.toString().padLeft(2, '0');
      return '$hour12:$minStr $period';
    } catch (_) {
      return targetTime;
    }
  }

  /// Create model from Firestore Map
  factory ScheduleModel.fromMap(Map<String, dynamic> map, String docId) {
    return ScheduleModel(
      id: docId,
      medicineName: map['medicineName'] as String? ?? 'Medication',
      dosage: map['dosage'] as String? ?? '1 Unit',
      targetTime: map['targetTime'] as String? ?? '08:00',
      compartmentSlot: (map['compartmentSlot'] as num?)?.toInt() ?? 1,
      isActive: map['isActive'] as bool? ?? true,
      stockCount: (map['stockCount'] as num?)?.toInt() ?? 10,
      lowStockThreshold: (map['lowStockThreshold'] as num?)?.toInt() ?? 3,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  /// Create model from Firestore DocumentSnapshot
  factory ScheduleModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ScheduleModel.fromMap(data, doc.id);
  }

  /// Convert model to Map for Firestore payload
  Map<String, dynamic> toMap() {
    return {
      'medicineName': medicineName,
      'dosage': dosage,
      'targetTime': targetTime,
      'compartmentSlot': compartmentSlot,
      'isActive': isActive,
      'stockCount': stockCount,
      'lowStockThreshold': lowStockThreshold,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Copy instance with updated fields
  ScheduleModel copyWith({
    String? id,
    String? medicineName,
    String? dosage,
    String? targetTime,
    int? compartmentSlot,
    bool? isActive,
    int? stockCount,
    int? lowStockThreshold,
    DateTime? createdAt,
  }) {
    return ScheduleModel(
      id: id ?? this.id,
      medicineName: medicineName ?? this.medicineName,
      dosage: dosage ?? this.dosage,
      targetTime: targetTime ?? this.targetTime,
      compartmentSlot: compartmentSlot ?? this.compartmentSlot,
      isActive: isActive ?? this.isActive,
      stockCount: stockCount ?? this.stockCount,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
