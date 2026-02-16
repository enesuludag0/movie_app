import 'package:flutter/material.dart';
import 'package:movie_app/models/movie.dart';
import 'package:movie_app/services/api_service.dart';
import 'package:movie_app/services/favorites_service.dart';
import 'package:movie_app/components/movie_card.dart';
import 'package:movie_app/views/favorites_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ApiService apiService = ApiService();
  late FavoritesService favoritesService;
  List<Movie> movies = [];
  List<Movie> filteredMovies = [];
  Set<int> favoriteIds = {};
  bool isLoading = true;
  String searchQuery = '';

  Future<void> loadFavorites() async {
    try {
      final favorites = await favoritesService.getFavorites();
      setState(() {
        favoriteIds = favorites.toSet();
      });
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    }
  }

  Future<void> loadPopularMovies() async {
    try {
      setState(() => isLoading = true);
      final result = await apiService.getPopularMovies();
      setState(() {
        movies = result;
        filteredMovies = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void searchMovies(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchQuery = '';
        filteredMovies = movies;
      });
      return;
    }

    try {
      setState(() {
        searchQuery = query;
        isLoading = true;
      });
      final results = await apiService.searchMovies(query);
      setState(() {
        filteredMovies = results;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  void initState() {
    super.initState();
    favoritesService = FavoritesService();
    loadFavorites();
    loadPopularMovies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Movies & TV Series'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: IconButton(
              icon: const Icon(Icons.favorite),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        FavoritesScreen(favoriteIds: favoriteIds),
                  ),
                ).then((_) {
                  loadFavorites();
                });
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                onChanged: searchMovies,
                decoration: InputDecoration(
                  hintText: 'Search movies or TV series...',
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            searchMovies('');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
            ),

            // Content
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : filteredMovies.isEmpty
                  ? Center(
                      child: Text(
                        searchQuery.isEmpty
                            ? 'No shows available'
                            : 'No results found',
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredMovies.length,
                      itemBuilder: (context, index) {
                        final movie = filteredMovies[index];
                        return MovieCard(
                          movie: movie,
                          isFavorite: favoriteIds.contains(movie.id),
                          onFavoriteChanged: (isFavorite) {
                            setState(() {
                              if (isFavorite) {
                                favoriteIds.add(movie.id);
                              } else {
                                favoriteIds.remove(movie.id);
                              }
                            });
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
