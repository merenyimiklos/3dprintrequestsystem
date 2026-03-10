import 'package:hive_flutter/hive_flutter.dart';
import '../models/print_request.dart';

/// Service class for all Hive local persistence operations.
class HiveService {
  static const String _boxName = 'print_requests';

  /// Initializes Hive and registers adapters. Call once at app startup.
  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(PrintRequestAdapter());
    await Hive.openBox<PrintRequest>(_boxName);
  }

  static Box<PrintRequest> get box => Hive.box<PrintRequest>(_boxName);

  /// Saves a new or replaces an existing request (upsert by id).
  static Future<void> saveRequest(PrintRequest request) async {
    await box.put(request.id, request);
  }

  /// Deletes a request by its id.
  static Future<void> deleteRequest(String id) async {
    await box.delete(id);
  }

  /// Returns all stored requests as a list.
  static List<PrintRequest> getAllRequests() {
    return box.values.toList();
  }
}
