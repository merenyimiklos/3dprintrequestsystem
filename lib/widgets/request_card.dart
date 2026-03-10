import 'package:flutter/material.dart';
import '../models/print_request.dart';
import '../utils/app_constants.dart';
import '../utils/enum_helpers.dart';
import '../utils/date_formatter.dart';
import 'status_badge.dart';

/// A card widget that displays a summary of a [PrintRequest].
/// Tapping the card triggers [onTap].
class RequestCard extends StatelessWidget {
  final PrintRequest request;
  final VoidCallback? onTap;

  const RequestCard({super.key, required this.request, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurfaceVariant;
    final pColor = priorityColor(request.priority);

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: AppConstants.smallPadding,
      ),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row: project name + status badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      request.projectName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  StatusBadge(status: request.status),
                ],
              ),
              const SizedBox(height: 8),

              // Requester & class
              _InfoRow(
                icon: Icons.person_outline,
                text: request.requesterName,
                onSurface: onSurface,
              ),
              if (request.classGroup.isNotEmpty)
                _InfoRow(
                  icon: Icons.group_outlined,
                  text: request.classGroup,
                  onSurface: onSurface,
                ),
              const SizedBox(height: 4),

              // Printer & material
              Row(
                children: [
                  _InfoChip(
                    icon: Icons.print_outlined,
                    text: printerLabel(request.printer),
                    onSurface: onSurface,
                  ),
                  const SizedBox(width: 12),
                  _InfoChip(
                    icon: Icons.science_outlined,
                    text: materialLabel(request.material),
                    onSurface: onSurface,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Priority & date footer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Priority pill
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: pColor.withAlpha(38),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.flag_rounded, size: 12, color: pColor),
                        const SizedBox(width: 3),
                        Text(
                          priorityLabel(request.priority),
                          style: TextStyle(
                            fontSize: 11,
                            color: pColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    DateFormatter.formatDate(request.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: onSurface,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color onSurface;

  const _InfoRow({
    required this.icon,
    required this.text,
    required this.onSurface,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Icon(icon, size: 14, color: onSurface),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: onSurface,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color onSurface;

  const _InfoChip({
    required this.icon,
    required this.text,
    required this.onSurface,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: onSurface),
        const SizedBox(width: 4),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: onSurface,
              ),
        ),
      ],
    );
  }
}
