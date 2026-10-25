import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Palet & token desain Tapak.
/// Semua halaman wajib mengambil warna dari sini agar konsisten.
class AppColors {
  const AppColors._();

  static const Color primary = Color(0xFF2F6F5E);
  static const Color primaryContainer = Color(0xFFDCEAE4);
  static const Color secondary = Color(0xFFF2A65A);
  static const Color secondaryContainer = Color(0xFFFCEBD8);

  static const Color background = Color(0xFFF7F5F0);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFEDE9E1);
  static const Color outline = Color(0xFFDDD8CE);

  static const Color ink = Color(0xFF1E2A28);
  static const Color slate = Color(0xFF5C6B68);
  static const Color mist = Color(0xFF9AA5A2);

  static const Color success = Color(0xFF3F8F63);
  static const Color warning = Color(0xFFC0563F);

  static const ColorScheme scheme = ColorScheme(
    brightness: Brightness.light,
    primary: primary,
    onPrimary: Colors.white,
    primaryContainer: primaryContainer,
    onPrimaryContainer: Color(0xFF17342C),
    secondary: secondary,
    onSecondary: Color(0xFF3A2410),
    secondaryContainer: secondaryContainer,
    onSecondaryContainer: Color(0xFF4A2E14),
    error: warning,
    onError: Colors.white,
    surface: surface,
    onSurface: ink,
    onSurfaceVariant: slate,
    outline: outline,
    outlineVariant: outline,
    shadow: Color(0x0F1E2A28),
  );
}

/// Ritme 8pt: gunakan nilai-nilai ini, hindari angka acak.
class AppSpacing {
  const AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
}

class AppRadius {
  const AppRadius._();

  static const double chip = 12;
  static const double card = 16;
  static const double hero = 20;
  static const double header = 28;

  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(card));
  static const BorderRadius heroRadius = BorderRadius.all(Radius.circular(hero));
}

/// Tema global: tipografi, AppBar, navigasi, dan tombol.
ThemeData buildAppTheme() {
  final textTheme = TextTheme(
    displaySmall: GoogleFonts.plusJakartaSans(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      height: 1.25,
      letterSpacing: -0.5,
      color: AppColors.ink,
    ),
    headlineMedium: GoogleFonts.plusJakartaSans(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      height: 1.30,
      letterSpacing: -0.3,
      color: AppColors.ink,
    ),
    titleLarge: GoogleFonts.plusJakartaSans(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      height: 1.35,
      letterSpacing: -0.2,
      color: AppColors.ink,
    ),
    titleMedium: GoogleFonts.plusJakartaSans(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.40,
      color: AppColors.ink,
    ),
    bodyLarge: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.55,
      color: AppColors.ink,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.55,
      color: AppColors.slate,
    ),
    labelLarge: GoogleFonts.plusJakartaSans(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.20,
      letterSpacing: 0.2,
      color: AppColors.ink,
    ),
    labelMedium: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      height: 1.20,
      letterSpacing: 0.3,
      color: AppColors.slate,
    ),
    bodySmall: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.40,
      letterSpacing: 0.2,
      color: AppColors.slate,
    ),
    labelSmall: GoogleFonts.inter(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      height: 1.20,
      letterSpacing: 1.2,
      color: AppColors.slate,
    ),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: AppColors.scheme,
    scaffoldBackgroundColor: AppColors.background,
    textTheme: textTheme,
    splashFactory: InkSparkle.splashFactory,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      iconTheme: const IconThemeData(color: AppColors.ink),
      titleTextStyle: textTheme.titleLarge,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      indicatorColor: AppColors.primaryContainer,
      height: 72,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      labelTextStyle: WidgetStatePropertyAll<TextStyle?>(
        textTheme.labelMedium,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        shape: const StadiumBorder(),
        textStyle: textTheme.labelLarge,
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.primaryContainer,
      side: const BorderSide(color: AppColors.outline),
      labelStyle: textTheme.labelMedium,
      shape: const StadiumBorder(),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.surfaceVariant,
      thickness: 1,
      space: 1,
    ),
  );
}
