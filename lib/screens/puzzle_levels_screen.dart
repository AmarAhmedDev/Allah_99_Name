import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../providers/names_provider.dart';
import '../providers/language_provider.dart';
import '../constants/app_strings.dart';
import 'puzzle_game_screen.dart';

import 'package:shared_preferences/shared_preferences.dart';

class PuzzleLevelsScreen extends StatefulWidget {
  const PuzzleLevelsScreen({super.key});

  @override
  State<PuzzleLevelsScreen> createState() => _PuzzleLevelsScreenState();
}

class _PuzzleLevelsScreenState extends State<PuzzleLevelsScreen> {
  int _unlockedLevel = 1;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _unlockedLevel = prefs.getInt('puzzle_unlocked_level') ?? 1;
      _isLoading = false;
    });
  }

  Future<void> _refreshProgress() async {
    await _loadProgress();
  }

  @override
  Widget build(BuildContext context) {
    final namesProvider = context.watch<NamesProvider>();
    final allNames = namesProvider.allNames;
    
    // Group into levels of 9 names each (11 levels total: 11 * 9 = 99)
    final int itemsPerLevel = 9;
    final int totalLevels = (allNames.length / itemsPerLevel).ceil();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.puzzleLevels(context.watch<LanguageProvider>().isAmharicAudio),
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: _isLoading || allNames.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(AppSizes.paddingLG),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppSizes.paddingLG,
                mainAxisSpacing: AppSizes.paddingLG,
                childAspectRatio: 1.1,
              ),
              itemCount: totalLevels,
              itemBuilder: (context, index) {
                final startIdx = index * itemsPerLevel;
                final endIdx = (startIdx + itemsPerLevel > allNames.length)
                    ? allNames.length
                    : startIdx + itemsPerLevel;
                
                final levelNum = index + 1;
                final isLocked = levelNum > _unlockedLevel;
                    
                return _LevelCard(
                  levelNum: levelNum,
                  startName: startIdx + 1,
                  endName: endIdx,
                  isLocked: isLocked,
                  onTap: () async {
                    if (isLocked) {
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.lock, color: Colors.white),
                              const SizedBox(width: AppSizes.paddingSM),
                              Text(
                                AppStrings.completeToUnlock(context.read<LanguageProvider>().isAmharicAudio, _unlockedLevel),
                                style: GoogleFonts.poppins(),
                              ),
                            ],
                          ),
                          backgroundColor: Colors.redAccent,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }
                    
                    final levelNames = allNames.sublist(startIdx, endIdx);
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PuzzleGameScreen(
                          levelNum: levelNum,
                          names: levelNames,
                        ),
                      ),
                    );
                    // Refresh in case they beat a level
                    _refreshProgress();
                  },
                );
              },
            ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final int levelNum;
  final int startName;
  final int endName;
  final bool isLocked;
  final VoidCallback onTap;

  const _LevelCard({
    required this.levelNum,
    required this.startName,
    required this.endName,
    this.isLocked = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusLG),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor.withValues(alpha: isLocked ? 0.5 : 1.0),
          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
          border: Border.all(
            color: isLocked 
                ? (isDark ? AppColors.borderDark : AppColors.borderLight).withValues(alpha: 0.5)
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
          ),
          boxShadow: isLocked ? [] : [
            BoxShadow(
              color: AppColors.gold.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingMD),
              decoration: BoxDecoration(
                color: isLocked 
                    ? Colors.grey.withValues(alpha: 0.2) 
                    : AppColors.gold.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: isLocked 
                  ? const Icon(Icons.lock, color: Colors.grey, size: 28)
                  : Text(
                      '$levelNum',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.gold,
                      ),
                    ),
            ),
            const SizedBox(height: AppSizes.paddingMD),
            Text(
              '${AppStrings.level(context.watch<LanguageProvider>().isAmharicAudio)}$levelNum',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isLocked ? Colors.grey : null,
              ),
            ),
            const SizedBox(height: AppSizes.paddingXS),
            Text(
              '${AppStrings.names(context.watch<LanguageProvider>().isAmharicAudio)}$startName - $endName',
              style: theme.textTheme.bodySmall?.copyWith(
                    color: isLocked ? Colors.grey : AppColors.gold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
