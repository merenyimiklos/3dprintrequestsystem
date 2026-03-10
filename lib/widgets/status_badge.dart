import 'package:flutter/material.dart';
import '../models/enums.dart';
import '../utils/enum_helpers.dart';

/// A colored badge chip that displays the current [PrintStatus].
class StatusBadge extends StatelessWidget {
  final PrintStatus status;

  /// When [small] is true, uses smaller text and padding.
  final bool small;

  const StatusBadge({super.key, required this.status, this.small = false});

  @override
  Widget build(BuildContext context) {
    final color = printStatusColor(status);
    final label = printStatusLabel(status);
    final fontSize = small ? 10.0 : 12.0;
    final padding = small
        ? const EdgeInsets.symmetric(horizontal: 6, vertical: 2)
        : const EdgeInsets.symmetric(horizontal: 10, vertical: 4);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color.withAlpha(38),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(128)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
