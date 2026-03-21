import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';
import '../theme/app_colors.dart';
import '../theme/sijang_design_system.dart';
import 'shrinkable_button.dart';

/// SDS (Sijang Design System) Core Widgets
/// Highly refined, premium UI components following TDS patterns.

/// --- SDS List Row ---
/// A standardized row for lists with various padding and icon options.
class SDSListRow extends StatelessWidget {
  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showDivider;
  final double paddingLevel; // 1: S, 2: M, 3: L, 4: XL

  const SDSListRow({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.showDivider = false,
    this.paddingLevel = 2,
  });

  @override
  Widget build(BuildContext context) {
    double verticalPadding;
    switch (paddingLevel) {
      case 1: verticalPadding = 14.0; break; // S (approx 44-48dp total)
      case 3: verticalPadding = SDS.space24; break; // L
      case 4: verticalPadding = SDS.space32; break; // XL
      case 2:
      default: verticalPadding = SDS.space18; break; // M (More spacious)
    }

    final row = Container(
      padding: EdgeInsets.symmetric(horizontal: SDS.gutter, vertical: verticalPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: showDivider ? const Border(bottom: BorderSide(color: AppColors.divider, width: 0.8)) : null,
      ),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: SDS.space16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.4,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: SDS.space12),
            trailing!,
          ] else if (onTap != null) ...[
            const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary, size: 24),
          ],
        ],
      ),
    );

    if (onTap == null) return row;
    return ShrinkableButton(onTap: onTap, child: row);
  }
}

/// --- SDS Button ---
/// Premium button with scale animation and sophisticated gradients.
class SDSButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isPrimary;
  final IconData? icon;
  final Color? color;

  const SDSButton({
    super.key,
    required this.label,
    this.onTap,
    this.isPrimary = true,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = color ?? (isPrimary ? AppColors.primary : AppColors.background);
    final textColor = isPrimary ? Colors.white : AppColors.textPrimary;

    return ShrinkableButton(
      onTap: onTap,
      child: Container(
        height: 58,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isPrimary ? null : themeColor,
          gradient: isPrimary ? AppColors.primaryGradient : null,
          borderRadius: BorderRadius.circular(SDS.radiusM),
          boxShadow: isPrimary ? SDS.shadowAccent(AppColors.primary) : null,
          border: isPrimary ? null : Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20, color: textColor),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: textColor,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// --- SDS Top Bar (Immersive) ---
/// Transparent navigation bar with glassmorphism support.
class SDSTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  final bool showBackButton;
  final Color? backgroundColor;

  const SDSTopBar({
    super.key,
    this.title,
    this.actions,
    this.showBackButton = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          height: 56 + MediaQuery.of(context).padding.top,
          color: backgroundColor ?? AppColors.surface.withValues(alpha: 0.85),
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          child: Stack(
            children: [
              // --- Title ---
              if (title != null)
                Center(
                  child: Text(
                    title!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.4,
                    ),
                  ),
                ),

              // --- Content Row ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    if (showBackButton)
                      ShrinkableButton(
                        onTap: () => Navigator.maybePop(context),
                        child: const SizedBox(
                          width: 44,
                          height: 44,
                          child: Icon(Icons.arrow_back_ios_new_rounded,
                              size: 20, color: AppColors.textPrimary),
                        ),
                      ),
                    const Spacer(),
                    if (actions != null)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: actions!,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}

/// --- SDS Staggered Entrance Animation ---
class SDSFadeIn extends StatelessWidget {
  final Widget child;
  final Duration delay;
  final Offset offset;

  const SDSFadeIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.offset = const Offset(0, 30),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: SDS.durationNormal,
      curve: SDS.curveEntrance,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: offset * (1 - value),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// --- SDS Floating Tabbar ---
/// A premium, floating capsule-style tab bar following TDS guidelines.
class SDSFloatingTabbar extends StatelessWidget {
  final int currentIndex;
  final List<SDSFloatingTabItem> items;
  final Function(int) onTap;

  const SDSFloatingTabbar({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      height: 64,
      decoration: SDS.glassDecoration(
        radius: SDS.radiusCapsule,
        opacity: 0.92,
        blur: 24,
      ).copyWith(
        boxShadow: SDS.shadowPremium,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isSelected = currentIndex == index;

          return Expanded(
            child: ShrinkableButton(
              onTap: () => onTap(index),
              shrinkScale: 0.9,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedScale(
                    scale: isSelected ? 1.1 : 1.0,
                    duration: SDS.durationFast,
                    curve: Curves.easeOutBack,
                    child: Icon(
                      isSelected ? item.activeIcon : item.icon,
                      color: isSelected ? AppColors.primary : AppColors.textTertiary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedDefaultTextStyle(
                    duration: SDS.durationFast,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                      color: isSelected ? AppColors.primary : AppColors.textTertiary,
                      letterSpacing: -0.5,
                    ),
                    child: Text(item.label),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class SDSFloatingTabItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const SDSFloatingTabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

/// --- Premium Placeholder ---
/// A sophisticated placeholder for store images with category icons.
class PremiumPlaceholder extends StatelessWidget {
  final String category;
  final double width;
  final double height;
  final double borderRadius;

  const PremiumPlaceholder({
    super.key,
    required this.category,
    this.width = 48,
    this.height = 48,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Center(
        child: Icon(
          _iconForCategory(category),
          color: AppColors.primary,
          size: width * 0.5,
        ),
      ),
    );
  }

  IconData _iconForCategory(String category) {
    if (category.contains('먹거리')) return Icons.restaurant_rounded;
    if (category.contains('수산')) return Icons.set_meal_rounded;
    if (category.contains('정육')) return Icons.kebab_dining_rounded;
    if (category.contains('과일') || category.contains('채소')) return Icons.eco_rounded;
    return Icons.storefront_rounded;
  }
}

/// --- SDS Step Bar ---
/// A minimalist linear progress indicator for multi-step flows.
class SDSStepBar extends StatelessWidget {
  final int totalSteps;
  final int currentStep;
  final Color? color;

  const SDSStepBar({
    super.key,
    required this.totalSteps,
    required this.currentStep,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 3,
      width: double.infinity,
      color: AppColors.border.withValues(alpha: 0.3),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: (currentStep + 1) / totalSteps,
        child: Container(
          color: color ?? AppColors.primary,
        ),
      ),
    );
  }
}

/// --- SDS Sticky Button ---
/// A full-width button that sticks to the bottom with safe area support.
class SDSStickyButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isEnabled;
  final bool isLoading;

  const SDSStickyButton({
    super.key,
    required this.label,
    this.onTap,
    this.isEnabled = true,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPadding > 0 ? bottomPadding : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border.withValues(alpha: 0.5), width: 0.5)),
      ),
      child: ShrinkableButton(
        onTap: isEnabled && !isLoading ? onTap : null,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: isEnabled ? AppColors.primary : AppColors.border.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(SDS.radiusM),
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                  )
                : Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: SDS.fwBlack,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

/// --- SDS Glass Container ---
/// A reusable glassmorphism container for premium overlays.
class SDSGlass extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final double radius;
  final EdgeInsets? padding;
  final Color? color;

  const SDSGlass({
    super.key,
    required this.child,
    this.blur = 24.0,
    this.opacity = 0.7,
    this.radius = SDS.radiusM,
    this.padding,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: (color ?? Colors.white).withValues(alpha: opacity),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// --- SDS Category Item ---
/// A premium, circular 3D category item used for navigation.
class SDSCategoryItem extends StatelessWidget {
  final String label;
  final String assetPath;
  final VoidCallback onTap;
  final bool isSelected;

  const SDSCategoryItem({
    super.key,
    required this.label,
    required this.assetPath,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ShrinkableButton(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 76, 
              height: 76,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary.withValues(alpha: 0.05) : Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
                border: Border.all(
                  color: isSelected ? AppColors.primary.withValues(alpha: 0.3) : const Color(0xFFF2F4F6), 
                  width: 1.5
                ),
              ),
              child: ClipOval(
                child: Center(
                  child: ShaderMask(
                    shaderCallback: (rect) {
                      return const RadialGradient(
                        colors: [Colors.white, Colors.white, Colors.transparent],
                        stops: [0.0, 0.75, 1.0], // Fades out the square background corners
                      ).createShader(rect);
                    },
                    blendMode: BlendMode.dstIn,
                    child: Image.asset(
                      assetPath, 
                      width: 54, 
                      height: 54, 
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8), // Reduced from 12 to prevent 2px overflow
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? SDS.fwBlack : SDS.fwBold,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                letterSpacing: -0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// --- SDS Logo Widget ---
/// A premium, code-generated logo for SijangYeojido.
/// Combines the 'ㅅ' (Sijang) and 'Pin' (Map) into a single 3D-styled icon.
class SDSLogo extends StatelessWidget {
  final double size;
  final bool useGlass;

  const SDSLogo({
    super.key,
    this.size = 120,
    this.useGlass = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Real-time Drop Shadow
          Positioned(
            bottom: size * 0.05,
            child: Container(
              width: size * 0.4,
              height: size * 0.1,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: size * 0.2,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
          // 2. The Main Pin with Painter
          CustomPaint(
            size: Size(size, size),
            painter: _SDSLogoPainter(
              color: AppColors.primary,
              gradient: AppColors.primaryGradient,
            ),
          ),
          // 3. Premium Glass Highlight
          if (useGlass)
            Positioned(
              top: size * 0.18,
              child: Opacity(
                opacity: 0.3,
                child: Container(
                  width: size * 0.5,
                  height: size * 0.25,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.8),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SDSLogoPainter extends CustomPainter {
  final Color color;
  final Gradient gradient;

  _SDSLogoPainter({required this.color, required this.gradient});

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final center = Offset(w / 2, h / 2 - h * 0.08);

    // --- 1. Main Pin Path ---
    final Paint pinPaint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;

    final Path pinPath = Path();
    final double radius = w * 0.36;
    
    // Top circle part (270 degrees approx)
    pinPath.addArc(
      Rect.fromCircle(center: center, radius: radius),
      0.65 * 3.14159, // start angle
      1.73 * 3.14159, // sweep angle
    );
    
    // Bottom point
    pinPath.lineTo(w / 2, h * 0.92);
    pinPath.close();

    canvas.drawPath(pinPath, pinPaint);

    // --- 2. Inner Glow for Depth ---
    final Paint glowPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawPath(pinPath, glowPaint);

    // --- 3. The 'ㅅ' (S) Architectural Cutout ---
    final Paint cutoutPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final Path sPath = Path();
    final double sSize = radius * 0.9;
    final double sTopY = center.dy - sSize * 0.35;
    final double sBottomY = center.dy + sSize * 0.45;
    
    // Left Stroke of 'ㅅ'
    sPath.moveTo(center.dx, sTopY);
    sPath.lineTo(center.dx - sSize * 0.55, sBottomY);
    sPath.lineTo(center.dx - sSize * 0.28, sBottomY);
    sPath.lineTo(center.dx, sTopY + sSize * 0.22);
    
    // Right Stroke of 'ㅅ'
    sPath.lineTo(center.dx + sSize * 0.28, sBottomY);
    sPath.lineTo(center.dx + sSize * 0.55, sBottomY);
    sPath.lineTo(center.dx, sTopY);
    sPath.close();

    canvas.drawPath(sPath, cutoutPaint);
    
    // --- 4. Shadow inside the Cutout for 'Elevated' look ---
    final Paint innerShadow = Paint()
      ..color = const Color(0x33000000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);
    canvas.drawPath(sPath, innerShadow);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// --- SDS Kakao Logo (High-Fidelity) ---
/// A pixel-perfect recreation of the official Kakao speech bubble.
class SDSKakaoLogo extends StatelessWidget {
  final double size;
  const SDSKakaoLogo({super.key, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _KakaoLogoPainter(),
    );
  }
}

class _KakaoLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final Paint paint = Paint()
      ..color = const Color(0xFF3C1E1E)
      ..style = PaintingStyle.fill;

    final Path path = Path();
    // Rounded bubble shape (Official proportions)
    final double centerX = w * 0.5;
    final double centerY = h * 0.45;
    final double radiusX = w * 0.46;
    final double radiusY = h * 0.40;

    path.addOval(Rect.fromCenter(
      center: Offset(centerX, centerY),
      width: radiusX * 2,
      height: radiusY * 2,
    ));

    // Tail (Little point at bottom-left area)
    final Path tail = Path();
    tail.moveTo(w * 0.25, h * 0.75);
    tail.lineTo(w * 0.18, h * 0.92);
    tail.lineTo(w * 0.38, h * 0.82);
    tail.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(tail, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// --- SDS Google Logo (High-Fidelity) ---
/// A geometrically perfect recreation of the official multi-colored Google 'G'.
class SDSGoogleLogo extends StatelessWidget {
  final double size;
  const SDSGoogleLogo({super.key, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _GoogleLogoPainter(),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Official Google SVG paths (viewport 0-40, but the 'G' is in a 20x20 box from 10,10)
    // We scale it so the 'G' (20x20) exactly fills the provided size (e.g. 28x28).
    final double scale = size.width / 20.0;
    canvas.scale(scale);
    canvas.translate(-10, -10); // Center the 20x20 'G' from the 40x40 SVG

    final Paint bluePaint = Paint()..color = const Color(0xFF4285F4)..style = PaintingStyle.fill;
    final Paint greenPaint = Paint()..color = const Color(0xFF34A853)..style = PaintingStyle.fill;
    final Paint yellowPaint = Paint()..color = const Color(0xFFFBBC04)..style = PaintingStyle.fill;
    final Paint redPaint = Paint()..color = const Color(0xFFE94235)..style = PaintingStyle.fill;

    // Blue segment
    canvas.drawPath(
      parseSvgPathData("M29.6 20.2273C29.6 19.5182 29.5364 18.8364 29.4182 18.1818H20V22.05H25.3818C25.15 23.3 24.4455 24.3591 23.3864 25.0682V27.5773H26.6182C28.5091 25.8364 29.6 23.2727 29.6 20.2273V20.2273Z"),
      bluePaint,
    );
    // Green segment
    canvas.drawPath(
      parseSvgPathData("M20 30C22.7 30 24.9636 29.1045 28.6181 27.5773L25.3863 25.0682C24.4909 25.6682 23.3454 26.0227 20 26.0227C19.3954 26.0227 15.1909 24.2636 14.4045 21.9H11.0636V24.4909C12.7091 27.7591 16.0909 30 20 30Z"),
      greenPaint,
    );
    // Yellow segment
    canvas.drawPath(
      parseSvgPathData("M14.4045 21.9C14.2045 21.3 14.0909 20.6591 14.0909 20C14.0909 19.3409 14.2045 18.7 14.4045 18.1V15.5091H11.0636C10.3864 16.8591 10 18.3864 10 20C10 21.6136 10.3864 23.1409 11.0636 24.4909L14.4045 21.9Z"),
      yellowPaint,
    );
    // Red segment
    canvas.drawPath(
      parseSvgPathData("M20 13.9773C21.4681 13.9773 22.7863 14.4818 23.8227 15.4727L26.6909 12.6045C24.9591 10.9909 22.6954 10 20 10C16.0909 10 12.7091 12.2409 11.0636 15.5091L14.4045 18.1C15.1909 15.7364 17.3954 13.9773 20 13.9773Z"),
      redPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
