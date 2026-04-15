import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../providers/names_provider.dart';
import '../providers/audio_provider.dart';
import '../providers/language_provider.dart';

class AudioPlayerScreen extends StatefulWidget {
  const AudioPlayerScreen({super.key});

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late AudioProvider _audioProvider;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _audioProvider = context.read<AudioProvider>();

    // Set the playlist and start playing from the very first name
    final namesProvider = context.read<NamesProvider>();
    final audioProvider = context.read<AudioProvider>();

    if (namesProvider.allNames.isNotEmpty) {
      audioProvider.setPlaylist(namesProvider.allNames);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        audioProvider.playFromStart();
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    // Stop audio safely when leaving this screen (prevents unmounted context crash)
    _audioProvider.pause();
    _audioProvider.setAutoPlay(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final audioProvider = context.watch<AudioProvider>();
    final currentName = audioProvider.currentName;

    if (currentName == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Playing All Names')),
        body: const Center(child: Text('No names available')),
      );
    }

    final progress =
        (audioProvider.currentIndex + 1) / audioProvider.totalCount;

    return WillPopScope(
      onWillPop: () async {
        // Instantly pause BEFORE the exit animation even starts
        _audioProvider.pause();
        _audioProvider.setAutoPlay(false);
        return true;
      },
      child: Scaffold(
      appBar: AppBar(
        title: const Text('Playing All Names'),
        actions: [
          PopupMenuButton<bool>(
            icon: const Icon(Icons.language),
            tooltip: 'Select Audio Language',
            initialValue: context.watch<LanguageProvider>().isAmharicAudio,
            onSelected: (bool isAmharic) {
              context.read<LanguageProvider>().toggleLanguage(isAmharic);
              // Restart audio to reflect language change if currently playing?
              // The user might prefer if it continues but maybe in the newly selected language
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<bool>>[
              PopupMenuItem<bool>(
                value: false,
                child: Row(
                  children: [
                    const Text('English'),
                    if (!context.read<LanguageProvider>().isAmharicAudio)
                      const Spacer(),
                    if (!context.read<LanguageProvider>().isAmharicAudio)
                      const Icon(Icons.check, size: 20),
                  ],
                ),
              ),
              PopupMenuItem<bool>(
                value: true,
                child: Row(
                  children: [
                    const Text('አማርኛ'),
                    if (context.read<LanguageProvider>().isAmharicAudio)
                      const Spacer(),
                    if (context.read<LanguageProvider>().isAmharicAudio)
                      const Icon(Icons.check, size: 20),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.padding2XL),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Icon Circle
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [AppColors.goldLight, AppColors.gold],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.gold.withValues(alpha: 0.5),
                            blurRadius: 32,
                            spreadRadius: audioProvider.isPlaying ? 8 : 4,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '📿',
                          style: TextStyle(
                            fontSize: 80,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: AppSizes.padding2XL),

                // Current Name Display
                Column(
                  children: [
                    Text(
                      currentName.arabic,
                      style: GoogleFonts.amiri(
                        fontSize: 40,
                        fontWeight: FontWeight.w700,
                        height: 1.8,
                      ),
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSizes.paddingLG),

                    Text(
                      currentName.transliteration,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSizes.paddingMD),

                    Text(
                      currentName.meaningEn,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(color: AppColors.gold),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),

                const SizedBox(height: AppSizes.padding2XL),

                // Progress Bar
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${audioProvider.currentIndex + 1}/${audioProvider.totalCount}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          'Name ${currentName.id}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.paddingSM),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor:
                            Theme.of(context).brightness == Brightness.dark
                            ? AppColors.borderDark
                            : AppColors.borderLight,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.gold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSizes.padding2XL),

                // Audio Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Previous Button
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.gold, width: 2),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => audioProvider.previous(),
                          customBorder: const CircleBorder(),
                          child: const Icon(
                            Icons.skip_previous,
                            color: AppColors.gold,
                            size: 28,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: AppSizes.paddingLG),

                    // Play/Pause Button
                    Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                        color: AppColors.gold,
                        shape: BoxShape.circle,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => audioProvider.togglePlay(),
                          customBorder: const CircleBorder(),
                          child: Icon(
                            audioProvider.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: AppSizes.paddingLG),

                    // Next Button
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.gold, width: 2),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => audioProvider.next(),
                          customBorder: const CircleBorder(),
                          child: const Icon(
                            Icons.skip_next,
                            color: AppColors.gold,
                            size: 28,
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
      ),
    );
  }
}
