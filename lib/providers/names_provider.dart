import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/allah_name.dart';

class NamesProvider with ChangeNotifier {
  List<AllahName> _allNames = [];
  List<AllahName> _filteredNames = [];
  bool _isLoading = true;
  String _searchQuery = '';

  // Cache for getIndexById lookups
  Map<int, int> _indexCache = {};

  List<AllahName> get allNames => _allNames;
  List<AllahName> get filteredNames => _filteredNames;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  NamesProvider() {
    loadNames();
  }

  Future<void> loadNames() async {
    try {
      _isLoading = true;
      // Don't notifyListeners here - avoid unnecessary rebuild during init

      // Load JSON file from assets
      final String jsonString = await rootBundle.loadString(
        'assets/data/names.json',
      );
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> namesJson = jsonData['names'];

      _allNames = namesJson.map((json) => AllahName.fromJson(json)).toList();

      // Sort by id to ensure proper order (0, 1, 2, 3, ...)
      _allNames.sort((a, b) => a.id.compareTo(b.id));

      // Build index cache for O(1) lookups
      _indexCache = {};
      for (int i = 0; i < _allNames.length; i++) {
        _indexCache[_allNames[i].id] = i;
      }

      _filteredNames = List.from(_allNames);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading names: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  void searchNames(String query) {
    final trimmed = query.trim();
    if (trimmed == _searchQuery) return; // Skip if query unchanged
    _searchQuery = trimmed;

    if (_searchQuery.isEmpty) {
      _filteredNames = List.from(_allNames);
    } else {
      final lowerQuery = _searchQuery.toLowerCase();
      _filteredNames = _allNames.where((name) {
        return name.transliteration.toLowerCase().contains(lowerQuery) ||
            name.meaningEn.toLowerCase().contains(lowerQuery) ||
            name.arabic.contains(_searchQuery) ||
            name.meaningAm.toLowerCase().contains(lowerQuery) ||
            name.id.toString() == _searchQuery;
      }).toList();
    }

    notifyListeners();
  }

  /// Clear search and reset list to default order
  void clearSearch() {
    if (_searchQuery.isEmpty) return; // Skip if already cleared
    _searchQuery = '';
    _filteredNames = List.from(_allNames);
    notifyListeners();
  }

  AllahName? getNameById(int id) {
    final index = _indexCache[id];
    if (index != null && index < _allNames.length) {
      return _allNames[index];
    }
    return null;
  }

  int getIndexById(int id) {
    return _indexCache[id] ?? -1; // O(1) lookup instead of O(n) search
  }
}
