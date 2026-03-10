import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/print_request.dart';
import '../models/enums.dart';
import '../services/hive_service.dart';

/// Provider that manages all print requests and filter/search state.
/// Uses ChangeNotifier so widgets can rebuild when data changes.
class RequestProvider extends ChangeNotifier {
  List<PrintRequest> _requests = [];
  String _searchQuery = '';
  PrintStatus? _filterStatus;
  PrinterType? _filterPrinter;

  final _uuid = const Uuid();

  // ─── Getters ──────────────────────────────────────────────────────────────

  /// Returns the filtered and searched list for display.
  List<PrintRequest> get requests => _filteredRequests;

  /// Returns the complete unfiltered list (used for lookups by id).
  List<PrintRequest> get allRequests => List.unmodifiable(_requests);

  String get searchQuery => _searchQuery;
  PrintStatus? get filterStatus => _filterStatus;
  PrinterType? get filterPrinter => _filterPrinter;

  // ─── Load ─────────────────────────────────────────────────────────────────

  /// Loads all requests from Hive, sorted newest first.
  void loadRequests() {
    _requests = HiveService.getAllRequests();
    _requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    notifyListeners();
  }

  // ─── Filtering ────────────────────────────────────────────────────────────

  List<PrintRequest> get _filteredRequests {
    List<PrintRequest> result = List.from(_requests);

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((r) {
        return r.projectName.toLowerCase().contains(query) ||
            r.requesterName.toLowerCase().contains(query) ||
            r.classGroup.toLowerCase().contains(query);
      }).toList();
    }

    if (_filterStatus != null) {
      result = result.where((r) => r.status == _filterStatus).toList();
    }

    if (_filterPrinter != null) {
      result = result.where((r) => r.printer == _filterPrinter).toList();
    }

    return result;
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilterStatus(PrintStatus? status) {
    _filterStatus = status;
    notifyListeners();
  }

  void setFilterPrinter(PrinterType? printer) {
    _filterPrinter = printer;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _filterStatus = null;
    _filterPrinter = null;
    notifyListeners();
  }

  // ─── CRUD Operations ──────────────────────────────────────────────────────

  Future<void> addRequest(PrintRequest request) async {
    await HiveService.saveRequest(request);
    loadRequests();
  }

  Future<void> updateRequest(PrintRequest request) async {
    await HiveService.saveRequest(request);
    loadRequests();
  }

  Future<void> deleteRequest(String id) async {
    await HiveService.deleteRequest(id);
    loadRequests();
  }

  /// Convenience method to change only the status of a request.
  Future<void> updateStatus(String id, PrintStatus newStatus) async {
    final index = _requests.indexWhere((r) => r.id == id);
    if (index == -1) return;
    final updated = _requests[index].copyWith(
      status: newStatus,
      updatedAt: DateTime.now(),
    );
    await HiveService.saveRequest(updated);
    loadRequests();
  }

  // ─── Statistics ───────────────────────────────────────────────────────────

  int get totalCount => _requests.length;

  int get pendingCount =>
      _requests.where((r) => r.status == PrintStatus.pending).length;

  int get approvedCount =>
      _requests.where((r) => r.status == PrintStatus.approved).length;

  int get printingCount =>
      _requests.where((r) => r.status == PrintStatus.printing).length;

  int get doneCount =>
      _requests.where((r) => r.status == PrintStatus.done).length;

  int get rejectedCount =>
      _requests.where((r) => r.status == PrintStatus.rejected).length;

  int get highPriorityCount =>
      _requests.where((r) => r.priority == Priority.high).length;

  /// Returns a map of [PrinterType] → request count.
  Map<PrinterType, int> get countByPrinter {
    return {
      for (final printer in PrinterType.values)
        printer: _requests.where((r) => r.printer == printer).length,
    };
  }

  /// Returns a map of [PrintStatus] → request count.
  Map<PrintStatus, int> get countByStatus {
    return {
      for (final status in PrintStatus.values)
        status: _requests.where((r) => r.status == status).length,
    };
  }

  /// Generates a unique id for a new request.
  String generateId() => _uuid.v4();
}
