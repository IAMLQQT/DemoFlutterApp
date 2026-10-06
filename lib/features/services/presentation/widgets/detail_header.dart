import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';


class DetailHeader extends StatelessWidget {
  const DetailHeader({super.key, required this.bannerUrl, required this.title});

  final String bannerUrl;
  final String title;

  static const double _overlap =
      32; // how much the title card covers the banner

  @override
  Widget build(BuildContext context) {
    final double safeTop = MediaQuery.paddingOf(context)
        .top; // status bar height
    final double bannerHeight =
        MediaQuery.sizeOf(context).width * 0.56 + safeTop;

    return ColoredBox(
      color:
          AppColors.background, // light-blue band behind the card's lower half
      child: Stack(
        children: [
          // [1] Banner — bottom layer
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: bannerHeight,
            child: CachedNetworkImage(imageUrl: bannerUrl, fit: BoxFit.cover),
          ),

          // [2] Title card — NOT positioned, so it decides the Stack's height
          Padding(
            padding: EdgeInsets.fromLTRB(32, bannerHeight - _overlap, 32, 20),
            child: _TitleCard(title: title),
          ),

          // [3] Back button — top layer
          Positioned(
            top: safeTop + 8,
            left: 16,
            child: const _CircleBackButton(),
          ),
        ],
      ),
    );
  }
}

class _TitleCard extends StatelessWidget {
  const _TitleCard({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: AppTextStyles.detailTitle,
      ),
    );
  }
}

class _CircleBackButton extends StatelessWidget {
  const _CircleBackButton();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(),
      elevation: 2,
      child: IconButton(
        icon: const Icon(
          Icons.chevron_left,
          color: AppColors.primary,
          size: 30,
        ),
        onPressed: () => context.pop(),
      ),
    );
  }
}
