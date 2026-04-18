import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../models/allah_name.dart';
import '../providers/names_provider.dart';
import '../providers/language_provider.dart';
import '../constants/app_strings.dart';

import 'package:shared_preferences/shared_preferences.dart';

class PuzzleGameScreen extends StatefulWidget {
  final int levelNum;
  final List<AllahName> names;

  const PuzzleGameScreen({
    super.key,
    required this.levelNum,
    required this.names,
  });

  @override
  State<PuzzleGameScreen> createState() => _PuzzleGameScreenState();
}

class _PuzzleGameScreenState extends State<PuzzleGameScreen> {
  // Ordered target names
  late List<AllahName> _targetNames;
  
  // Shuffled bank of names remaining
  late List<AllahName> _bankNames;
  
  // Tracks which slots have been correctly filled
  late List<bool> _slotsFilled;
  
  // Level complete flag
  bool _levelComplete = false;
  
  // Audio player for feedback sounds
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _initLevel();
  }

  void _initLevel() {
    _targetNames = widget.names;
    _bankNames = List.from(widget.names)..shuffle();
    _slotsFilled = List.filled(widget.names.length, false);
    _levelComplete = false;
    _loadLevelProgress();
  }

  Future<void> _loadLevelProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final filledString = prefs.getString('puzzle_level_${widget.levelNum}_progress');
    
    if (filledString != null && filledString.isNotEmpty) {
      final filledList = filledString.split(',');
      if (filledList.length == _targetNames.length) {
        setState(() {
          for (int i = 0; i < filledList.length; i++) {
            bool isFilled = filledList[i] == '1';
            _slotsFilled[i] = isFilled;
            if (isFilled) {
              _bankNames.removeWhere((n) => n.id == _targetNames[i].id);
            }
          }
          if (_bankNames.isEmpty) {
            _levelComplete = true;
          }
        });
      }
    }
  }

  Future<void> _saveLevelProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final filledString = _slotsFilled.map((e) => e ? '1' : '0').join(',');
    await prefs.setString('puzzle_level_${widget.levelNum}_progress', filledString);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _unlockNextLevel() async {
    final prefs = await SharedPreferences.getInstance();
    final currentUnlocked = prefs.getInt('puzzle_unlocked_level') ?? 1;
    final nextLevel = widget.levelNum + 1;
    if (nextLevel > currentUnlocked) {
      await prefs.setInt('puzzle_unlocked_level', nextLevel);
    }
  }

  void _onAccept(AllahName draggedName, int targetIndex) {
    if (draggedName.id == _targetNames[targetIndex].id) {
      // Correct Match
      setState(() {
        _slotsFilled[targetIndex] = true;
        _bankNames.removeWhere((n) => n.id == draggedName.id);
      });
      _saveLevelProgress(); // Save progress whenever a match is made
      
      // Check if level is complete
      if (_bankNames.isEmpty) {
        _unlockNextLevel();
        setState(() {
          _levelComplete = true;
        });
      }
    }
  }

  void _resetLevel() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('puzzle_level_${widget.levelNum}_progress');
    
    setState(() {
      _initLevel();
    });
  }

  void _goToNextLevel() {
    final namesProvider = context.read<NamesProvider>();
    final allNames = namesProvider.allNames;
    const itemsPerLevel = 9;
    final nextLevelNum = widget.levelNum + 1;
    final startIdx = (nextLevelNum - 1) * itemsPerLevel;
    final endIdx = (startIdx + itemsPerLevel > allNames.length)
        ? allNames.length
        : startIdx + itemsPerLevel;

    if (startIdx >= allNames.length) {
      // No more levels - show completion message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Text('🎉', style: TextStyle(fontSize: 20)),
              const SizedBox(width: AppSizes.paddingSM),
              Text(AppStrings.completedAllLevels(context.read<LanguageProvider>().isAmharicAudio), style: GoogleFonts.poppins()),
            ],
          ),
          backgroundColor: AppColors.gold,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final nextNames = allNames.sublist(startIdx, endIdx);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PuzzleGameScreen(
          levelNum: nextLevelNum,
          names: nextNames,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${AppStrings.level(context.watch<LanguageProvider>().isAmharicAudio)}${widget.levelNum}',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        actions: [
          if (!_levelComplete)
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: AppStrings.reset(context.watch<LanguageProvider>().isAmharicAudio),
              onPressed: _resetLevel,
            ),
        ],
      ),
      body: Column(
        children: [
          // Instruction / Status
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMD, vertical: AppSizes.paddingSM),
            child: Text(
              _levelComplete 
                  ? AppStrings.allMemorized(context.watch<LanguageProvider>().isAmharicAudio, _targetNames.length)
                  : AppStrings.dragInstructions(context.watch<LanguageProvider>().isAmharicAudio),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontStyle: _levelComplete ? FontStyle.normal : FontStyle.italic,
                fontWeight: _levelComplete ? FontWeight.w600 : FontWeight.normal,
                color: _levelComplete ? AppColors.gold : null,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          // Target Slots - 3x3 Grid (TOP) - Always visible, keeps correct answers
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMD),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: AppSizes.paddingSM,
                  mainAxisSpacing: AppSizes.paddingSM,
                  childAspectRatio: 1.5,
                ),
                itemCount: _targetNames.length,
                itemBuilder: (context, index) {
                  return _buildTargetSlot(index);
                },
              ),
            ),
          ),
          
          // Divider
          const Divider(color: AppColors.gold, thickness: 1, endIndent: 30, indent: 30),
          
          // Bottom Section - Bank or Completion Actions
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMD),
              child: _levelComplete
                  ? _buildCompletionActions()
                  : _bankNames.isEmpty
                      ? const SizedBox.shrink()
                      : GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: AppSizes.paddingSM,
                            mainAxisSpacing: AppSizes.paddingSM,
                            childAspectRatio: 1.5,
                          ),
                          itemCount: _bankNames.length,
                          itemBuilder: (context, index) {
                            return _buildDraggableCard(_bankNames[index]);
                          },
                        ),
            ),
          ),
          const SizedBox(height: AppSizes.paddingSM),
        ],
      ),
    );
  }

  Widget _buildCompletionActions() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Success emoji
            const Text('🏆', style: TextStyle(fontSize: 48)),
            const SizedBox(height: AppSizes.paddingMD),

            // Score text
            Text(
              AppStrings.levelComplete(context.watch<LanguageProvider>().isAmharicAudio, widget.levelNum),
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.gold,
              ),
            ),
            const SizedBox(height: AppSizes.paddingXS),
            Text(
              AppStrings.orderPreserved(context.watch<LanguageProvider>().isAmharicAudio),
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Theme.of(context).hintColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.paddingLG),

            // Action Buttons
            Row(
              children: [
                // Reset / Play Again
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _resetLevel,
                    icon: const Icon(Icons.refresh_rounded, size: 20),
                    label: Text(AppStrings.playAgain(context.watch<LanguageProvider>().isAmharicAudio), style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.gold, width: 2),
                      foregroundColor: AppColors.gold,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.paddingMD),
                // Next Level
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _goToNextLevel,
                    icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                    label: Text(AppStrings.nextLevel(context.watch<LanguageProvider>().isAmharicAudio), style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: AppColors.gold,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingSM),

            // Back to Levels
            TextButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.grid_view_rounded, size: 18),
              label: Text(AppStrings.backToLevels(context.watch<LanguageProvider>().isAmharicAudio), style: GoogleFonts.poppins(fontSize: 13)),
              style: TextButton.styleFrom(foregroundColor: Theme.of(context).hintColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetSlot(int index) {
    final targetName = _targetNames[index];
    final isFilled = _slotsFilled[index];

    return DragTarget<AllahName>(
      onWillAcceptWithDetails: (details) => !isFilled && !_levelComplete,
      onAcceptWithDetails: (details) {
        final draggedName = details.data;
        if (draggedName.id == targetName.id) {
          _onAccept(draggedName, index);
        } else {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: AppSizes.paddingSM),
                  Text(AppStrings.notQuiteRight(context.read<LanguageProvider>().isAmharicAudio), style: GoogleFonts.poppins()),
                ],
              ),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 1),
            ),
          );
        }
      },
      builder: (context, candidateData, rejectedData) {
        final isHovered = candidateData.isNotEmpty;

        return Container(
          decoration: BoxDecoration(
            color: isFilled 
                ? AppColors.gold.withValues(alpha: 0.15) 
                : (isHovered ? AppColors.gold.withValues(alpha: 0.1) : Theme.of(context).cardColor),
            borderRadius: BorderRadius.circular(AppSizes.radiusSM),
            border: Border.all(
              color: isFilled ? AppColors.gold : (isHovered ? AppColors.gold : AppColors.borderLight),
              width: isHovered || isFilled ? 2 : 1,
            ),
          ),
          child: Stack(
            children: [
              // Number badge top-left
              Positioned(
                top: 4,
                left: 4,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: isFilled ? AppColors.gold : AppColors.gold.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${targetName.id}',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isFilled ? Colors.white : AppColors.gold,
                      ),
                    ),
                  ),
                ),
              ),
              // Check icon top-right
              if (isFilled)
                const Positioned(
                  top: 4,
                  right: 4,
                  child: Icon(Icons.check_circle, color: Colors.green, size: 18),
                ),
              // Center content
              Center(
                child: isFilled
                    ? Text(
                        targetName.arabic,
                        style: GoogleFonts.amiri(
                          fontSize: 22,
                          color: AppColors.gold,
                          fontWeight: FontWeight.bold,
                        ),
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.center,
                      )
                    : Text(
                        index == 0 ? targetName.transliteration : '???',
                        style: GoogleFonts.poppins(
                          color: Theme.of(context).hintColor.withValues(alpha: 0.5),
                          fontStyle: FontStyle.italic,
                          fontSize: index == 0 ? 16 : 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDraggableCard(AllahName name) {
    return Draggable<AllahName>(
      data: name,
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.gold,
            borderRadius: BorderRadius.circular(AppSizes.radiusSM),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Text(
            name.arabic,
            style: GoogleFonts.amiri(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      childWhenDragging: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppSizes.radiusSM),
          border: Border.all(color: AppColors.borderLight),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppSizes.radiusSM),
          border: Border.all(
            color: AppColors.gold.withValues(alpha: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          name.arabic,
          style: GoogleFonts.amiri(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
