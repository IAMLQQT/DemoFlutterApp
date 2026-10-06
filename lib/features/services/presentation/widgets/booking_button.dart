import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class BookingButton extends StatelessWidget {
  const BookingButton({super.key, required this.onPressed, this.label = 'Đặt lịch'});

  final VoidCallback onPressed;
  final String label;

  static final BorderRadius _radius = BorderRadius.circular(32);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppColors.bookingButtonGradient,
        borderRadius: _radius,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        type: MaterialType
            .transparency, // lets the gradient show through, keeps the ripple
        child: InkWell(
          borderRadius: _radius,
          onTap: onPressed,
          child: const SizedBox(
            height: 60,
            width: double.infinity,
            child: Center(child: Text('Đặt lịch', style: AppTextStyles.button)),
          ),
        ),
      ),
    );
  }
}
