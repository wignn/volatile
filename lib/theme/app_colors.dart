import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFF6C5CE7);
  static const Color primaryLight = Color(0xFFA29BFE);
  static const Color primaryDark = Color(0xFF5849BE);

  // Secondary Colors
  static const Color secondary = Color(0xFF00D9FF);
  static const Color secondaryLight = Color(0xFF74F3FF);
  static const Color secondaryDark = Color(0xFF00A8CB);

  // Semantic Colors
  static const Color success = Color(0xFF00B894);
  static const Color warning = Color(0xFFFDAB3D);
  static const Color error = Color(0xFFE74C3C);
  static const Color info = Color(0xFF3498DB);

  // Income/Expense Colors
  static const Color income = Color(0xFF00B894);
  static const Color expense = Color(0xFFE74C3C);

  // Light Theme Colors
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF2D3436);
  static const Color lightTextSecondary = Color(0xFF636E72);
  static const Color lightBorder = Color(0xFFDFE6E9);

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF11111B);
  static const Color darkSurface = Color(0xFF1E1E2E);
  static const Color darkSurfaceLight = Color(0xFF2A2A3E);
  static const Color darkText = Color(0xFFF5F5F5);
  static const Color darkTextSecondary = Color(0xFFA0A0B0);
  static const Color darkBorder = Color(0xFF3A3A4E);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF8B7CF7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient incomeGradient = LinearGradient(
    colors: [success, Color(0xFF55EFC4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient expenseGradient = LinearGradient(
    colors: [error, Color(0xFFFF7675)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Category Colors
  static const List<Color> categoryColors = [
    Color(0xFF6C5CE7), // Purple
    Color(0xFF00B894), // Green
    Color(0xFFE74C3C), // Red
    Color(0xFF3498DB), // Blue
    Color(0xFFFDAB3D), // Orange
    Color(0xFF9B59B6), // Violet
    Color(0xFF1ABC9C), // Teal
    Color(0xFFE91E63), // Pink
    Color(0xFF00BCD4), // Cyan
    Color(0xFF795548), // Brown
  ];
}
