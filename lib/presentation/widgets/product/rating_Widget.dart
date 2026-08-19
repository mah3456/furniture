// lib/presentation/widgets/rating_widget.dart

import 'package:flutter/material.dart';

class RatingWidget extends StatelessWidget {
  final int rating;
  final double size;
  final Color filledColor;
  final Color emptyColor;

  const RatingWidget({
    Key? key,
    required this.rating,
    this.size = 20,
    this.filledColor = Colors.orange,
    this.emptyColor = Colors.grey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: index < rating ? filledColor : emptyColor.withOpacity(0.3),
          size: size,
        );
      }),
    );
  }
}