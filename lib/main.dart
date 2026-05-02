import 'package:cliniko/core/routing/app_router.dart';
import 'package:cliniko/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: ClinikoApp(),
    ),
  );
}

class ClinikoApp extends StatelessWidget {
  const ClinikoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Cliniko',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      routerConfig: AppRouter.router,
    );
  }
}
