import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/names_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/audio_provider.dart';
import 'providers/language_provider.dart';
import 'utils/app_theme.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Pre-cache for faster startup - don't block on it
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Hide the navigation bar (back, home, recent) but keep the top status bar
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual, 
    overlays: [SystemUiOverlay.top],
  );
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.black12,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarContrastEnforced: false,
      systemStatusBarContrastEnforced: false,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider(), lazy: false),
        ChangeNotifierProvider(create: (_) => NamesProvider()),
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
