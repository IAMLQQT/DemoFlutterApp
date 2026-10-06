import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Placeholder / error box for network images, so a broken URL never leaves a blank hole.
class ImageErrorBox extends StatelessWidget {
  const ImageErrorBox({super.key, this.loading = false});

  final bool loading;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: loading
          ? const SizedBox.expand()
          : const Center(
              child: Icon(Icons.broken_image_outlined, color: AppColors.textSecondary),
            ),
    );
  }
}
