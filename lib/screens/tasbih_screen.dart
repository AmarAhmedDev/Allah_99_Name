import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vibration/vibration.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../constants/app_strings.dart';
import '../providers/language_provider.dart';

class TasbihScreen extends StatefulWidget {
  const TasbihScreen({super.key});

  @override
  State<TasbihScreen> createState() => _TasbihScreenState();
}

class _TasbihScreenState extends State<TasbihScreen>
    with SingleTickerProviderStateMixin {
  int _count = 0;
  int _target = 33;
  int _cycle = 0;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _incrementCount() {
    _pulseController.forward().then((_) => _pulseController.reverse());
    HapticFeedback.lightImpact();

    setState(() {
      _count++;
      if (_target != 0 && _count > _target) {
        _count = 1;
        _cycle++;
        Vibration.vibrate(duration: 100);
      }
    });
  }

  void _resetCount() {
    HapticFeedback.mediumImpact();
    setState(() {
      _count = 0;
      _cycle = 0;
    });
  }

  void _setTarget(int newTarget) {
    setState(() {
      _target = newTarget;
      _count = 0;
      _cycle = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = _target == 0 ? 0.0 : _count / _target;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.digitalTasbih(context.watch<LanguageProvider>().isAmharicAudio)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetCount,
            tooltip: AppStrings.reset(context.watch<LanguageProvider>().isAmharicAudio),
          ),
        ],
      ),
      body: Column(
        children: [
          // Target Selector
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingLG),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _TargetButton(
                  label: '33',
                  isSelected: _target == 33,
                  onTap: () => _setTarget(33),
                ),
                const SizedBox(width: AppSizes.paddingMD),
                _TargetButton(
                  label: '99',
                  isSelected: _target == 99,
                  onTap: () => _setTarget(99),
                ),
                const SizedBox(width: AppSizes.paddingMD),
                _TargetButton(
                  label: '∞',
                  isSelected: _target == 0,
                  onTap: () => _setTarget(0),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Main Counter Display
          ScaleTransition(
            scale: _pulseAnimation,
            child: GestureDetector(
              onTap: _incrementCount,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold.withOpacity(0.2),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                    if (isDark)
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                  ],
                  border: Border.all(
                    color: AppColors.gold.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Circular Progress Indicator
                    if (_target != 0)
                      CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 10,
                        backgroundColor: isDark
                            ? Colors.grey[800]
                            : Colors.grey[200],
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.gold,
                        ),
                      ),

                    // Counter Text
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$_count',
                          style: GoogleFonts.poppins(
                            fontSize: 80,
                            fontWeight: FontWeight.bold,
                            color: AppColors.gold,
                          ),
                        ),
                        if (_target != 0)
                          Text(
                            '${AppStrings.target(context.watch<LanguageProvider>().isAmharicAudio)}$_target',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey),
                          ),
                        if (_cycle > 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.gold.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${AppStrings.cycle(context.watch<LanguageProvider>().isAmharicAudio)}$_cycle',
                                style: const TextStyle(
                                  color: AppColors.gold,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          const Spacer(),

          // Instructions
          Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.padding2XL),
            child: Text(
              AppStrings.tapToCount(context.watch<LanguageProvider>().isAmharicAudio),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}

class _TargetButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TargetButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.gold : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.gold : Colors.grey),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
