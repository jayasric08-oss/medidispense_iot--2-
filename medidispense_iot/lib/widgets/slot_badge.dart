import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/theme.dart';

/// Compartment Slot (1 to 4) Visual Indicator Badge
class CompartmentSlotBadge extends StatelessWidget {
  final int slot;
  final bool isCompact;

  const CompartmentSlotBadge({
    Key? key,
    required this.slot,
    this.isCompact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Dynamic color gradient per slot for visual clarity
    final slotColors = [
      CyberMedicalTheme.primaryAccent,
      CyberMedicalTheme.secondaryAccent,
      const Color(0xFFA855F7), // Cyber Purple
      const Color(0xFFF59E0B), // Cyber Amber
    ];

    final color = slotColors[(slot - 1) % slotColors.length];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 12,
        vertical: isCompact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 6,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.grid_view_rounded,
            size: isCompact ? 12 : 15,
            color: color,
          ),
          SizedBox(width: isCompact ? 4 : 6),
          Text(
            'SLOT $slot',
            style: GoogleFonts.outfit(
              color: color,
              fontSize: isCompact ? 11 : 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}
