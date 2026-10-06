import 'package:flutter/material.dart';

class AppColors {
  // Primary Gold Color
  static const Color gold = Color(0xFFD4AF37);
  static const Color goldDark = Color(0xFFB8941F);
  static const Color goldLight = Color(0xFFE8D4A0);

  // Background Colors - Light Theme
  static const Color bgPrimaryLight = Color(0xFFFAF7F0);
  static const Color bgSecondaryLight = Color(0xFFFFFFFF);
  static const Color bgCardLight = Color(0xFFFEFDFB);

  // Background Colors - Dark Theme
  static const Color bgPrimaryDark = Color(0xFF1A1A1A);
  static const Color bgSecondaryDark = Color(0xFF242424);
  static const Color bgCardDark = Color(0xFF2A2A2A);

  // Text Colors - Light Theme
  static const Color textPrimaryLight = Color(0xFF2C2416);
  static const Color textSecondaryLight = Color(0xFF6B5D42);
  static const Color textTertiaryLight = Color(0xFF9B8B6B);

  // Text Colors - Dark Theme
  static const Color textPrimaryDark = Color(0xFFF5F5F5);
  static const Color textSecondaryDark = Color(0xFFD0D0D0);
  static const Color textTertiaryDark = Color(0xFFA0A0A0);

  // Accent Colors
  static const Color accentGreen = Color(0xFF0F4C3A);
  static const Color accentBlue = Color(0xFF1B3A4B);

  // Border Colors
  static const Color borderLight = Color(0xFFE8DCC4);
  static const Color borderDark = Color(0xFF3A3A3A);
}

class AppTextStyles {
  // Arabic Text Styles
  static const TextStyle arabicLarge = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    height: 1.8,
  );

  static const TextStyle arabicMedium = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.8,
  );

  static const TextStyle arabicSmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.8,
  );

  // Transliteration
  static const TextStyle transliteration = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  // Meaning
  static const TextStyle meaning = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.gold,
  );

  // Explanation
  static const TextStyle explanation = TextStyle(fontSize: 14, height: 1.7);

  // Heading
  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  // Body
  static const TextStyle bodyLarge = TextStyle(fontSize: 18);

  static const TextStyle bodyMedium = TextStyle(fontSize: 16);

  static const TextStyle bodySmall = TextStyle(fontSize: 14);
}

class AppSizes {
  static const double paddingXS = 4.0;
  static const double paddingSM = 8.0;
  static const double paddingMD = 16.0;
  static const double paddingLG = 24.0;
  static const double paddingXL = 32.0;
  static const double padding2XL = 48.0;
  static const double padding3XL = 64.0;

  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusFull = 9999.0;
}
