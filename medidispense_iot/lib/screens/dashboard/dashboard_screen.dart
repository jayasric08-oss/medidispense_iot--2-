import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../models/schedule_model.dart';
import '../../models/telemetry_model.dart';
import '../../models/intake_log_model.dart';
import '../../services/firestore_service.dart';
import '../../services/hardware_service.dart';
import '../../utils/theme.dart';
import '../../widgets/cyber_card.dart';
import '../../widgets/status_pill.dart';
import '../../widgets/slot_badge.dart';
import '../schedule/add_schedule_screen.dart';

/// Screen A: Main Telemetry Dashboard for MediDispense IoT
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirestoreService _firestoreService = FirestoreService.instance;
  final HardwareService _hardwareService = HardwareService.instance;
  final Set<String> _pendingDispenses = {};

  @override
  void initState() {
    super.initState();
    _hardwareService.addListener(_onHardwareStateChanged);
  }

  @override
  void dispose() {
    _hardwareService.removeListener(_onHardwareStateChanged);
    super.dispose();
  }

  void _onHardwareStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CyberMedicalTheme.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: CyberMedicalTheme.primaryAccent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: CyberMedicalTheme.primaryAccent.withValues(alpha: 0.4),
                ),
              ),
              child: const Icon(
                Icons.medical_services_outlined,
                color: CyberMedicalTheme.primaryAccent,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MediDispense IoT',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: CyberMedicalTheme.textPrimary,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'Automated Pill Telemetry System',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: CyberMedicalTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: CyberMedicalTheme.primaryAccent),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: CyberMedicalTheme.primaryAccent,
          backgroundColor: CyberMedicalTheme.cardSurface,
          onRefresh: () async => setState(() {}),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHardwareTelemetryBanner(),
                const SizedBox(height: 24),
                _buildHardwareSimulationPanel(),
                const SizedBox(height: 24),

                // Active Schedule & Inventory
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.inventory_2_outlined, color: CyberMedicalTheme.primaryAccent, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Inventory & Schedules',
                          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: CyberMedicalTheme.textPrimary),
                        ),
                      ],
                    ),
                    TextButton.icon(
                      onPressed: () => _navigateToAddSchedule(context),
                      icon: const Icon(Icons.add_circle_outline, size: 18, color: CyberMedicalTheme.primaryAccent),
                      label: Text('Add New', style: GoogleFonts.outfit(color: CyberMedicalTheme.primaryAccent, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildScheduleListStream(),

                const SizedBox(height: 28),

                // Intake History
                Row(
                  children: [
                    const Icon(Icons.history_toggle_off_rounded, color: CyberMedicalTheme.secondaryAccent, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Dose History Log',
                      style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: CyberMedicalTheme.textPrimary),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildIntakeLogStream(),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddSchedule(context),
        icon: const Icon(Icons.add_alarm_rounded, color: Colors.black),
        label: Text('NEW DOSAGE', style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.w800)),
      ),
    );
  }

  Widget _buildHardwareSimulationPanel() {
    return CyberCard(
      borderColor: _hardwareService.isSimulationMode
          ? CyberMedicalTheme.secondaryAccent.withValues(alpha: 0.5)
          : CyberMedicalTheme.dividerColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.developer_board_rounded, color: _hardwareService.isSimulationMode ? CyberMedicalTheme.secondaryAccent : CyberMedicalTheme.textMuted, size: 20),
                  const SizedBox(width: 8),
                  Text('ESP32 Hardware Simulation', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: CyberMedicalTheme.textPrimary)),
                ],
              ),
              Switch.adaptive(
                value: _hardwareService.isSimulationMode,
                activeColor: CyberMedicalTheme.secondaryAccent,
                onChanged: (val) => _hardwareService.toggleSimulationMode(val),
              ),
            ],
          ),
          if (_hardwareService.isSimulationMode) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildGpioStatusBadge('GPIO 18 (SERVO)', _hardwareService.servoStatus, Icons.settings_input_component_rounded),
                _buildGpioStatusBadge('GPIO 4 (IR)', _hardwareService.irSensorStatus, Icons.sensors_rounded),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildHardwareToggleButton(label: 'BUZZER (GP5)', isActive: _hardwareService.isBuzzerActive, icon: Icons.volume_up_rounded, onToggle: (val) => _hardwareService.toggleBuzzer(val))),
                const SizedBox(width: 12),
                Expanded(child: _buildHardwareToggleButton(label: 'STATUS LED (GP2)', isActive: _hardwareService.isLedActive, icon: Icons.lightbulb_outline_rounded, onToggle: (val) => _hardwareService.toggleLed(val))),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 100, width: double.infinity, padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(12), border: Border.all(color: CyberMedicalTheme.dividerColor)),
              child: ListView.builder(
                itemCount: _hardwareService.hardwareLogs.length,
                itemBuilder: (context, index) => Text(_hardwareService.hardwareLogs[index], style: GoogleFonts.jetBrainsMono(fontSize: 10, color: CyberMedicalTheme.success.withValues(alpha: 0.8))),
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildGpioStatusBadge(String label, String status, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w600, color: CyberMedicalTheme.textMuted)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(color: CyberMedicalTheme.background, borderRadius: BorderRadius.circular(8), border: Border.all(color: CyberMedicalTheme.dividerColor)),
          child: Row(
            children: [
              Icon(icon, size: 14, color: CyberMedicalTheme.primaryAccent),
              const SizedBox(width: 6),
              Text(status, style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.w700, color: CyberMedicalTheme.textPrimary)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHardwareToggleButton({required String label, required bool isActive, required IconData icon, required Function(bool) onToggle}) {
    return InkWell(
      onTap: () => onToggle(!isActive),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? CyberMedicalTheme.secondaryAccent.withValues(alpha: 0.15) : CyberMedicalTheme.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isActive ? CyberMedicalTheme.secondaryAccent : CyberMedicalTheme.dividerColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: isActive ? CyberMedicalTheme.secondaryAccent : CyberMedicalTheme.textMuted),
            const SizedBox(width: 8),
            Text(label, style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w700, color: isActive ? CyberMedicalTheme.textPrimary : CyberMedicalTheme.textMuted)),
          ],
        ),
      ),
    );
  }

  Widget _buildHardwareTelemetryBanner() {
    return StreamBuilder<DeviceTelemetryModel>(
      stream: _firestoreService.streamDeviceTelemetry(),
      builder: (context, snapshot) {
        final telemetry = snapshot.data ?? DeviceTelemetryModel.initialMock();
        return CyberCard(
          borderColor: telemetry.isOnline ? CyberMedicalTheme.primaryAccent.withValues(alpha: 0.35) : CyberMedicalTheme.warningAlert.withValues(alpha: 0.35),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.memory_rounded, color: CyberMedicalTheme.primaryAccent, size: 24),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(telemetry.deviceId, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700, color: CyberMedicalTheme.textPrimary)),
                          Text('ESP32 Firmware: ${telemetry.firmwareVersion}', style: GoogleFonts.outfit(fontSize: 11, color: CyberMedicalTheme.textMuted)),
                        ],
                      ),
                    ],
                  ),
                  HardwareStatusPill(isOnline: telemetry.isOnline),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(color: CyberMedicalTheme.dividerColor, height: 1),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMetricTile(icon: Icons.wifi_rounded, label: 'Signal', value: '${telemetry.wifiRssi} dBm', color: CyberMedicalTheme.primaryAccent),
                  _buildMetricTile(icon: Icons.battery_charging_full_rounded, label: 'Power', value: '${telemetry.batteryPercent}%', color: CyberMedicalTheme.success),
                  _buildMetricTile(icon: Icons.sync_rounded, label: 'Last Sync', value: DateFormat('hh:mm a').format(telemetry.lastSeen), color: CyberMedicalTheme.secondaryAccent),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricTile({required IconData icon, required String label, required String value, required Color color}) {
    return Column(
      children: [
        Row(children: [Icon(icon, size: 14, color: color), const SizedBox(width: 4), Text(value, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700))]),
        Text(label, style: GoogleFonts.outfit(fontSize: 10, color: CyberMedicalTheme.textMuted)),
      ],
    );
  }

  Widget _buildScheduleListStream() {
    return StreamBuilder<List<ScheduleModel>>(
      stream: _firestoreService.streamSchedules(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final schedules = snapshot.data ?? [];
        if (schedules.isEmpty) return CyberCard(padding: const EdgeInsets.all(24), child: Center(child: Text('No Schedules Set', style: GoogleFonts.outfit(color: CyberMedicalTheme.textMuted))));

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: schedules.length,
          itemBuilder: (context, index) => _buildScheduleItemCard(schedules[index]),
        );
      },
    );
  }

  Widget _buildScheduleItemCard(ScheduleModel schedule) {
    final isLowStock = schedule.stockCount <= schedule.lowStockThreshold;
    final isDispensing = _pendingDispenses.contains(schedule.id);

    return CyberCard(
      borderColor: isLowStock ? CyberMedicalTheme.warningAlert.withValues(alpha: 0.4) : null,
      child: Column(
        children: [
          Row(
            children: [
              CompartmentSlotBadge(slot: schedule.compartmentSlot),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(schedule.medicineName, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700)),
                    Row(
                      children: [
                        Text(schedule.dosage, style: GoogleFonts.outfit(fontSize: 12, color: CyberMedicalTheme.textSecondary)),
                        const SizedBox(width: 8),
                        const Icon(Icons.alarm, size: 12, color: CyberMedicalTheme.secondaryAccent),
                        const SizedBox(width: 4),
                        Text(schedule.displayTime, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700, color: CyberMedicalTheme.primaryAccent)),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline, size: 20, color: CyberMedicalTheme.warningAlert.withValues(alpha: 0.7)),
                onPressed: () => _confirmDeleteSchedule(context, schedule),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: CyberMedicalTheme.dividerColor, height: 1),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.inventory_2, size: 14, color: isLowStock ? CyberMedicalTheme.warningAlert : CyberMedicalTheme.textMuted),
                  const SizedBox(width: 6),
                  Text(
                    'Stock: ${schedule.stockCount} left',
                    style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: isLowStock ? CyberMedicalTheme.warningAlert : CyberMedicalTheme.textPrimary),
                  ),
                  if (isLowStock) ...[
                    const SizedBox(width: 8),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: CyberMedicalTheme.warningAlert.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)), child: Text('LOW', style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w900, color: CyberMedicalTheme.warningAlert))),
                  ],
                ],
              ),
              isDispensing
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : TextButton(
                    onPressed: () => _handleTestDispense(schedule),
                    child: Text('TEST DROP', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w800, color: CyberMedicalTheme.primaryAccent)),
                  ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIntakeLogStream() {
    return StreamBuilder<List<IntakeLogModel>>(
      stream: _firestoreService.streamIntakeLogs(),
      builder: (context, snapshot) {
        final logs = snapshot.data ?? [];
        if (logs.isEmpty) return CyberCard(child: Center(child: Text('No Logs Yet', style: GoogleFonts.outfit(color: CyberMedicalTheme.textMuted))));

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: logs.length,
          itemBuilder: (context, index) {
            final log = logs[index];
            final color = log.isTaken ? CyberMedicalTheme.success : CyberMedicalTheme.warningAlert;
            return CyberCard(
              margin: const EdgeInsets.only(bottom: 8),
              borderColor: color.withValues(alpha: 0.2),
              child: Row(
                children: [
                  Icon(log.isTaken ? Icons.check_circle : Icons.error, color: color, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(log.medicineName, style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
                        Text('Slot ${log.compartmentSlot} • ${DateFormat('MMM d, hh:mm a').format(log.timestamp)}', style: GoogleFonts.outfit(fontSize: 11, color: CyberMedicalTheme.textMuted)),
                      ],
                    ),
                  ),
                  Text(log.statusText, style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: color)),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _handleTestDispense(ScheduleModel schedule) async {
    setState(() => _pendingDispenses.add(schedule.id));
    try {
      if (_hardwareService.isSimulationMode) {
        await _hardwareService.simulateDispenseCycle(schedule.compartmentSlot, schedule.medicineName);
        // Explicitly decrement for simulation if the hardware service doesn't do it via firestore
      }
      await _firestoreService.triggerTestDispense(
        compartmentSlot: schedule.compartmentSlot,
        medicineName: schedule.medicineName,
        scheduleId: schedule.id,
      );
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Dispense triggered for ${schedule.medicineName}')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: CyberMedicalTheme.warningAlert));
    } finally {
      if (mounted) setState(() => _pendingDispenses.remove(schedule.id));
    }
  }

  void _confirmDeleteSchedule(BuildContext context, ScheduleModel schedule) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Schedule?'),
        content: Text('Remove ${schedule.medicineName}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
          TextButton(onPressed: () {
            _firestoreService.deleteSchedule(schedule.id);
            Navigator.pop(ctx);
          }, child: const Text('DELETE', style: TextStyle(color: CyberMedicalTheme.warningAlert))),
        ],
      ),
    );
  }

  void _navigateToAddSchedule(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const AddScheduleScreen()));
  }
}
