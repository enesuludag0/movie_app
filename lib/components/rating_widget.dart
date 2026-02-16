import 'package:flutter/material.dart';

class RatingWidget extends StatelessWidget {
  final double? rating;
  final double size;
  final double fontSize;
  final double width;

  const RatingWidget({
    Key? key,
    this.rating,
    this.size = 24.0,
    this.fontSize = 14.0,
    this.width = 8.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (rating == null) {
      return Row(
        children: [
          Icon(Icons.star_border, size: size, color: Colors.grey),
          SizedBox(width: 4),
          Text('No rating', style: TextStyle(color: Colors.grey)),
        ],
      );
    }

    final stars = (rating! / 2).round(); // Normalize to 5 stars
    final filledStars = stars;
    final emptyStars = 5 - stars;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ...List.generate(
              filledStars,
              (_) => Icon(Icons.star, size: size, color: Colors.amber),
            ),
            ...List.generate(
              emptyStars,
              (_) => Icon(Icons.star_border, size: size, color: Colors.grey),
            ),
            SizedBox(width: width),
            Text(
              '${rating!.toStringAsFixed(1)}/10',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
