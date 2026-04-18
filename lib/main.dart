import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/names_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/audio_provider.dart';
import 'providers/language_provider.dart';
import 'utils/app_theme.dart';
import 'screens/splash_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set orientation and UI mode immediately (non-blocking, fast)
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarContrastEnforced: false,
      systemStatusBarContrastEnforced: false,
    ),
  );

  // Launch the app IMMEDIATELY - don't block on notifications
  runApp(const MyApp());

  // Initialize notifications in the background AFTER app is visible
  _initNotificationsInBackground();
}

/// Non-blocking notification setup - runs after the first frame is painted
void _initNotificationsInBackground() {
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    try {
      final notificationService = NotificationService();
      await notificationService.initialize();
      await notificationService.requestPermissions();
      await notificationService.scheduleRandomDailyReminders();
    } catch (e) {
      debugPrint('Notification init error (non-critical): $e');
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider(), lazy: false),
        ChangeNotifierProvider(create: (_) => NamesProvider(), lazy: false),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProxyProvider<LanguageProvider, AudioProvider>(
          create: (_) => AudioProvider(),
          update: (_, languageProvider, audioProvider) =>
              audioProvider!..updateLanguage(languageProvider.isAmharicAudio),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Asma\'ul Husna',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
