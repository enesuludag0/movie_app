import 'package:flutter/material.dart';
import 'package:movie_app/models/movie.dart';
import 'package:movie_app/components/rating_widget.dart';
import 'package:movie_app/components/info_card.dart';
import 'package:movie_app/services/favorites_service.dart';

class MovieDetailScreen extends StatefulWidget {
  final Movie movie;
  final bool isFavorite;
  final Function(bool)? onFavoriteChanged;

  const MovieDetailScreen({
    super.key,
    required this.movie,
    this.isFavorite = false,
    this.onFavoriteChanged,
  });

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  late FavoritesService favoritesService = FavoritesService();
  late bool _isFavorite;

  Future<void> _toggleFavorite() async {
    if (_isFavorite) {
      await favoritesService.removeFavorite(widget.movie.id);
      setState(() => _isFavorite = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${widget.movie.name} favorilerden silindi')),
        );
      }
    } else {
      await favoritesService.addFavorite(widget.movie.id);
      setState(() => _isFavorite = true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${widget.movie.name} favorilere eklendi')),
        );
      }
    }
    widget.onFavoriteChanged?.call(_isFavorite);
  }

  String removeTags(String html) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: false);
    return html.replaceAll(exp, '').replaceAll('&nbsp;', ' ');
  }

  @override
  void initState() {
    _isFavorite = widget.isFavorite;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.movie.name),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                if (widget.movie.image != null)
                  Center(
                    child: Hero(
                      tag: widget.movie.id,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          widget.movie.image!,
                          height: 300,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 300,
                              width: 200,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.image_not_supported),
                            );
                          },
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    height: 300,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.image_not_supported),
                  ),
                SizedBox(height: 24),

                // Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      widget.movie.name,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),

                    IconButton(
                      icon: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: _isFavorite ? Colors.red : null,
                      ),
                      onPressed: _toggleFavorite , 
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Rating
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: RatingWidget(
                    rating: widget.movie.rating?.average,
                    fontSize: 18,
                    width: 14,
                  ),
                ),
                SizedBox(height: 16),

                // Info Row
                Row(
                  children: [
                    if (widget.movie.status != null)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Status',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              widget.movie.status!,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (widget.movie.premiered != null)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Premiered',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              widget.movie.premiered!,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 16),

                // Additional Info Grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  childAspectRatio: 2.5,
                  children: [
                    if (widget.movie.type != null)
                      InfoCard(label: 'Type', value: widget.movie.type!),
                    if (widget.movie.language != null)
                      InfoCard(
                        label: 'Language',
                        value: widget.movie.language!,
                      ),
                    if (widget.movie.runtime != null)
                      InfoCard(
                        label: 'Runtime',
                        value: '${widget.movie.runtime} min',
                      ),
                    if (widget.movie.schedule != null &&
                        widget.movie.schedule!.days.isNotEmpty)
                      InfoCard(
                        label: 'Broadcast',
                        value:
                            '${widget.movie.schedule!.days.join(", ")}${widget.movie.schedule!.time != null ? " at ${widget.movie.schedule!.time}" : ""}',
                      ),
                  ],
                ),
                SizedBox(height: 16),

                // Genres
                if (widget.movie.genres.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Genres',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: widget.movie.genres
                            .map(
                              (genre) => Chip(
                                label: Text(genre),
                                backgroundColor: Colors.deepPurple.withOpacity(
                                  0.2,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      SizedBox(height: 16),
                    ],
                  ),

                // Network
                if (widget.movie.network != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Network',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        widget.movie.network!,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                    ],
                  ),

                // Ended Date
                if (widget.movie.ended != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ended',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        widget.movie.ended!,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                    ],
                  ),

                // Official Site Button
                if (widget.movie.officialSite != null)
                  Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Official Site: ${widget.movie.officialSite}',
                            ),
                          ),
                        );
                      },
                      icon: Icon(Icons.language),
                      label: Text('Visit Official Site'),
                    ),
                  ),

                // Summary
                if (widget.movie.summary != null &&
                    widget.movie.summary!.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Description',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        removeTags(widget.movie.summary!),
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    'No description available',
                    style: TextStyle(color: Colors.grey),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
