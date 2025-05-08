import 'package:flutter/material.dart';
import '../../ui/app_colors.dart';

class StarRatingWidget extends StatelessWidget {
  final int starCount = 5;
  final double starSize = 20;
  final double rating;

  const StarRatingWidget({
    super.key,
    this.rating = 0.0, // Default rating is 0
  });

  // Method to build each individual star based on the rating and index
  Widget buildStar(final BuildContext context, final int index) {
    Icon icon;
    // If the index is greater than or equal to the rating, we show an empty star
    if (index >= rating) {
      icon = Icon(
        Icons.star_border, // Empty star
        size: starSize,
        color: AppColors.secondaryContainerGray,
      );
    }
    // If the index is between the rating minus 1 and the rating, we show a half star
    else if (index > rating - 1 && index < rating) {
      icon = Icon(
        Icons.star_half,
        size: starSize,
        color: AppColors.ratingPrimaryColor,
      );
    }
    // Otherwise, we show a full star
    else {
      icon = Icon(
        Icons.star, // Full star
        size: starSize,
        color: AppColors.ratingPrimaryColor,
      );
    }
    return icon;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        starCount,
        (final index) => buildStar(context, index),
      ),
    );
  }
}
