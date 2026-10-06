import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/service_item.dart';

class ServiceCard extends StatelessWidget {
  const ServiceCard({super.key, required this.service, required this.onTap});

  final ServiceItem service;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect (
                borderRadius: BorderRadius.circular(8),
                child: AspectRatio(
                  aspectRatio: 16/10,
                  child: CachedNetworkImage(
                    imageUrl: service.thumbnailUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const ColoredBox(color: AppColors.background),
                    errorWidget: (context, url, error) => const Icon(Icons.broken_image_outlined),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Padding (padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  service.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.cardTitle,
                ),
              )
            ],  
          )
        )
    )
    );
}
}