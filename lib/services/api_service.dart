import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:movie_app/models/movie.dart';

class ApiService {
  static const String baseUrl = 'https://api.tvmaze.com';

  Future<List<Movie>> searchMovies(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/search/shows?q=$query'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => Movie.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load shows: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching shows: $e');
    }
  }

  Future<List<Movie>> getPopularMovies() async {
    try {
      // Get popular shows by fetching shows sorted by ID
      final response = await http.get(Uri.parse('$baseUrl/shows?page=0'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => Movie.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load shows: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching popular shows: $e');
    }
  }

  Future<Movie> getMovieDetails(int movieId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/shows/$movieId'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Movie.fromJson(data);
      } else {
        throw Exception('Failed to load show details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching show details: $e');
    }
  }
}
