import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../models/allah_name.dart';
import '../providers/names_provider.dart';
import '../providers/audio_provider.dart';
import '../providers/language_provider.dart';

class NameDetailScreen extends StatefulWidget {
  final AllahName name;

  const NameDetailScreen({super.key, required this.name});

  @override
  State<NameDetailScreen> createState() => _NameDetailScreenState();
}

class _NameDetailScreenState extends State<NameDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Stop any playing audio when entering detail screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AudioProvider>().stop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final namesProvider = context.read<NamesProvider>();
    final audioProvider = context.watch<AudioProvider>();
    final isPlaying =
        audioProvider.currentName?.id == widget.name.id &&
        audioProvider.isPlaying;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name.transliteration),
        actions: [
          PopupMenuButton<bool>(
            icon: const Icon(Icons.language),
            tooltip: 'Select Audio Language',
            initialValue: context.watch<LanguageProvider>().isAmharicAudio,
            onSelected: (bool isAmharic) {
              context.read<LanguageProvider>().toggleLanguage(isAmharic);
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingXL),
          child: Column(
            children: [
              // Arabic Name
              Text(
                widget.name.arabic,
                style: GoogleFonts.amiri(
                  fontSize: 56,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.paddingXL),

              // Transliteration
              Text(
                widget.name.transliteration,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.paddingMD),

              // English Meaning
              Text(
                widget.name.meaningEn,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.paddingSM),

              // Amharic Meaning
              if (widget.name.meaningAm.isNotEmpty)
                Text(
                  widget.name.meaningAm,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),

              const SizedBox(height: AppSizes.padding2XL),

              // Play Button
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.3),
                      blurRadius: 16,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      final index = namesProvider.getIndexById(widget.name.id);
                      if (index != -1) {
                        if (audioProvider.currentName?.id == widget.name.id) {
                          if (isPlaying) {
                            await audioProvider.pause();
                          } else {
                            await audioProvider.resume();
                          }
                        } else {
                          await audioProvider.playByIndex(index);
                        }
                      }
                    },
                    customBorder: const CircleBorder(),
                    child: Center(
                      child: Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSizes.padding2XL),

              // Explanation
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingXL),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(AppSizes.radiusLG),
                  border: Border(
                    left: BorderSide(color: AppColors.gold, width: 4),
                  ),
                ),
                child: Text(
                  widget.name.explanation,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(height: 1.8),
                ),
              ),

              const SizedBox(height: AppSizes.padding2XL),

              // Navigation Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        final prevId = widget.name.id > 1
                            ? widget.name.id - 1
                            : 99;
                        final prevName = namesProvider.getNameById(prevId);
                        if (prevName != null) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => NameDetailScreen(name: prevName),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Previous'),
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingMD),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        final nextId = widget.name.id < 99
                            ? widget.name.id + 1
                            : 1;
                        final nextName = namesProvider.getNameById(nextId);
                        if (nextName != null) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => NameDetailScreen(name: nextName),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Next'),
                      style: OutlinedButton.styleFrom(
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
