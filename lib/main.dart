import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'services/hive_service.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';
import 'providers/meal_provider.dart';
import 'screens/home_screen.dart';

/// Global navigator key — allows notification taps to push screens from outside widget tree
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await HiveService.init();

  // Initialize Notifications (pass navigatorKey so taps can open screens)
  await NotificationService.init(navigatorKey);

  // Initialize Arabic locale for dates
  await initializeDateFormatting('ar', null);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MealProvider()),
      ],
      child: const SihatiApp(),
    ),
  );
}

class SihatiApp extends StatelessWidget {
  const SihatiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'سحتي',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      navigatorKey: navigatorKey,
      home: const HomeScreen(),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
    );
  }
}
