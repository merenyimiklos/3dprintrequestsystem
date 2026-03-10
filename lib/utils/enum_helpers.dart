import 'package:flutter/material.dart';
import '../models/enums.dart';

// ─── Status ────────────────────────────────────────────────────────────────

String printStatusLabel(PrintStatus status) {
  switch (status) {
    case PrintStatus.pending:
      return 'Pending';
    case PrintStatus.approved:
      return 'Approved';
    case PrintStatus.printing:
      return 'Printing';
    case PrintStatus.done:
      return 'Done';
    case PrintStatus.rejected:
      return 'Rejected';
  }
}

Color printStatusColor(PrintStatus status) {
  switch (status) {
    case PrintStatus.pending:
      return Colors.orange;
    case PrintStatus.approved:
      return Colors.blue;
    case PrintStatus.printing:
      return Colors.purple;
    case PrintStatus.done:
      return Colors.green;
    case PrintStatus.rejected:
      return Colors.red;
  }
}

// ─── Priority ──────────────────────────────────────────────────────────────

String priorityLabel(Priority priority) {
  switch (priority) {
    case Priority.low:
      return 'Low';
    case Priority.normal:
      return 'Normal';
    case Priority.high:
      return 'High';
  }
}

Color priorityColor(Priority priority) {
  switch (priority) {
    case Priority.low:
      return Colors.grey;
    case Priority.normal:
      return Colors.blue;
    case Priority.high:
      return Colors.red;
  }
}

// ─── Printer ───────────────────────────────────────────────────────────────

String printerLabel(PrinterType printer) {
  switch (printer) {
    case PrinterType.bambuLabP1S:
      return 'Bambu Lab P1S';
    case PrinterType.ender3:
      return 'Ender 3';
    case PrinterType.flashforgeAdventurer:
      return 'Flashforge Adventurer';
    case PrinterType.other:
      return 'Other';
  }
}

// ─── Material ──────────────────────────────────────────────────────────────

String materialLabel(MaterialType material) {
  switch (material) {
    case MaterialType.pla:
      return 'PLA';
    case MaterialType.petg:
      return 'PETG';
    case MaterialType.tpu:
      return 'TPU';
    case MaterialType.abs:
      return 'ABS';
    case MaterialType.other:
      return 'Other';
  }
}
