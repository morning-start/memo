import 'package:flutter/material.dart';

/// Memo 应用主题定义
///
/// 设计理念："温暖的私人备忘录"
/// 暖色调的大地色系，营造安心、有序的私人空间感。
/// 灵感来自皮质手账本的质感 —— 温暖、可靠、经得起时间。
abstract final class AppColors {
  // ── 亮色主题 ──────────────────────────────────────
  static const Color primary = Color(0xFF8B5E3C); // 温暖的棕色（皮质手账）
  static const Color primaryLight = Color(0xFFB07D5A); // 浅棕
  static const Color primaryDark = Color(0xFF6B4226); // 深棕
  static const Color accent = Color(0xFFE07A5F); // 赤陶色（强调/行动按钮）

  static const Color surface = Color(0xFFFFF8F0); // 温暖的象牙白
  static const Color surfaceAlt = Color(0xFFF5EDE3); // 浅米色（卡片/分组背景）
  static const Color surfaceBright = Color(0xFFFFFFFF); // 纯白

  static const Color overdue = Color(0xFFC0392B); // 深红（已逾期）
  static const Color dueSoon = Color(0xFFD4803A); // 琥珀色（即将到期）
  static const Color healthy = Color(0xFF5B8C5A); // 苔藓绿（进行中/正常）
  static const Color paused = Color(0xFF9E9E9E); // 中性灰（暂停）

  static const Color textPrimary = Color(0xFF2C1810); // 深棕近黑
  static const Color textSecondary = Color(0xFF8C7A6B); // 温暖灰棕
  static const Color textTertiary = Color(0xFFB5A99A); // 浅灰棕
  static const Color divider = Color(0xFFE8DFD4); // 温暖分割线

  // ── 深色主题 ──────────────────────────────────────
  static const Color darkSurface = Color(0xFF1A1412); // 深炭色
  static const Color darkSurfaceAlt = Color(0xFF2A2220); // 深色卡片背景
  static const Color darkSurfaceBright = Color(0xFF342A26); // 浅一层深色
  static const Color darkPrimary = Color(0xFFD4A574); // 暖金色（深色主题主色）
  static const Color darkAccent = Color(0xFFE8956A); // 亮赤陶
  static const Color darkTextPrimary = Color(0xFFF5EDE3); // 暖白
  static const Color darkTextSecondary = Color(0xFFB5A99A); // 暖灰
  static const Color darkDivider = Color(0xFF3E3430); // 深色分割线

  // ── 统一语义色（在页面中按 RoutineStatus 使用） ──────
  // overdue  → AppColors.overdue
  // dueSoon  → AppColors.dueSoon
  // normal   → AppColors.primary / AppColors.darkPrimary
}

/// 排版常量
abstract final class AppTypography {
  static const String _fontFamily = 'Noto Sans SC';

  /// 大标题（页面标题）
  static TextStyle displayLarge(bool isDark) => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 26,
        fontWeight: FontWeight.w700,
        height: 1.3,
        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
        letterSpacing: -0.5,
      );

  /// 区域标题
  static TextStyle titleLarge(bool isDark) => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        height: 1.35,
        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
      );

  /// 卡片标题 / 列表主标题
  static TextStyle titleMedium(bool isDark) => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
      );

  /// 正文
  static TextStyle bodyLarge(bool isDark) => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
      );

  /// 副正文
  static TextStyle bodyMedium(bool isDark) => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color:
            isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
      );

  /// 标签 / 芯片文字
  static TextStyle labelLarge(bool isDark) => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: 1.4,
        letterSpacing: 0.2,
        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
      );

  /// 小标签
  static TextStyle labelSmall(bool isDark) => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 1.4,
        color:
            isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
      );
}

/// 间距常量
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 28;
  static const double xxxl = 36;
}

/// 圆角常量
abstract final class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double pill = 100;
}

/// 构建亮色 ThemeData
ThemeData buildLightTheme() {
  const cs = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: Colors.white,
    primaryContainer: AppColors.surfaceAlt,
    onPrimaryContainer: AppColors.primaryDark,
    secondary: AppColors.accent,
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFFFE0D3),
    onSecondaryContainer: AppColors.primaryDark,
    error: AppColors.overdue,
    onError: Colors.white,
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    surfaceContainerHighest: AppColors.surfaceAlt,
    surfaceContainerHigh: AppColors.surfaceBright,
    outline: AppColors.divider,
    outlineVariant: AppColors.divider,
  );

  return _buildTheme(cs, isDark: false);
}

/// 构建深色 ThemeData
ThemeData buildDarkTheme() {
  const cs = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.darkPrimary,
    onPrimary: AppColors.darkSurface,
    primaryContainer: AppColors.darkSurfaceAlt,
    onPrimaryContainer: AppColors.darkTextPrimary,
    secondary: AppColors.darkAccent,
    onSecondary: AppColors.darkSurface,
    secondaryContainer: Color(0xFF4A3228),
    onSecondaryContainer: AppColors.darkTextPrimary,
    error: Color(0xFFE57373),
    onError: AppColors.darkSurface,
    surface: AppColors.darkSurface,
    onSurface: AppColors.darkTextPrimary,
    surfaceContainerHighest: AppColors.darkSurfaceAlt,
    surfaceContainerHigh: AppColors.darkSurfaceBright,
    outline: AppColors.darkDivider,
    outlineVariant: AppColors.darkDivider,
  );

  return _buildTheme(cs, isDark: true);
}

ThemeData _buildTheme(ColorScheme cs, {required bool isDark}) {
  final textTheme = TextTheme(
    displayLarge: AppTypography.displayLarge(isDark),
    headlineSmall: AppTypography.titleLarge(isDark),
    titleLarge: AppTypography.titleLarge(isDark),
    titleMedium: AppTypography.titleMedium(isDark),
    bodyLarge: AppTypography.bodyLarge(isDark),
    bodyMedium: AppTypography.bodyMedium(isDark),
    bodySmall: AppTypography.bodyMedium(isDark),
    labelLarge: AppTypography.labelLarge(isDark),
    labelSmall: AppTypography.labelSmall(isDark),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: cs,
    textTheme: textTheme,
    scaffoldBackgroundColor: cs.surface,
    fontFamily: AppTypography._fontFamily,

    // ── AppBar ──
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      centerTitle: false,
      titleTextStyle: AppTypography.titleLarge(isDark),
      iconTheme: IconThemeData(color: cs.onSurface),
    ),

    // ── BottomNavigationBar ──
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: isDark ? AppColors.darkSurfaceBright : AppColors.surfaceBright,
      selectedItemColor: cs.primary,
      unselectedItemColor:
          isDark ? AppColors.darkTextSecondary : AppColors.textTertiary,
      selectedLabelStyle: AppTypography.labelSmall(isDark).copyWith(
        fontWeight: FontWeight.w700,
      ),
      unselectedLabelStyle: AppTypography.labelSmall(isDark),
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      showUnselectedLabels: true,
    ),

    // ── Card ──
    cardTheme: CardThemeData(
      color: isDark ? AppColors.darkSurfaceAlt : AppColors.surfaceBright,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(
          color: isDark ? AppColors.darkDivider : AppColors.divider,
          width: 0.5,
        ),
      ),
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
    ),

    // ── Dialog ──
    dialogTheme: DialogThemeData(
      backgroundColor: isDark ? AppColors.darkSurfaceBright : AppColors.surfaceBright,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      titleTextStyle: AppTypography.titleLarge(isDark),
      contentTextStyle: AppTypography.bodyLarge(isDark),
    ),

    // ── ListTile ──
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      titleTextStyle: AppTypography.titleMedium(isDark),
      subtitleTextStyle: AppTypography.bodyMedium(isDark),
      iconColor: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
    ),

    // ── TabBar ──
    tabBarTheme: TabBarThemeData(
      labelColor: cs.primary,
      unselectedLabelColor:
          isDark ? AppColors.darkTextSecondary : AppColors.textTertiary,
      labelStyle: AppTypography.labelLarge(isDark),
      unselectedLabelStyle:
          AppTypography.labelLarge(isDark).copyWith(fontWeight: FontWeight.w400),
      indicatorColor: cs.primary,
      indicatorSize: TabBarIndicatorSize.label,
      dividerColor: Colors.transparent,
    ),

    // ── FAB ──
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: cs.secondary,
      foregroundColor: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      extendedTextStyle: AppTypography.labelLarge(isDark).copyWith(
        color: Colors.white,
      ),
    ),

    // ── Chip ──
    chipTheme: ChipThemeData(
      backgroundColor:
          isDark ? AppColors.darkSurfaceAlt : AppColors.surfaceAlt,
      selectedColor: cs.primary.withOpacity(0.15),
      labelStyle: AppTypography.labelLarge(isDark),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        side: BorderSide(
          color: isDark ? AppColors.darkDivider : AppColors.divider,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    ),

    // ── Input (TextField) ──
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: isDark ? AppColors.darkSurfaceAlt : AppColors.surfaceAlt,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: BorderSide(
          color: isDark ? AppColors.darkDivider : AppColors.divider,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: BorderSide(
          color: isDark ? AppColors.darkDivider : AppColors.divider,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: BorderSide(color: cs.primary, width: 1.5),
      ),
      labelStyle: AppTypography.bodyMedium(isDark),
      hintStyle: AppTypography.bodyMedium(isDark).copyWith(
        color: isDark ? AppColors.darkTextSecondary : AppColors.textTertiary,
      ),
    ),

    // ── ElevatedButton ──
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: cs.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        textStyle: AppTypography.labelLarge(isDark).copyWith(
          color: Colors.white,
        ),
      ),
    ),

    // ── FilledButton ──
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: cs.secondary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        textStyle: AppTypography.labelLarge(isDark).copyWith(
          color: Colors.white,
        ),
      ),
    ),

    // ── TextButton ──
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: cs.primary,
        textStyle: AppTypography.labelLarge(isDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      ),
    ),

    // ── Divider ──
    dividerTheme: DividerThemeData(
      color: isDark ? AppColors.darkDivider : AppColors.divider,
      thickness: 0.5,
      space: 0,
    ),

    // ── Snackbar ──
    snackBarTheme: SnackBarThemeData(
      backgroundColor:
          isDark ? AppColors.darkSurfaceBright : AppColors.primaryDark,
      contentTextStyle: AppTypography.bodyMedium(isDark).copyWith(
        color: Colors.white,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      behavior: SnackBarBehavior.floating,
    ),

    // ── PopupMenu ──
    popupMenuTheme: PopupMenuThemeData(
      color: isDark ? AppColors.darkSurfaceBright : AppColors.surfaceBright,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      textStyle: AppTypography.bodyLarge(isDark),
    ),

    // ── BottomSheet ──
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor:
          isDark ? AppColors.darkSurfaceBright : AppColors.surfaceBright,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.lg),
        ),
      ),
      elevation: 8,
    ),

    // ── ExpansionTile ──
    expansionTileTheme: ExpansionTileThemeData(
      backgroundColor: Colors.transparent,
      collapsedBackgroundColor: Colors.transparent,
      shape: Border.all(color: Colors.transparent),
      collapsedShape: Border.all(color: Colors.transparent),
    ),
  );
}
