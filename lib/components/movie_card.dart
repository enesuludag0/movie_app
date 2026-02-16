import 'package:flutter/material.dart';
import 'package:movie_app/models/movie.dart';
import 'package:movie_app/components/rating_widget.dart';
import 'package:movie_app/views/movie_detail_screen.dart';
import 'package:movie_app/services/favorites_service.dart';

class MovieCard extends StatefulWidget {
  final Movie movie;
  final bool isFavorite;
  final Function(bool)? onFavoriteChanged;

  const MovieCard({
    Key? key,
    required this.movie,
    this.isFavorite = false,
    this.onFavoriteChanged,
  }) : super(key: key);

  @override
  State<MovieCard> createState() => _MovieCardState();
}

class _MovieCardState extends State<MovieCard> {
  late FavoritesService favoritesService = FavoritesService();
  late bool _isFavorite;

  Future<void> _toggleFavorite() async {
    if (_isFavorite) {
      await favoritesService.removeFavorite(widget.movie.id);
      setState(() => _isFavorite = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.movie.name} favorilerden çıkarıldı.'),
          ),
        );
      }
    } else {
      await favoritesService.addFavorite(widget.movie.id);
      setState(() => _isFavorite = true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${widget.movie.name} favorilere eklendi.')),
        );
      }
    }
    widget.onFavoriteChanged?.call(_isFavorite);
  }

  @override
  void initState() {
    _isFavorite = widget.isFavorite;
    super.initState();
  }

  @override
  void didUpdateWidget(MovieCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFavorite != widget.isFavorite) {
      _isFavorite = widget.isFavorite;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MovieDetailScreen(
              movie: widget.movie,
              isFavorite: _isFavorite,
              onFavoriteChanged: widget.onFavoriteChanged,
            ),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              if (widget.movie.image != null)
                Hero(
                  tag: widget.movie.id,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      widget.movie.image!,
                      width: 80,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 80,
                          height: 120,
                          color: Colors.grey[300],
                          child: Icon(Icons.image_not_supported),
                        );
                      },
                    ),
                  ),
                )
              else
                Container(
                  width: 80,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.image_not_supported),
                ),
              SizedBox(width: 16),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 2),
                    // Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.movie.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        IconButton(
                          visualDensity: VisualDensity.compact,
                          icon: Icon(
                            _isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: _isFavorite ? Colors.red : null,
                          ),
                          onPressed: _toggleFavorite,
                        ),
                      ],
                    ),

                    // Genres
                    if (widget.movie.genres.isNotEmpty)
                      Text(
                        widget.movie.genres.join(', '),
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    SizedBox(height: 8),

                    // Type and Runtime
                    Row(
                      children: [
                        if (widget.movie.type != null)
                          Text(
                            widget.movie.type!,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.deepPurple,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        if (widget.movie.type != null &&
                            widget.movie.runtime != null)
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              '•',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        if (widget.movie.runtime != null)
                          Text(
                            '${widget.movie.runtime} min',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 8),
                    if (widget.movie.status != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: widget.movie.status == 'Running'
                                  ? Colors.green.withOpacity(0.2)
                                  : Colors.orange.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              widget.movie.status!,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: widget.movie.status == 'Running'
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                            ),
                          ),

                          SizedBox(height: 8),

                          // Rating
                          if (widget.movie.rating?.average != null)
                            RatingWidget(
                              rating: widget.movie.rating!.average,
                              size: 16,
                            )
                          else
                            Text(
                              'No rating',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
