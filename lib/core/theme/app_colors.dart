import 'package:flutter/material.dart';

abstract class AppColors {
  //Brand
  static const Color primary = Color(0xFF2B3A9E);
  static const Color primaryLight = Color(0xFF3F5BD9);
  static const Color primaryDark = Color(0xFF1E2A8A);
  static const Color gold = Color(0xFFE8A33C); 

  //Surfaces
  static const Color background = Color(0xFFF1F3FB);
  static const Color surface = Colors.white;

  //Text 
  static const Color textPrimary = Color(0xFF1F1F1F);
  static const Color textSecondary = Color(0xFF4A4A4A);

  //Booking button gradient
  static const LinearGradient bookingButtonGradient = LinearGradient(
    colors: [primaryLight, primaryDark],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}