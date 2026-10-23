import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors (Navy Palette)
  static const Color navyPrimary = Color(0xFF0D1B2A);
  static const Color navySecondary = Color(0xFF1B263B);
  static const Color navyDark = Color(0xFF0A1118);
  static const Color navyMuted = Color(0xFF415A77); // Fixes analytics Ln 420
  static const Color navyLight = Color(0xFF778DA9);
  static const Color primary = navyPrimary;

  // Accent Colors (Teal Palette)
  static const Color tealAccent = Color(0xFF00B4D8);
  static const Color tealSecondary = Color(0xFF90E0EF);
  static const Color tealDark = Color(0xFF0077B6);
  static const Color tealContainer = Color(0xFFE0F7FA);
  static const Color tealMuted = Color(0xFF80CED7);
  static const Color accent = tealAccent;

  // Platform Colors
  static const Color shopeeOrange = Color(0xFFEE4D2D);
  static const Color shopeeContainer = Color(0xFFFBE9E7);
  static const Color lazadaBlue = Color(0xFF0F146D);
  static const Color lazadaContainer = Color(0xFFE8EAF6);
  static const Color tikTokBlack = Color(0xFF010101);
  static const Color tikTokContainer = Color(0xFFF1F1F2);
  static const Color tiktokBlack = Color(0xFF010101);
  static const Color tiktokContainer = Color(0xFFF1F1F2);
  static const Color tikTokRed = Color(0xFFFE2C55);
  static const Color tikTokCyan = Color(0xFF25F4EE);

  // Parcel & Flow Status Colors (Fixes app_theme, analytics, dispatch, & parcel_detail)
  static const Color statusDelivered = Color(0xFF2B9348);
  static const Color statusDeliveredContainer = Color(0xFFE8F5E9);
  static const Color statusReturned = Color(0xFFD90429);
  static const Color statusReturnedContainer = Color(0xFFFFEBEE);
  static const Color statusPending = Color(0xFFFFB703);
  static const Color statusPendingContainer = Color(0xFFFFF3CD);
  static const Color statusInTransit = Color(0xFF0077B6);
  static const Color statusInTransitContainer = Color(0xFFE0F2FE);
  static const Color statusDispatched = Color(0xFF00B4D8);
  static const Color statusDispatchedContainer = Color(0xFFE0F7FA);
  static const Color statusCancelled = Color(0xFF6C757D);
  static const Color statusCancelledContainer = Color(0xFFE9ECEF);
  static const Color statusApproved = Color(0xFF2B9348);
  static const Color statusReplacementDispatched = Color(0xFF7209B7);
  static const Color statusRefunded = Color(0xFF6A4C93);
  static const Color statusRejected = Color(0xFFD90429);
  static const Color statusProcessing = Color(0xFF0077B6);
  static const Color statusFailed = Color(0xFFD90429);

  // Neutral Backgrounds & Surfaces
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color surfaceWhite = Colors.white;
  static const Color surfaceMuted = Color(0xFFF1F3F5);
  static const Color surfaceVariant = Color(0xFFE9ECEF);
  static const Color background = backgroundLight;
  static const Color surface = surfaceWhite;

  // Text Colors
  static const Color textPrimary = Color(0xFF212529);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textMuted = Color(0xFFADB5BD);

  // Border & Divider Colors
  static const Color borderSubtle = Color(0xFFE9ECEF);
  static const Color borderLight = Color(0xFFDEE2E6);
  static const Color border = borderSubtle;

  // Semantic Status Colors
  static const Color successGreen = Color(0xFF2B9348);
  static const Color errorRed = Color(0xFFD90429);
  static const Color warningOrange = Color(0xFFF77F00);
  static const Color infoBlue = Color(0xFF0077B6);
  static const Color error = errorRed;
  static const Color success = successGreen;
  static const Color warning = warningOrange;
  static const Color info = infoBlue;
}