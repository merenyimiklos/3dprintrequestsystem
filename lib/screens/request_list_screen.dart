import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/request_provider.dart';
import '../utils/app_constants.dart';
import '../widgets/request_card.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/filter_bar_widget.dart';
import 'add_request_screen.dart';
import 'request_detail_screen.dart';

/// Shows the full list of print requests with search and filter support.
class RequestListScreen extends StatefulWidget {
  const RequestListScreen({super.key});

  @override
  State<RequestListScreen> createState() => _RequestListScreenState();
}

class _RequestListScreenState extends State<RequestListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RequestProvider>();
    final requests = provider.requests;
    final hasFilters = provider.filterStatus != null ||
        provider.filterPrinter != null ||
        provider.searchQuery.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Print Queue'),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: provider.filterStatus != null ||
                  provider.filterPrinter != null,
              child: const Icon(Icons.filter_list_rounded),
            ),
            tooltip: 'Filter',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                builder: (_) => const _FilterBottomSheet(),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.defaultPadding,
              AppConstants.defaultPadding,
              AppConstants.defaultPadding,
              AppConstants.smallPadding,
            ),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Search by project, name, or class…',
              leading: const Icon(Icons.search),
              trailing: [
                if (_searchController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      provider.setSearchQuery('');
                    },
                  ),
              ],
              onChanged: provider.setSearchQuery,
            ),
          ),

          // Active filter chips
          if (provider.filterStatus != null || provider.filterPrinter != null)
            const FilterBarWidget(),

          // Request list
          Expanded(
            child: requests.isEmpty
                ? EmptyStateWidget(
                    title: 'No Requests Found',
                    message: hasFilters
                        ? 'Try adjusting your search or filters.'
                        : 'No print requests yet.\nTap + to add one.',
                    icon: Icons.print_disabled_outlined,
                    actionLabel: hasFilters ? null : 'Add Request',
                    onAction: hasFilters
                        ? null
                        : () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const AddRequestScreen()),
                            ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 88),
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      final request = requests[index];
                      return RequestCard(
                        request: request,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                RequestDetailScreen(requestId: request.id),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddRequestScreen()),
        ),
        tooltip: 'New Request',
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Bottom sheet containing the [FilterBarWidget].
class _FilterBottomSheet extends StatelessWidget {
  const _FilterBottomSheet();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.35,
      maxChildSize: 0.85,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Text(
                    'Filter Requests',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      context.read<RequestProvider>().clearFilters();
                      Navigator.pop(context);
                    },
                    child: const Text('Clear all'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                controller: scrollController,
                children: const [FilterBarWidget()],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                8,
                16,
                MediaQuery.viewPaddingOf(context).bottom + 16,
              ),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Apply Filters'),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
