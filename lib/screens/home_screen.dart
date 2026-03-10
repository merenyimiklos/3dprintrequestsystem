import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/request_provider.dart';
import '../utils/app_constants.dart';
import '../widgets/stats_card.dart';
import 'request_list_screen.dart';
import 'add_request_screen.dart';
import 'dashboard_screen.dart';

/// The main landing screen with statistics overview and quick-action buttons.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RequestProvider>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded),
            tooltip: 'Statistics Dashboard',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DashboardScreen()),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppConstants.appSubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 28),

            // ── Statistics overview ──────────────────────────────────────
            Text(
              'Overview',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.4,
              children: [
                StatsCard(
                  label: 'Total Requests',
                  count: provider.totalCount,
                  color: colorScheme.primary,
                  icon: Icons.list_alt_rounded,
                ),
                StatsCard(
                  label: 'Pending',
                  count: provider.pendingCount,
                  color: Colors.orange,
                  icon: Icons.hourglass_empty_rounded,
                ),
                StatsCard(
                  label: 'Printing',
                  count: provider.printingCount,
                  color: Colors.purple,
                  icon: Icons.print_rounded,
                ),
                StatsCard(
                  label: 'Done',
                  count: provider.doneCount,
                  color: Colors.green,
                  icon: Icons.check_circle_outline_rounded,
                ),
              ],
            ),
            const SizedBox(height: 32),

            // ── Quick actions ────────────────────────────────────────────
            Text(
              'Quick Actions',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const RequestListScreen()),
                    ),
                    icon: const Icon(Icons.list_alt_rounded),
                    label: const Text('View Queue'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AddRequestScreen()),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('New Request'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DashboardScreen()),
                ),
                icon: const Icon(Icons.bar_chart_rounded),
                label: const Text('Statistics Dashboard'),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddRequestScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('New Request'),
      ),
    );
  }
}
