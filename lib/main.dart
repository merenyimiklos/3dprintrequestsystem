import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/request_provider.dart';
import 'screens/home_screen.dart';
import 'services/hive_service.dart';
import 'utils/app_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  runApp(const PrintRequestApp());
}

class PrintRequestApp extends StatelessWidget {
  const PrintRequestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // Load requests immediately when the provider is created
      create: (_) => RequestProvider()..loadRequests(),
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: AppConstants.seedColor,
          useMaterial3: true,
          // Use filled + outlined input style consistently
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
            filled: true,
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
