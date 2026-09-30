import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/theme.dart';

/// Visual status indicator pill for ESP32 hardware online/offline status
class HardwareStatusPill extends StatefulWidget {
  final bool isOnline;
  final String label;

  const HardwareStatusPill({
    Key? key,
    required this.isOnline,
    this.label = 'ESP32 DISPENSER',
  }) : super(key: key);

  @override
  State<HardwareStatusPill> createState() => _HardwareStatusPillState();
}

class _HardwareStatusPillState extends State<HardwareStatusPill>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = widget.isOnline
        ? CyberMedicalTheme.success
        : CyberMedicalTheme.warningAlert;
    final statusText = widget.isOnline ? 'ONLINE' : 'OFFLINE';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.4),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.2),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated Pulse Dot
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: statusColor.withValues(
                    alpha: widget.isOnline ? _pulseAnimation.value : 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: statusColor,
                      blurRadius: widget.isOnline ? 6 * _pulseAnimation.value : 2,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          Text(
            statusText,
            style: GoogleFonts.outfit(
              color: statusColor,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
