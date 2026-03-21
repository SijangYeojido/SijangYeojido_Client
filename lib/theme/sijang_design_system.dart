import 'dart:ui';
import 'package:flutter/material.dart';
import 'app_colors.dart';

/// SDS (Sijang Design System) v8
/// 
/// 앱 전체의 일관된 고품격 미학을 유지하기 위한 통합 디자인 시스템 토큰입니다.
class SDS {
  // --- Blur Filters (V8 Cinematic) ---
  static final blurSubtle = ImageFilter.blur(sigmaX: 10, sigmaY: 10);
  static final blurNormal = ImageFilter.blur(sigmaX: 20, sigmaY: 20);
  static final blurHeavy = ImageFilter.blur(sigmaX: 40, sigmaY: 40);

  // --- Border Radius ---
  // --- Border Radius ---
  static const double radiusS = 12.0;
  static const double radiusM = 20.0;
  static const double radiusL = 28.0; // Optimized for Premium Cards
  static const double radiusXL = 40.0;
  static const double radiusEpic = 64.0;
  static const double radiusCapsule = 100.0;

  // --- Spacing (TDS Aligned) ---
  static const double gutter = 20.0;
  static const double space2 = 2.0;
  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space18 = 18.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
  static const double space40 = 40.0;
  static const double space48 = 48.0;
  static const double space64 = 64.0;

  // Legacy Spacing Aliases
  static const double spaceXS = space4;
  static const double spaceS = space8;
  static const double spaceM = space16;
  static const double spaceL = space24;
  static const double spaceXL = space40;

  // --- Shadows (Cinematic Depth V8) ---
  static List<BoxShadow> shadowSoft = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> shadowPremium = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.12),
      blurRadius: 40,
      offset: const Offset(0, 20),
      spreadRadius: -4,
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.03),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> shadowEpic = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.2),
      blurRadius: 60,
      offset: const Offset(0, 32),
      spreadRadius: -12,
    ),
  ];

  static List<BoxShadow> shadowAccent(Color accent) => [
    BoxShadow(
      color: accent.withValues(alpha: 0.15),
      blurRadius: 40,
      offset: const Offset(0, 16),
      spreadRadius: -4,
    ),
  ];

  // --- Glassmorphism v2 ---
  static BoxDecoration glassDecoration({
    double opacity = 0.65,
    double blur = 32.0,
    double radius = radiusM,
    Color? color,
    Color? border,
  }) {
    return BoxDecoration(
      color: (color ?? Colors.white).withValues(alpha: opacity),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: border ?? Colors.white.withValues(alpha: 0.25),
        width: 1.2,
      ),
    );
  }

  // --- Animation Settings ---
  static const Duration durationFast = Duration(milliseconds: 240);
  static const Duration durationNormal = Duration(milliseconds: 400);
  static const Duration durationSlow = Duration(milliseconds: 800);
  
  static const Curve curveStandard = Curves.easeInOutCubic;
  static const Curve curveEntrance = Curves.easeOutQuart;
  static const Curve curveSpring = Curves.elasticOut;

  // --- Micro-Typography (V11) ---
  static const double lsTight = -0.8;
  static const double lsNormal = -0.5;
  static const double lsWide = 0.2;
  
  static const FontWeight fwLight = FontWeight.w300;
  static const FontWeight fwRegular = FontWeight.w400;
  static const FontWeight fwMedium = FontWeight.w500;
  static const FontWeight fwSemiBold = FontWeight.w600;
  static const FontWeight fwBold = FontWeight.w700;
  static const FontWeight fwExtraBold = FontWeight.w800;
  static const FontWeight fwBlack = FontWeight.w900;

  // --- Core Components (V8 Epic) ---

  /// Epic Card for cinematic store/item display
  static Widget epicCard({
    required Widget child,
    double? width,
    double? height,
    Color? color,
    EdgeInsets? padding,
    List<BoxShadow>? shadow,
    double radius = radiusL,
  }) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: shadow ?? shadowPremium,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: child,
      ),
    );
  }

  /// Premium Navigation Top Bar
  static Widget topBar({
    required BuildContext context,
    required String title,
    String? subtitle,
    Widget? leading,
    List<Widget>? actions,
    bool showBackButton = true,
  }) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 8, 20, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF2F4F6), width: 1)),
      ),
      child: Row(
        children: [
          if (showBackButton)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Color(0xFF191F28)),
              ),
            )
          else if (leading != null)
            Padding(padding: const EdgeInsets.only(right: 12), child: leading),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: fwBlack,
                    color: Color(0xFF191F28),
                    letterSpacing: lsTight,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: fwBold,
                      color: const Color(0xFF8B95A1),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (actions != null) ...actions,
        ],
      ),
    );
  }

  /// Standardized List Row for consistent item representation
  static Widget listRow({
    required Widget title,
    Widget? subtitle,
    Widget? leading,
    Widget? trailing,
    VoidCallback? onTap,
    EdgeInsets? padding,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            if (leading != null) ...[
              leading,
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  DefaultTextStyle(
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: fwBold,
                      color: const Color(0xFF191F28),
                      letterSpacing: lsNormal,
                    ),
                    child: title,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    DefaultTextStyle(
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: fwMedium,
                        color: const Color(0xFF4E5968),
                      ),
                      child: subtitle,
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 12),
              trailing,
            ],
          ],
        ),
      ),
    );
  }

  /// High-Fidelity Button with SDS styling
  static Widget button({
    required String label,
    required VoidCallback onTap,
    bool isPrimary = true,
    IconData? icon,
    Color? color,
    double? width,
  }) {
    final bgColor = color ?? (isPrimary ? AppColors.primary : const Color(0xFFF2F4F6));
    final textColor = isPrimary ? Colors.white : const Color(0xFF4E5968);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        decoration: BoxDecoration(
          color: color ?? (isPrimary ? null : const Color(0xFFF2F4F6)),
          gradient: isPrimary ? AppColors.primaryGradient : null,
          borderRadius: BorderRadius.circular(radiusM),
          boxShadow: isPrimary ? [
            BoxShadow(
              color: bgColor.withValues(alpha: 0.25),
              blurRadius: 20,
              offset: const Offset(0, 8),
            )
          ] : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20, color: textColor),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: fwBlack,
                color: textColor,
                letterSpacing: lsNormal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
