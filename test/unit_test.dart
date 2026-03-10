import 'package:flutter_test/flutter_test.dart';
import 'package:print_request_system/models/enums.dart';
import 'package:print_request_system/models/print_request.dart';
import 'package:print_request_system/utils/enum_helpers.dart';
import 'package:print_request_system/utils/date_formatter.dart';

void main() {
  // ── Enum label tests ──────────────────────────────────────────────────────

  group('printStatusLabel', () {
    test('returns correct label for each status', () {
      expect(printStatusLabel(PrintStatus.pending), 'Pending');
      expect(printStatusLabel(PrintStatus.approved), 'Approved');
      expect(printStatusLabel(PrintStatus.printing), 'Printing');
      expect(printStatusLabel(PrintStatus.done), 'Done');
      expect(printStatusLabel(PrintStatus.rejected), 'Rejected');
    });
  });

  group('priorityLabel', () {
    test('returns correct label for each priority', () {
      expect(priorityLabel(Priority.low), 'Low');
      expect(priorityLabel(Priority.normal), 'Normal');
      expect(priorityLabel(Priority.high), 'High');
    });
  });

  group('printerLabel', () {
    test('returns correct label for each printer', () {
      expect(printerLabel(PrinterType.bambuLabP1S), 'Bambu Lab P1S');
      expect(printerLabel(PrinterType.ender3), 'Ender 3');
      expect(printerLabel(PrinterType.flashforgeAdventurer),
          'Flashforge Adventurer');
      expect(printerLabel(PrinterType.other), 'Other');
    });
  });

  group('materialLabel', () {
    test('returns correct label for each material', () {
      expect(materialLabel(MaterialType.pla), 'PLA');
      expect(materialLabel(MaterialType.petg), 'PETG');
      expect(materialLabel(MaterialType.tpu), 'TPU');
      expect(materialLabel(MaterialType.abs), 'ABS');
      expect(materialLabel(MaterialType.other), 'Other');
    });
  });

  // ── DateFormatter tests ───────────────────────────────────────────────────

  group('DateFormatter', () {
    final testDate = DateTime(2026, 3, 10, 14, 30);

    test('formatDate returns expected format', () {
      expect(DateFormatter.formatDate(testDate), 'Mar 10, 2026');
    });

    test('formatDateTime includes time', () {
      expect(DateFormatter.formatDateTime(testDate), 'Mar 10, 2026 · 14:30');
    });

    test('timeAgo returns "Just now" for very recent dates', () {
      final recent = DateTime.now().subtract(const Duration(seconds: 30));
      expect(DateFormatter.timeAgo(recent), 'Just now');
    });

    test('timeAgo returns minutes for recent dates', () {
      final fiveMinutesAgo =
          DateTime.now().subtract(const Duration(minutes: 5));
      expect(DateFormatter.timeAgo(fiveMinutesAgo), '5 minutes ago');
    });
  });

  // ── PrintRequest model tests ──────────────────────────────────────────────

  group('PrintRequest.copyWith', () {
    final original = PrintRequest(
      id: 'test-id',
      requesterName: 'Alice',
      classGroup: '10A',
      projectName: 'Rocket Model',
      printer: PrinterType.ender3,
      material: MaterialType.pla,
      estimatedPrintTime: 2.5,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

    test('copyWith updates only specified fields', () {
      final copy = original.copyWith(
        requesterName: 'Bob',
        status: PrintStatus.approved,
      );

      expect(copy.id, 'test-id');
      expect(copy.requesterName, 'Bob');
      expect(copy.projectName, 'Rocket Model');
      expect(copy.status, PrintStatus.approved);
      // Original unchanged
      expect(original.requesterName, 'Alice');
      expect(original.status, PrintStatus.pending);
    });

    test('default status is pending', () {
      expect(original.status, PrintStatus.pending);
    });

    test('default priority is normal', () {
      expect(original.priority, Priority.normal);
    });
  });
}
