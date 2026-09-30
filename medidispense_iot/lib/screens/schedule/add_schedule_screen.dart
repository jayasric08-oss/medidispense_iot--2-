import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/schedule_model.dart';
import '../../services/firestore_service.dart';
import '../../utils/theme.dart';
import '../../widgets/cyber_card.dart';

/// Screen B: Add Schedule Screen form to program dosage times & ESP32 compartment slots
class AddScheduleScreen extends StatefulWidget {
  const AddScheduleScreen({super.key});

  @override
  State<AddScheduleScreen> createState() => _AddScheduleScreenState();
}

class _AddScheduleScreenState extends State<AddScheduleScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService.instance;

  // Form Controllers
  final TextEditingController _medicineNameController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController(text: '1 Tablet');
  final TextEditingController _stockController = TextEditingController(text: '10');
  final TextEditingController _thresholdController = TextEditingController(text: '3');

  // Selected State
  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 0);
  int _selectedSlot = 1; // Default Slot 1 (Slots 1 to 4)
  bool _isSubmitting = false;

  @override
  void dispose() {
    _medicineNameController.dispose();
    _dosageController.dispose();
    _stockController.dispose();
    _thresholdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CyberMedicalTheme.background,
      appBar: AppBar(
        title: Text(
          'Add Dosage Schedule',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: CyberMedicalTheme.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: CyberMedicalTheme.primaryAccent),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Banner
                CyberCard(
                  borderColor: CyberMedicalTheme.primaryAccent.withValues(alpha: 0.3),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: CyberMedicalTheme.primaryAccent.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.build_circle_outlined,
                          color: CyberMedicalTheme.primaryAccent,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ESP32 Sync Ready',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: CyberMedicalTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'New schedule payloads sync automatically with the IoT hardware dispenser.',
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                color: CyberMedicalTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 1. Medicine Name Field
                Text(
                  'MEDICINE NAME',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: CyberMedicalTheme.primaryAccent,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _medicineNameController,
                  style: const TextStyle(color: CyberMedicalTheme.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'e.g. Amoxicillin 500mg',
                    prefixIcon: Icon(Icons.medication_outlined, color: CyberMedicalTheme.primaryAccent),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a valid medicine name';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // 2. Dosage & Inventory Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DOSAGE',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: CyberMedicalTheme.primaryAccent,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _dosageController,
                            style: const TextStyle(color: CyberMedicalTheme.textPrimary),
                            decoration: const InputDecoration(
                              hintText: '1 Tablet',
                              prefixIcon: Icon(Icons.vaccines_outlined, color: CyberMedicalTheme.primaryAccent),
                            ),
                            validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'STOCK',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: CyberMedicalTheme.secondaryAccent,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _stockController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: CyberMedicalTheme.textPrimary),
                            decoration: const InputDecoration(
                              hintText: '20',
                              prefixIcon: Icon(Icons.inventory_2_outlined, color: CyberMedicalTheme.secondaryAccent),
                            ),
                            validator: (value) => value == null || int.tryParse(value) == null ? 'Invalid' : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // 3. Target Time Picker
                Text(
                  'TARGET DISPENSE TIME',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: CyberMedicalTheme.primaryAccent,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                CyberCard(
                  margin: EdgeInsets.zero,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  onTap: () => _pickTime(context),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time_filled_rounded,
                            color: CyberMedicalTheme.secondaryAccent,
                            size: 24,
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedTime.format(context),
                                style: GoogleFonts.outfit(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: CyberMedicalTheme.textPrimary,
                                ),
                              ),
                              Text(
                                '24h Sync Format: ${ScheduleModel.formatTimeOfDay(_selectedTime)}',
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  color: CyberMedicalTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: CyberMedicalTheme.secondaryAccent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: CyberMedicalTheme.secondaryAccent),
                        ),
                        child: Text(
                          'CHANGE TIME',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: CyberMedicalTheme.secondaryAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 4. Compartment Selection
                Text(
                  'HARDWARE COMPARTMENT SLOT (1-4)',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: CyberMedicalTheme.primaryAccent,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: List.generate(4, (index) {
                    final slotNumber = index + 1;
                    final isSelected = _selectedSlot == slotNumber;

                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedSlot = slotNumber;
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? CyberMedicalTheme.primaryAccent.withValues(alpha: 0.2)
                                : CyberMedicalTheme.cardSurface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? CyberMedicalTheme.primaryAccent
                                  : CyberMedicalTheme.dividerColor,
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: isSelected
                                ? CyberMedicalTheme.cyberGlow(
                                    color: CyberMedicalTheme.primaryAccent, opacity: 0.3)
                                : null,
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.grid_view_rounded,
                                color: isSelected
                                    ? CyberMedicalTheme.primaryAccent
                                    : CyberMedicalTheme.textMuted,
                                size: 22,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'SLOT $slotNumber',
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: isSelected
                                      ? CyberMedicalTheme.primaryAccent
                                      : CyberMedicalTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 36),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitSchedule,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.black,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.cloud_upload_outlined, size: 22),
                              const SizedBox(width: 10),
                              Text(
                                'SYNC & SAVE SCHEDULE',
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: CyberMedicalTheme.primaryAccent,
              onPrimary: Colors.black,
              surface: CyberMedicalTheme.cardSurface,
              onSurface: CyberMedicalTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _submitSchedule() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final newSchedule = ScheduleModel(
        id: '',
        medicineName: _medicineNameController.text.trim(),
        dosage: _dosageController.text.trim(),
        targetTime: ScheduleModel.formatTimeOfDay(_selectedTime),
        compartmentSlot: _selectedSlot,
        stockCount: int.parse(_stockController.text),
        lowStockThreshold: int.parse(_thresholdController.text),
        isActive: true,
      );

      await _firestoreService.addSchedule(newSchedule);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: CyberMedicalTheme.success),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Schedule created and synced with ESP32 Slot $_selectedSlot!',
                ),
              ),
            ],
          ),
          backgroundColor: CyberMedicalTheme.cardSurface,
          duration: const Duration(seconds: 3),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save schedule: $e'),
          backgroundColor: CyberMedicalTheme.warningAlert,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
