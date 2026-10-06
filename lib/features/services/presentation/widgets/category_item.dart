import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/service_category.dart';

class CategoryItem extends StatelessWidget {
  const CategoryItem({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  final ServiceCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Hot category label stays gold even when another category is selected
    final Color labelColor = (isSelected || category.isHot)
        ? AppColors.gold
        : AppColors.textPrimary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque, // tap on empty space inside also counts
      child: SizedBox(
        width: 84,
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 60,
              height: 60,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.gold : Colors.transparent,
                  width: 2,
                ),
              ),
              child: ClipOval(child: _buildIcon()),
            ),
            const SizedBox(height: 8),
            Text(
              category.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.categoryLabel.copyWith(
                color: labelColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    // No icon from the API -> show the flame as a fallback
    if (category.iconUrl.isEmpty) {
      return ColoredBox(
        color: AppColors.gold.withValues(alpha: 0.15),
        child: const Icon(
          Icons.local_fire_department,
          color: AppColors.gold,
          size: 32,
        ),
      );
    }
    return CachedNetworkImage(
      imageUrl: category.iconUrl,
      fit: BoxFit.cover,
      errorWidget: (_, _, _) => const Icon(Icons.image_not_supported_outlined),
    );
  }
}
