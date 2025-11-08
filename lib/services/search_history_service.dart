import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing search history with SharedPreferences
class SearchHistoryService {
  static const String _searchHistoryKey = 'search_history';
  static const int maxHistoryItems = 10;

  /// Get search history
  static Future<List<String>> getSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList(_searchHistoryKey) ?? [];
      return history;
    } catch (e) {
      print('Error getting search history: $e');
      return [];
    }
  }

  /// Add search term to history
  static Future<void> addSearchTerm(String term) async {
    if (term.trim().isEmpty) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList(_searchHistoryKey) ?? [];

      // Remove if already exists (to put at top)
      history.removeWhere((item) => item.toLowerCase() == term.toLowerCase());

      // Add to beginning
      history.insert(0, term);

      // Keep only maxHistoryItems
      if (history.length > maxHistoryItems) {
        history.removeRange(maxHistoryItems, history.length);
      }

      await prefs.setStringList(_searchHistoryKey, history);
    } catch (e) {
      print('Error adding search term: $e');
    }
  }

  /// Clear all search history
  static Future<void> clearSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_searchHistoryKey);
    } catch (e) {
      print('Error clearing search history: $e');
    }
  }

  /// Remove specific search term
  static Future<void> removeSearchTerm(String term) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList(_searchHistoryKey) ?? [];
      history.removeWhere((item) => item == term);
      await prefs.setStringList(_searchHistoryKey, history);
    } catch (e) {
      print('Error removing search term: $e');
    }
  }
}
