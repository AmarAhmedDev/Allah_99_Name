class AllahName {
  final int id;
  final String arabic;
  final String transliteration;
  final String meaningEn;
  final String meaningAm;
  final String explanation;
  final String explanationAm;
  final String? audioUrl;

  AllahName({
    required this.id,
    required this.arabic,
    required this.transliteration,
    required this.meaningEn,
    required this.meaningAm,
    required this.explanation,
    required this.explanationAm,
    this.audioUrl,
  });

  factory AllahName.fromJson(Map<String, dynamic> json) {
    final int id = json['id'] as int;

    // Generate beautiful recitation URL from multiple sources
    final String generatedAudioUrl = _generateAudioUrl(id);

    return AllahName(
      id: id,
      arabic: json['arabic'] as String,
      transliteration: json['transliteration'] as String,
      meaningEn: json['meaning_en'] as String,
      meaningAm: json['meaning_am'] as String? ?? '',
      explanation: json['explanation'] as String,
      explanationAm: json['explanation_am'] as String? ?? json['explanation'] as String,
      audioUrl: json['audio_url'] as String? ?? generatedAudioUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'arabic': arabic,
      'transliteration': transliteration,
      'meaning_en': meaningEn,
      'meaning_am': meaningAm,
      'explanation': explanation,
      'explanation_am': explanationAm,
      'audio_url': audioUrl,
    };
  }

  /// Generate audio path for beautiful recitation
  /// Uses local asset files for offline playback
  static String _generateAudioUrl(int id) {
    // Format ID with leading zeros (e.g., 001, 002, etc.)
    final String formattedId = id.toString().padLeft(3, '0');

    // Primary source: Local asset file (offline)
    return 'assets/audio/$formattedId.mp3';
  }

  /// Get alternative audio URLs as fallback options
  /// Includes both local assets and online sources
  List<String> getAlternativeAudioUrls() {
    final String formattedId = id.toString().padLeft(3, '0');

    return [
      // Primary: Local asset (offline)
      'assets/audio/$formattedId.mp3',

      // Fallback 1: Islamic Finder (online)
      'https://www.islamicfinder.us/audios/asma-ul-husna/$formattedId.mp3',

      // Fallback 2: GitHub repository (online)
      'https://raw.githubusercontent.com/soachishti/Asma-ul-Husna/master/audio/$id.mp3',

      // Fallback 3: Alternative CDN (online)
      'https://cdn.islamic.network/quran/audio/128/ar.alafasy/$id.mp3',
    ];
  }

  /// Get local asset path
  String get localAudioPath =>
      'assets/audio/${id.toString().padLeft(3, '0')}.mp3';

  /// Check if using local audio (offline)
  bool get isLocalAudio => audioUrl?.startsWith('assets/') ?? false;

  /// Check if this name has a valid audio URL
  bool get hasAudio => audioUrl != null && audioUrl!.isNotEmpty;

  /// Get display name with number
  String get displayName => '$id. $transliteration';

  /// Get full Arabic text with diacritics
  String get arabicWithDiacritics => arabic;

  /// Create a copy with updated fields
  AllahName copyWith({
    int? id,
    String? arabic,
    String? transliteration,
    String? meaningEn,
    String? meaningAm,
    String? explanation,
    String? explanationAm,
    String? audioUrl,
  }) {
    return AllahName(
      id: id ?? this.id,
      arabic: arabic ?? this.arabic,
      transliteration: transliteration ?? this.transliteration,
      meaningEn: meaningEn ?? this.meaningEn,
      meaningAm: meaningAm ?? this.meaningAm,
      explanation: explanation ?? this.explanation,
      explanationAm: explanationAm ?? this.explanationAm,
      audioUrl: audioUrl ?? this.audioUrl,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AllahName &&
        other.id == id &&
        other.arabic == arabic &&
        other.transliteration == transliteration;
  }

  @override
  int get hashCode {
    return id.hashCode ^ arabic.hashCode ^ transliteration.hashCode;
  }

  @override
  String toString() {
    return 'AllahName(id: $id, transliteration: $transliteration, arabic: $arabic)';
  }
}
