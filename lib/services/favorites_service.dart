import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static const String _favoritesKey = 'favorite_movie_ids';

  Future<void> addFavorite(int movieId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList(_favoritesKey) ?? [];
    
    if (!favorites.contains(movieId.toString())) {
      favorites.add(movieId.toString());
      await prefs.setStringList(_favoritesKey, favorites);
    }
  }

  Future<void> removeFavorite(int movieId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList(_favoritesKey) ?? [];
    
    favorites.removeWhere((id) => id == movieId.toString());
    await prefs.setStringList(_favoritesKey, favorites);
  }

  Future<List<int>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList(_favoritesKey) ?? [];
    
    return favorites.map((id) => int.parse(id)).toList();
  }

  Future<bool> isFavorite(int movieId) async {
    final favorites = await getFavorites();
    return favorites.contains(movieId);
  }

  Future<void> clearFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_favoritesKey);
  }

  Future<void> toggleFavorite(int movieId) async {
    final isFav = await isFavorite(movieId);
    if (isFav) {
      await removeFavorite(movieId);
    } else {
      await addFavorite(movieId);
    }
  }
}
