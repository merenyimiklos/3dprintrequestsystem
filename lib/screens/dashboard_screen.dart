import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/enums.dart';
import '../providers/request_provider.dart';
import '../utils/app_constants.dart';
import '../utils/enum_helpers.dart';

/// Dashboard screen showing aggregated statistics:
/// counts by status, counts by printer, high-priority count.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RequestProvider>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics Dashboard')),
      body: provider.totalCount == 0
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.bar_chart_rounded,
                    size: 80,
                    color: colorScheme.onSurfaceVariant.withAlpha(100),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No data yet',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Statistics will appear once requests are added.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant.withAlpha(178),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Summary cards ──────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _BigStatCard(
                          label: 'Total Requests',
                          count: provider.totalCount,
                          color: colorScheme.primary,
                          icon: Icons.list_alt_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _BigStatCard(
                          label: 'High Priority',
                          count: provider.highPriorityCount,
                          color: Colors.red,
                          icon: Icons.priority_high_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── By status ──────────────────────────────────────────
                  Text(
                    'Requests by Status',
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _BreakdownCard(
                    children: PrintStatus.values.map((status) {
                      final count =
                          provider.countByStatus[status] ?? 0;
                      final color = printStatusColor(status);
                      final fraction = provider.totalCount > 0
                          ? count / provider.totalCount
                          : 0.0;
                      return _ProgressRow(
                        label: printStatusLabel(status),
                        count: count,
                        fraction: fraction,
                        color: color,
                        leadingDot: true,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // ── By printer ────────────────────────────────────────
                  Text(
                    'Requests by Printer',
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _BreakdownCard(
                    children: PrinterType.values.map((printer) {
                      final count =
                          provider.countByPrinter[printer] ?? 0;
                      final fraction = provider.totalCount > 0
                          ? count / provider.totalCount
                          : 0.0;
                      return _ProgressRow(
                        label: printerLabel(printer),
                        count: count,
                        fraction: fraction,
                        color: colorScheme.primary,
                        icon: Icons.print_outlined,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}

// ─── Helper widgets ───────────────────────────────────────────────────────────

class _BigStatCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;

  const _BigStatCard({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BreakdownCard extends StatelessWidget {
  final List<Widget> children;

  const _BreakdownCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(children: children),
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  final String label;
  final int count;
  final double fraction;
  final Color color;
  final bool leadingDot;
  final IconData? icon;

  const _ProgressRow({
    required this.label,
    required this.count,
    required this.fraction,
    required this.color,
    this.leadingDot = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (leadingDot)
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                )
              else if (icon != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Icon(icon, size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              Expanded(child: Text(label)),
              Text(
                '$count',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: fraction,
              backgroundColor: color.withAlpha(38),
              color: color,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
