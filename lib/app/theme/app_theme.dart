import 'package:flutter/material.dart';

ThemeData buildLightAppTheme() {
  const canvas = Color(0xFFF2F2F7);
  const surface = Color(0xFFFFFFFF);
  const deepInk = Color(0xFF111111);
  const primary = Color(0xFF007AFF);
  const tertiary = Color(0xFFFF9F0A);
  const outline = Color(0xFFD1D1D6);
  const mutedText = Color(0xFF8E8E93);

  return _buildAppTheme(
    brightness: Brightness.light,
    seedColor: primary,
    scaffoldBackgroundColor: canvas,
    surfaceColor: surface,
    primaryColor: primary,
    tertiaryColor: tertiary,
    onSurfaceColor: deepInk,
    onSurfaceVariantColor: mutedText,
    outlineColor: outline,
    mutedTextColor: mutedText,
    surfaceContainerLow: const Color(0xFFFFFFFF),
    appBarBackgroundColor: Colors.transparent,
    appBarForegroundColor: deepInk,
    cardShadowColor: Colors.black.withValues(alpha: 0.03),
    searchShadowColor: Colors.black.withValues(alpha: 0.04),
  );
}

ThemeData buildDarkAppTheme() {
  const canvas = Color(0xFF101417);
  const surface = Color(0xFF171C1F);
  const primary = Color(0xFFBFE4EC);
  const tertiary = Color(0xFFFFC56B);
  const onSurface = Color(0xFFF3F7F8);
  const outline = Color(0xFF314046);
  const mutedText = Color(0xFFD2DDE0);

  return _buildAppTheme(
    brightness: Brightness.dark,
    seedColor: primary,
    scaffoldBackgroundColor: canvas,
    surfaceColor: surface,
    primaryColor: primary,
    tertiaryColor: tertiary,
    onSurfaceColor: onSurface,
    onSurfaceVariantColor: mutedText,
    outlineColor: outline,
    mutedTextColor: mutedText,
    surfaceContainerLow: const Color(0xFF1D2529),
    appBarBackgroundColor: surface,
    appBarForegroundColor: onSurface,
    cardShadowColor: Colors.black.withValues(alpha: 0.24),
    searchShadowColor: Colors.black.withValues(alpha: 0.28),
  );
}

ThemeData buildAmoledAppTheme() {
  const black = Color(0xFF000000);
  const primary = Color(0xFFA9D8FF);
  const tertiary = Color(0xFFFFC777);
  const onSurface = Color(0xFFF9F9F9);
  const outline = Color(0xFF2C2C2C);
  const mutedText = Color(0xFFD0D0D0);

  return _buildAppTheme(
    brightness: Brightness.dark,
    seedColor: primary,
    scaffoldBackgroundColor: black,
    surfaceColor: black,
    primaryColor: primary,
    tertiaryColor: tertiary,
    onSurfaceColor: onSurface,
    onSurfaceVariantColor: mutedText,
    outlineColor: outline,
    mutedTextColor: mutedText,
    surfaceContainerLow: black,
    appBarBackgroundColor: black,
    appBarForegroundColor: onSurface,
    cardShadowColor: Colors.transparent,
    searchShadowColor: Colors.transparent,
  );
}

ThemeData _buildAppTheme({
  required Brightness brightness,
  required Color seedColor,
  required Color scaffoldBackgroundColor,
  required Color surfaceColor,
  required Color primaryColor,
  required Color tertiaryColor,
  required Color onSurfaceColor,
  required Color onSurfaceVariantColor,
  required Color outlineColor,
  required Color mutedTextColor,
  required Color surfaceContainerLow,
  required Color appBarBackgroundColor,
  required Color appBarForegroundColor,
  required Color cardShadowColor,
  required Color searchShadowColor,
}) {
  final colorScheme =
      ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: brightness,
      ).copyWith(
        primary: primaryColor,
        tertiary: tertiaryColor,
        surface: surfaceColor,
        onSurface: onSurfaceColor,
        onSurfaceVariant: onSurfaceVariantColor,
        onPrimary: brightness == Brightness.dark ? Colors.black : Colors.white,
        outline: outlineColor,
        outlineVariant: outlineColor,
        surfaceContainerLowest: surfaceColor,
        surfaceContainerLow: surfaceContainerLow,
      );

  final baseTheme = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colorScheme,
  );
  final textTheme = baseTheme.textTheme.copyWith(
    titleLarge: baseTheme.textTheme.titleLarge?.copyWith(
      color: onSurfaceColor,
      fontWeight: FontWeight.w700,
    ),
    titleMedium: baseTheme.textTheme.titleMedium?.copyWith(
      color: onSurfaceColor,
      fontWeight: FontWeight.w700,
    ),
    bodyLarge: baseTheme.textTheme.bodyLarge?.copyWith(color: onSurfaceColor),
    bodyMedium: baseTheme.textTheme.bodyMedium?.copyWith(
      color: onSurfaceVariantColor,
    ),
    bodySmall: baseTheme.textTheme.bodySmall?.copyWith(
      color: onSurfaceVariantColor,
    ),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    scaffoldBackgroundColor: scaffoldBackgroundColor,
    colorScheme: colorScheme,
    textTheme: textTheme,
    primaryTextTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: appBarBackgroundColor,
      foregroundColor: appBarForegroundColor,
      surfaceTintColor: Colors.transparent,
      iconTheme: IconThemeData(color: appBarForegroundColor),
      actionsIconTheme: IconThemeData(color: appBarForegroundColor),
    ),
    cardTheme: CardThemeData(
      elevation: brightness == Brightness.light ? 2 : 0,
      margin: EdgeInsets.zero,
      color: surfaceColor,
      shadowColor: cardShadowColor,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: outlineColor),
      ),
    ),
    dividerTheme: DividerThemeData(color: outlineColor),
    iconTheme: IconThemeData(color: onSurfaceColor),
    listTileTheme: ListTileThemeData(
      iconColor: onSurfaceVariantColor,
      textColor: onSurfaceColor,
      titleTextStyle: textTheme.titleMedium,
      subtitleTextStyle: textTheme.bodyMedium,
    ),
    searchBarTheme: SearchBarThemeData(
      elevation: WidgetStatePropertyAll(brightness == Brightness.light ? 3 : 0),
      backgroundColor: WidgetStatePropertyAll(surfaceColor),
      surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
      shadowColor: WidgetStatePropertyAll(searchShadowColor),
      side: WidgetStatePropertyAll(BorderSide(color: outlineColor)),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 16),
      ),
      textStyle: WidgetStatePropertyAll(
        TextStyle(
          color: onSurfaceColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      hintStyle: WidgetStatePropertyAll(
        TextStyle(
          color: mutedTextColor,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: primaryColor.withValues(
        alpha: brightness == Brightness.light ? 0.07 : 0.16,
      ),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      labelStyle: TextStyle(color: onSurfaceColor),
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: outlineColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: outlineColor),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
      ),
      menuStyle: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(surfaceColor),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        side: WidgetStatePropertyAll(BorderSide(color: outlineColor)),
      ),
      textStyle: TextStyle(color: onSurfaceColor),
    ),
  );
}
