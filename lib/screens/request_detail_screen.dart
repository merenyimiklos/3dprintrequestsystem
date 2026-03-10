import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/print_request.dart';
import '../models/enums.dart';
import '../providers/request_provider.dart';
import '../utils/app_constants.dart';
import '../utils/enum_helpers.dart';
import '../utils/date_formatter.dart';
import '../widgets/status_badge.dart';
import 'edit_request_screen.dart';

/// Shows all details of a single print request, with actions to
/// edit, delete, or change status.
class RequestDetailScreen extends StatelessWidget {
  final String requestId;

  const RequestDetailScreen({super.key, required this.requestId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RequestProvider>();

    // Guard: handle the brief moment between deletion and pop
    final index = provider.allRequests.indexWhere((r) => r.id == requestId);
    if (index == -1) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final request = provider.allRequests[index];

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final pColor = priorityColor(request.priority);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          request.projectName,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EditRequestScreen(requestId: requestId),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete',
            onPressed: () => _confirmDelete(context, provider, request),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status + Priority row
            Row(
              children: [
                StatusBadge(status: request.status),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: pColor.withAlpha(38),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: pColor.withAlpha(128)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.flag_rounded, size: 14, color: pColor),
                      const SizedBox(width: 4),
                      Text(
                        '${priorityLabel(request.priority)} Priority',
                        style: TextStyle(
                          color: pColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Requester
            _DetailCard(
              title: 'Requester',
              rows: [
                _DetailRow(
                  icon: Icons.person_outline,
                  label: 'Name',
                  value: request.requesterName,
                ),
                _DetailRow(
                  icon: Icons.group_outlined,
                  label: 'Class / Group',
                  value: request.classGroup.isEmpty ? '—' : request.classGroup,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Project
            _DetailCard(
              title: 'Project',
              rows: [
                _DetailRow(
                  icon: Icons.folder_outlined,
                  label: 'Name',
                  value: request.projectName,
                ),
                if (request.description.isNotEmpty)
                  _DetailRow(
                    icon: Icons.description_outlined,
                    label: 'Description',
                    value: request.description,
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Print settings
            _DetailCard(
              title: 'Print Settings',
              rows: [
                _DetailRow(
                  icon: Icons.print_outlined,
                  label: 'Printer',
                  value: printerLabel(request.printer),
                ),
                _DetailRow(
                  icon: Icons.science_outlined,
                  label: 'Material',
                  value: materialLabel(request.material),
                ),
                if (request.color.isNotEmpty)
                  _DetailRow(
                    icon: Icons.palette_outlined,
                    label: 'Color',
                    value: request.color,
                  ),
                _DetailRow(
                  icon: Icons.timer_outlined,
                  label: 'Est. Print Time',
                  value: '${request.estimatedPrintTime}h',
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Timestamps
            _DetailCard(
              title: 'Timeline',
              rows: [
                _DetailRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Created',
                  value: DateFormatter.formatDateTime(request.createdAt),
                ),
                _DetailRow(
                  icon: Icons.update_rounded,
                  label: 'Last Updated',
                  value: DateFormatter.formatDateTime(request.updatedAt),
                ),
              ],
            ),

            // Notes
            if (request.notes.isNotEmpty) ...[
              const SizedBox(height: 12),
              _DetailCard(
                title: 'Notes',
                rows: [
                  _DetailRow(
                    icon: Icons.note_outlined,
                    label: '',
                    value: request.notes,
                  ),
                ],
              ),
            ],

            const SizedBox(height: 28),

            // Action buttons
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () =>
                    _showStatusDialog(context, provider, request),
                icon: const Icon(Icons.swap_horiz_rounded),
                label: const Text('Change Status'),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            EditRequestScreen(requestId: requestId),
                      ),
                    ),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.error,
                      side: BorderSide(color: colorScheme.error),
                    ),
                    onPressed: () =>
                        _confirmDelete(context, provider, request),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Delete'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    RequestProvider provider,
    PrintRequest request,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Request'),
        content: Text(
          'Are you sure you want to delete "${request.projectName}"?\n\n'
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await provider.deleteRequest(request.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request deleted.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  Future<void> _showStatusDialog(
    BuildContext context,
    RequestProvider provider,
    PrintRequest request,
  ) async {
    final newStatus = await showDialog<PrintStatus>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Change Status'),
        children: PrintStatus.values.map((status) {
          final isCurrent = request.status == status;
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, status),
            child: Row(
              children: [
                StatusBadge(status: status),
                if (isCurrent) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.check_rounded, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'current',
                    style: TextStyle(
                      color:
                          Theme.of(ctx).colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ),
    );

    if (newStatus != null &&
        newStatus != request.status &&
        context.mounted) {
      await provider.updateStatus(request.id, newStatus);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Status updated to ${printStatusLabel(newStatus)}.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

// ─── Helper widgets ───────────────────────────────────────────────────────────

class _DetailCard extends StatelessWidget {
  final String title;
  final List<Widget> rows;

  const _DetailCard({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Divider(),
            ...rows,
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          if (label.isNotEmpty)
            SizedBox(
              width: 110,
              child: Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          Expanded(
            child: Text(value, style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
