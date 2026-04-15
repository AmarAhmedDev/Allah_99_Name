import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/allah_name.dart';

class AudioProvider with ChangeNotifier {
  AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterTts _flutterTts = FlutterTts();
  Timer? _nextTrackTimer;

  List<AllahName> _playlist = [];
  int _currentIndex = 0;
  bool _isPlaying = false;
  bool _isLoading = false;
  bool _autoPlay = false;
  bool _useTtsFallback = false;
  bool _isAmharicAudio = false;

  AllahName? get currentName =>
      _currentIndex < _playlist.length ? _playlist[_currentIndex] : null;
  int get currentIndex => _currentIndex;
  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;
  int get totalCount => _playlist.length;
  bool get isAmharicAudio => _isAmharicAudio;
  bool get isAutoPlay => _autoPlay;

  void setAutoPlay(bool value) {
    _autoPlay = value;
  }

  void updateLanguage(bool isAmharic) {
    if (_isAmharicAudio != isAmharic) {
      _isAmharicAudio = isAmharic;
      notifyListeners();
    }
  }

  AudioProvider() {
    _initializeTts();
    _initializeAudioPlayer();
  }

  void _initializeAudioPlayer() {
    // Use mediaPlayer mode for full audio playback (not lowLatency which is for short sounds)
    _audioPlayer.setReleaseMode(ReleaseMode.stop);
    _audioPlayer.setPlayerMode(PlayerMode.mediaPlayer);
    _audioPlayer.setVolume(1.0);

    _audioPlayer.onPlayerComplete.listen((_) {
      _onAudioComplete();
    });

    // Track actual player state to keep isPlaying in sync
    // We only listen for completed. Stop/Pause natively sync via method calls.
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      if (state == PlayerState.completed) {
        if (!_useTtsFallback) {
          _isPlaying = false;
          notifyListeners();
        }
      }
    });
  }

  void _initializeTts() async {
    await _flutterTts.setLanguage('ar-SA');
    await _flutterTts.setSpeechRate(0.4);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    _flutterTts.setCompletionHandler(() {
      if (_useTtsFallback) {
        _useTtsFallback = false;
        _onAudioComplete();
      }
    });
  }

  void setPlaylist(List<AllahName> names) {
    _playlist = names;
    _currentIndex = 0;
    notifyListeners();
  }

  Future<void> playByIndex(int index) async {
    _nextTrackTimer?.cancel();
    if (index < 0 || index >= _playlist.length) return;

    _currentIndex = index;
    _isPlaying = true; // Instantly show pause button for a snappy UI
    _isLoading = false; // Disable spinner to remove delay feeling
    _useTtsFallback = false;
    notifyListeners();

    // Stop any currently playing audio first
    try {
      await _audioPlayer.stop();
      await _flutterTts.stop();
    } catch (_) {}

    final name = _playlist[index];

    try {
      bool audioPlayed = false;

      if (name.hasAudio) {
        audioPlayed = await _tryPlayAudio(name.audioUrl!);

        // If primary fails, try alternative URLs
        if (!audioPlayed) {
          final alternativeUrls = name.getAlternativeAudioUrls();
          for (final url in alternativeUrls) {
            if (url == name.audioUrl) continue; // Skip already tried
            audioPlayed = await _tryPlayAudio(url);
            if (audioPlayed) break;
          }
        }
      }

      // Fallback to Text-to-Speech if all audio sources fail
      if (!audioPlayed) {
        _useTtsFallback = true;
        await _flutterTts.speak(name.arabic);
        _isPlaying = true;
      }
    } catch (e) {
      debugPrint('Error playing audio: $e');
      _useTtsFallback = true;
      await _flutterTts.speak(name.arabic);
      _isPlaying = true;
    } finally {
      notifyListeners();
    }
  }

  /// Play audio with full volume - recreate player if needed for reliability
  Future<bool> _tryPlayAudio(String url) async {
    try {
      // Ensure volume is at maximum before every play (fixes volume drop after id 84)
      await _audioPlayer.setVolume(1.0);
      await _audioPlayer.setPlayerMode(PlayerMode.mediaPlayer);

      if (url.startsWith('assets/audio/')) {
        String langFolder = _isAmharicAudio ? 'Amharic' : 'English';
        url = url.replaceFirst('assets/audio/', 'assets/audio/$langFolder/');
      }

      if (url.startsWith('assets/')) {
        final assetPath = url.replaceFirst('assets/', '');
        await _audioPlayer.play(AssetSource(assetPath));
      } else {
        await _audioPlayer.play(UrlSource(url));
      }

      // Re-confirm volume after play starts (some devices reset volume on new source)
      await _audioPlayer.setVolume(1.0);

      _isPlaying = true;
      return true;
    } catch (e) {
      debugPrint('❌ Failed to play: $url - $e');
      // If playback fails, try recreating the player
      try {
        await _audioPlayer.dispose();
        _audioPlayer = AudioPlayer();
        _initializeAudioPlayer();

        await _audioPlayer.setVolume(1.0);
        
        if (url.startsWith('assets/audio/')) {
          String langFolder = _isAmharicAudio ? 'Amharic' : 'English';
          url = url.replaceFirst('assets/audio/', 'assets/audio/$langFolder/');
        }

        if (url.startsWith('assets/')) {
          final assetPath = url.replaceFirst('assets/', '');
          await _audioPlayer.play(AssetSource(assetPath));
        } else {
          await _audioPlayer.play(UrlSource(url));
        }
        await _audioPlayer.setVolume(1.0);
        _isPlaying = true;
        return true;
      } catch (e2) {
        debugPrint('❌ Retry also failed: $url - $e2');
        return false;
      }
    }
  }

  Future<void> play() async {
    if (_playlist.isEmpty) return;
    await playByIndex(_currentIndex);
  }

  /// Play all names from the very beginning (index 0)
  Future<void> playFromStart() async {
    if (_playlist.isEmpty) return;
    _autoPlay = true; // Auto-play is only enabled for "Play All" mode
    await playByIndex(0);
  }

  Future<void> pause() async {
    _nextTrackTimer?.cancel();
    await _audioPlayer.pause();
    await _flutterTts.stop();
    _isPlaying = false;
    _useTtsFallback = false;
    notifyListeners();
  }

  Future<void> stop() async {
    _nextTrackTimer?.cancel();
    await _audioPlayer.stop();
    await _flutterTts.stop();
    _isPlaying = false;
    _useTtsFallback = false;
    notifyListeners();
  }

  Future<void> resume() async {
    _nextTrackTimer?.cancel();
    await _audioPlayer.resume();
    _isPlaying = true;
    notifyListeners();
  }

  Future<void> next() async {
    if (_currentIndex < _playlist.length - 1) {
      await playByIndex(_currentIndex + 1);
    } else {
      await playByIndex(0);
    }
  }

  Future<void> previous() async {
    if (_currentIndex > 0) {
      await playByIndex(_currentIndex - 1);
    } else {
      await playByIndex(_playlist.length - 1);
    }
  }

  Future<void> togglePlay() async {
    if (_isPlaying) {
      await pause();
    } else {
      if (_audioPlayer.state == PlayerState.paused) {
        await resume();
      } else {
        await play();
      }
    }
  }

  void _onAudioComplete() {
    _isPlaying = false;
    _useTtsFallback = false;
    notifyListeners();

    if (_autoPlay && _currentIndex < _playlist.length - 1) {
      _nextTrackTimer?.cancel();
      // Small delay before next track for smooth continuous playback
      _nextTrackTimer = Timer(const Duration(milliseconds: 500), () {
        if (_autoPlay) {
          playByIndex(_currentIndex + 1);
        }
      });
    }
  }

  @override
  void dispose() {
    _nextTrackTimer?.cancel();
    _audioPlayer.dispose();
    _flutterTts.stop();
    super.dispose();
  }
}
