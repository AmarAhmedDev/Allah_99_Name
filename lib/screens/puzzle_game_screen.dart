import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import '../constants/app_constants.dart';
import '../models/allah_name.dart';

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
  
  // Audio player for feedback sounds
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _targetNames = widget.names;
    _bankNames = List.from(widget.names)..shuffle();
    _slotsFilled = List.filled(widget.names.length, false);
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
      // Play success feedback or just show visual
      if (_bankNames.isEmpty) {
        _unlockNextLevel();
        _showLevelCompleteDialog();
      }
    }
  }

  void _showLevelCompleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        ),
        title: Center(
          child: Column(
            children: [
              const Text('🎉', style: TextStyle(fontSize: 48)),
              const SizedBox(height: AppSizes.paddingMD),
              Text(
                'Mashallah!',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: AppColors.gold,
                ),
              ),
            ],
          ),
        ),
        content: Text(
          'You have successfully memorized and ordered names from Level ${widget.levelNum}!',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(),
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // close dialog
                Navigator.pop(context); // close screen
              },
              child: const Text('Back to Levels'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Level ${widget.levelNum}',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          // Instruction
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingMD),
            child: Text(
              'Drag the Arabic names into the correct sequential order.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          // Target Slots (Scrollable List)
          Expanded(
            flex: 6,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingLG),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(AppSizes.radiusLG),
                border: Border.all(
                  color: AppColors.borderLight,
                ),
              ),
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSizes.paddingMD),
                itemCount: _targetNames.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSizes.paddingSM),
                itemBuilder: (context, index) {
                  return _buildTargetSlot(index);
                },
              ),
            ),
          ),
          
          const SizedBox(height: AppSizes.paddingMD),
          
          // Divider
          const Divider(color: AppColors.gold, thickness: 1, endIndent: 30, indent: 30),
          
          // Bank of Available Names (Grid)
          Expanded(
            flex: 4,
            child: Container(
              padding: const EdgeInsets.all(AppSizes.paddingMD),
              child: _bankNames.isEmpty 
              ? Center(
                  child: Text(
                    'Level Complete!',
                    style: GoogleFonts.poppins(
                      fontSize: 20, 
                      fontWeight: FontWeight.bold,
                      color: AppColors.gold,
                    ),
                  ),
                )
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
        ],
      ),
    );
  }

  Widget _buildTargetSlot(int index) {
    final targetName = _targetNames[index];
    final isFilled = _slotsFilled[index];

    return DragTarget<AllahName>(
      onWillAcceptWithDetails: (details) => !isFilled,
      onAcceptWithDetails: (details) {
        final draggedName = details.data;
        if (draggedName.id == targetName.id) {
          _onAccept(draggedName, index);
        } else {
          // Show error
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: AppSizes.paddingSM),
                  Text(
                    'Not correct! Try another slot.',
                    style: GoogleFonts.poppins(),
                  ),
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
          height: 70,
          decoration: BoxDecoration(
            color: isFilled 
                ? AppColors.gold.withOpacity(0.15) 
                : (isHovered ? Theme.of(context).primaryColor.withOpacity(0.2) : Theme.of(context).cardColor),
            borderRadius: BorderRadius.circular(AppSizes.radiusMD),
            border: Border.all(
              color: isFilled ? AppColors.gold : (isHovered ? AppColors.gold : AppColors.borderLight),
              width: isHovered || isFilled ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // Number Icon
              Container(
                width: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: isFilled ? AppColors.gold.withOpacity(0.5) : AppColors.borderLight,
                    ),
                  ),
                ),
                child: Text(
                  '${targetName.id}',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isFilled ? AppColors.gold : null,
                  ),
                ),
              ),
              
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMD),
                  child: isFilled
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                targetName.transliteration,
                                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              targetName.arabic,
                              style: GoogleFonts.amiri(
                                fontSize: 24,
                                color: AppColors.gold,
                                fontWeight: FontWeight.bold,
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                          ],
                        )
                      : Text(
                          targetName.id == 0 ? targetName.transliteration : '???', // Hint
                          style: GoogleFonts.poppins(
                            color: Theme.of(context).hintColor.withValues(alpha: 0.5),
                            fontStyle: FontStyle.italic,
                            fontSize: 18,
                          ),
                        ),
                ),
              ),
              
              // Success Checkmark
              if (isFilled)
                const Padding(
                  padding: EdgeInsets.only(right: AppSizes.paddingMD),
                  child: Icon(Icons.check_circle, color: Colors.green),
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
          color: Theme.of(context).cardColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(AppSizes.radiusSM),
          border: Border.all(color: AppColors.borderLight),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppSizes.radiusSM),
          border: Border.all(
            color: AppColors.gold.withOpacity(0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withOpacity(0.1),
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
