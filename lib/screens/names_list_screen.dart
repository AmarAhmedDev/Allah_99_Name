import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../providers/names_provider.dart';
import '../providers/audio_provider.dart';
import '../providers/language_provider.dart';
import '../models/allah_name.dart';
import 'name_detail_screen.dart';
import 'audio_player_screen.dart';

class NamesListScreen extends StatefulWidget {
  const NamesListScreen({super.key});

  @override
  State<NamesListScreen> createState() => _NamesListScreenState();
}

class _NamesListScreenState extends State<NamesListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final namesProvider = context.read<NamesProvider>();
    final audioProvider = context.read<AudioProvider>();

    // Reset search when entering screen
    namesProvider.clearSearch();

    if (namesProvider.allNames.isNotEmpty) {
      audioProvider.setPlaylist(namesProvider.allNames);
    }

    // Listen to search controller changes
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final namesProvider = context.read<NamesProvider>();
    final text = _searchController.text;
    namesProvider.searchNames(text);
    // Rebuild to update the clear icon visibility
    setState(() {});
  }

  void _clearSearch() {
    _searchController.clear();
    final namesProvider = context.read<NamesProvider>();
    namesProvider.clearSearch();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final namesProvider = context.watch<NamesProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('99 Names of Allah'),
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
      body: namesProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingLG,
                    vertical: AppSizes.paddingMD,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gold.withValues(alpha: 0.1),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.borderDark
                            : AppColors.gold.withValues(alpha: 0.3),
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: GoogleFonts.poppins(fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'Search Arabic, translation, meaning...',
                        hintStyle: GoogleFonts.poppins(
                          color: Theme.of(context).hintColor,
                          fontSize: 14,
                        ),
                        prefixIcon: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Icon(Icons.search, color: AppColors.gold),
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 20, color: Colors.grey),
                                onPressed: _clearSearch,
                              )
                            : const SizedBox(width: 48), // balance padding
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                ),

                // Names Grid
                Expanded(
                  child: namesProvider.filteredNames.isEmpty
                      ? _buildEmptyState()
                      : GridView.builder(
                          padding: const EdgeInsets.all(AppSizes.paddingMD),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: _getCrossAxisCount(context),
                                crossAxisSpacing: AppSizes.paddingMD,
                                mainAxisSpacing: AppSizes.paddingMD,
                                childAspectRatio: 0.75,
                              ),
                          itemCount: namesProvider.filteredNames.length,
                          itemBuilder: (context, index) {
                            final name = namesProvider.filteredNames[index];
                            return _NameCard(name: name);
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AudioPlayerScreen()),
          );
        },
        icon: const Icon(Icons.play_arrow),
        label: const Text('Play All'),
      ),
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 900) return 4;
    if (width > 600) return 3;
    return 2;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🔍', style: TextStyle(fontSize: 64)),
          const SizedBox(height: AppSizes.paddingLG),
          Text(
            'No names found',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.textTertiaryDark
                  : AppColors.textTertiaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _NameCard extends StatelessWidget {
  final AllahName name;
  const _NameCard({required this.name});

  @override
  Widget build(BuildContext context) {
    final audioProvider = context.watch<AudioProvider>();
    final isPlaying =
        audioProvider.currentName?.id == name.id && audioProvider.isPlaying;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => NameDetailScreen(name: name)),
          );
        },
        child: Stack(
          children: [
            // Top accent line
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 4,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.gold, AppColors.goldLight],
                  ),
                ),
              ),
            ),

            // Playing indicator (Moved here so it's behind the play button)
            if (isPlaying)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.gold, width: 2),
                      borderRadius: BorderRadius.circular(AppSizes.radiusLG),
                    ),
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingMD),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Number Badge
                  Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: AppColors.gold,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${name.id}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingSM),

                  // Arabic Name
                  Expanded(
                    child: Center(
                      child: Text(
                        name.arabic,
                        style: GoogleFonts.amiri(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          height: 1.8,
                        ),
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                  // Transliteration
                  Text(
                    name.transliteration,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSizes.paddingXS),

                  // Meaning
                  Text(
                    context.watch<LanguageProvider>().isAmharicAudio && name.meaningAm.isNotEmpty
                        ? name.meaningAm
                        : name.meaningEn,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.gold,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: AppSizes.paddingSM),

                  // Play Button
                  Align(
                    alignment: Alignment.bottomRight,
                    child: GestureDetector(
                      // Catch any stray taps in the padded area to prevent Bubble
                      onTap: () {}, 
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: IconButton(
                          iconSize: 24,
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.gold,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(12),
                            minimumSize: const Size(48, 48),
                          ),
                          onPressed: () async {
                            final provider = context.read<AudioProvider>();
                            final namesProvider = context.read<NamesProvider>();

                            // Ensure playlist is set if empty but names are available
                            if (provider.totalCount == 0 &&
                                namesProvider.allNames.isNotEmpty) {
                              provider.setPlaylist(namesProvider.allNames);
                            }

                            final index = namesProvider.getIndexById(name.id);
                            if (index != -1) {
                              provider.setAutoPlay(false); // Only play this track

                              if (provider.currentName?.id == name.id) {
                                if (provider.isPlaying) {
                                  await provider.pause();
                                } else {
                                  await provider.resume();
                                }
                              } else {
                                await provider.playByIndex(index);
                              }
                            }
                          },
                          icon: audioProvider.isLoading &&
                                  audioProvider.currentName?.id == name.id
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Icon(
                                  isPlaying ? Icons.pause : Icons.play_arrow,
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}
