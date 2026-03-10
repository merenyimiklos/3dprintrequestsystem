import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/enums.dart';
import '../providers/request_provider.dart';
import '../utils/enum_helpers.dart';

/// A horizontally scrollable row of filter chips for status and printer.
/// Reads and writes filter state through [RequestProvider].
class FilterBarWidget extends StatelessWidget {
  const FilterBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RequestProvider>();
    final hasActiveFilters =
        provider.filterStatus != null || provider.filterPrinter != null;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          // Clear all button
          if (hasActiveFilters)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ActionChip(
                label: const Text('Clear all'),
                avatar: const Icon(Icons.close, size: 16),
                onPressed: provider.clearFilters,
              ),
            ),

          // Status filter chips
          Text(
            'Status:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 6),
          ...PrintStatus.values.map((status) {
            final isSelected = provider.filterStatus == status;
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: FilterChip(
                label: Text(printStatusLabel(status)),
                selected: isSelected,
                selectedColor:
                    printStatusColor(status).withAlpha(51),
                checkmarkColor: printStatusColor(status),
                onSelected: (selected) =>
                    provider.setFilterStatus(selected ? status : null),
              ),
            );
          }),

          const SizedBox(width: 12),

          // Printer filter chips
          Text(
            'Printer:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 6),
          ...PrinterType.values.map((printer) {
            final isSelected = provider.filterPrinter == printer;
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: FilterChip(
                label: Text(printerLabel(printer)),
                selected: isSelected,
                onSelected: (selected) =>
                    provider.setFilterPrinter(selected ? printer : null),
              ),
            );
          }),
        ],
      ),
    );
  }
}
