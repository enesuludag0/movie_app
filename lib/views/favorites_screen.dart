import 'package:flutter/material.dart';
import 'package:movie_app/models/movie.dart';
import 'package:movie_app/services/favorites_service.dart';
import 'package:movie_app/services/api_service.dart';
import 'package:movie_app/components/movie_card.dart';

class FavoritesScreen extends StatefulWidget {
  final Set<int>? favoriteIds;

  const FavoritesScreen({super.key, this.favoriteIds});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late FavoritesService favoritesService = FavoritesService();
  late ApiService apiService = ApiService();
  List<Movie> favoriteMovies = [];
  bool isLoading = true;

  Future<void> loadFavoriteMovies() async {
    try {
      setState(() => isLoading = true);

      final favoriteIds = await favoritesService.getFavorites();
      List<Movie> movies = [];

      for (int id in favoriteIds) {
        try {
          final movie = await apiService.getMovieDetails(id);
          movies.add(movie);
        } catch (e) {
          // Skip movies that fail to load
          debugPrint('Failed to load movie $id: $e');
        }
      }

      setState(() {
        favoriteMovies = movies;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading favorites: $e')));
      }
    }
  }

  @override
  void initState() {
    loadFavoriteMovies();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Favorites'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : favoriteMovies.isEmpty
          ? SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No Favorites Yet',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Add movies to your favorites to see them here',
                      style: TextStyle(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: loadFavoriteMovies,
              child: ListView.builder(
                itemCount: favoriteMovies.length,
                itemBuilder: (context, index) {
                  final movie = favoriteMovies[index];
                  return MovieCard(
                    movie: movie,
                    isFavorite: true,
                    onFavoriteChanged: (isFavorite) {
                      if (!isFavorite) {
                        loadFavoriteMovies();
                      }
                    },
                  );
                },
              ),
            ),
    );
  }
}
