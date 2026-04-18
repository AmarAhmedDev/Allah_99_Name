import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Hide the navigation bar (back, home, recent)
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual, 
      overlays: [SystemUiOverlay.top],
    );
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.black26, 
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarContrastEnforced: false,
        systemStatusBarContrastEnforced: false,
      ),
    );

    // Fast animation! Total 1.2 seconds before entering the app
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // "Movable background" effect: Slow, professional zooming (Ken Burns effect)
    // Starting slightly smaller to give a nice visual push, or 1.0 -> 1.15
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutSine,
      ),
    );

    _controller.forward();

    // Navigate immediately after the fast animation
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const HomeScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Match the dark starry background edges
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Center(
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Image.asset(
                  'assets/icon/splash_background.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
