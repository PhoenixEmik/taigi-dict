import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as glass;

const _liquidGlassFill = CupertinoDynamicColor.withBrightness(
  color: Color(0x26FFFFFF),
  darkColor: Color(0x26000000),
);
const _liquidGlassStroke = CupertinoDynamicColor.withBrightness(
  color: Color(0x14000000),
  darkColor: Color(0x26FFFFFF),
);
const _liquidGlassDivider = CupertinoDynamicColor.withBrightness(
  color: Color(0x14000000),
  darkColor: Color(0x26FFFFFF),
);
const _liquidGlassTint = CupertinoDynamicColor.withBrightness(
  color: CupertinoColors.activeBlue,
  darkColor: Color(0xFF8CCBFF),
);
const _liquidGlassSecondaryTint = CupertinoDynamicColor.withBrightness(
  color: Color(0xFFF2F5F7),
  darkColor: Color(0x33FFFFFF),
);
const _liquidGlassForeground = CupertinoDynamicColor.withBrightness(
  color: Color(0xFF0C2430),
  darkColor: Color(0xFFF3F8FB),
);
const _liquidGlassSecondaryForeground = CupertinoDynamicColor.withBrightness(
  color: Color(0xFF5B6A73),
  darkColor: Color(0xFFCAD5DB),
);

bool isApplePlatform(BuildContext context) {
  if (kIsWeb) {
    return false;
  }
  final platform = Theme.of(context).platform;
  return platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;
}

Color resolveLiquidGlassTint(BuildContext context) =>
    CupertinoDynamicColor.resolve(_liquidGlassTint, context);

Color resolveLiquidGlassSecondaryTint(BuildContext context) =>
    CupertinoDynamicColor.resolve(_liquidGlassSecondaryTint, context);

Color resolveLiquidGlassForeground(BuildContext context) =>
    CupertinoDynamicColor.resolve(_liquidGlassForeground, context);

Color resolveLiquidGlassSecondaryForeground(BuildContext context) =>
    CupertinoDynamicColor.resolve(_liquidGlassSecondaryForeground, context);

Color resolveAdaptiveCircleButtonBackground(BuildContext context) {
  final brightness = Theme.of(context).brightness;
  return brightness == Brightness.light
      ? Colors.black.withValues(alpha: 0.05)
      : Colors.white.withValues(alpha: 0.15);
}

Color resolveAdaptiveCircleButtonIconColor(BuildContext context) {
  final brightness = Theme.of(context).brightness;
  return brightness == Brightness.light
      ? Theme.of(context).colorScheme.primary
      : Colors.blueAccent.shade100;
}

TextStyle? resolveGlassListTileTitleStyle(BuildContext context) {
  return Theme.of(context).textTheme.titleMedium?.copyWith(
    color: resolveLiquidGlassForeground(context),
    fontWeight: FontWeight.w700,
  );
}

TextStyle? resolveGlassListTileSubtitleStyle(BuildContext context) {
  return Theme.of(context).textTheme.bodySmall?.copyWith(
    color: resolveLiquidGlassSecondaryForeground(context),
  );
}

Icon glassChevron(BuildContext context) {
  return Icon(
    Icons.chevron_right,
    color: resolveLiquidGlassSecondaryForeground(context),
    size: 20,
  );
}

class LiquidGlassBackground extends StatelessWidget {
  const LiquidGlassBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!isApplePlatform(context)) {
      return child;
    }

    final topGlow = resolveLiquidGlassTint(context).withValues(alpha: 0.14);
    final bottomGlow = resolveLiquidGlassSecondaryTint(
      context,
    ).withValues(alpha: 0.32);
    final base = Theme.of(context).scaffoldBackgroundColor;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.alphaBlend(topGlow.withValues(alpha: 0.10), base),
            base,
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -80,
            right: -30,
            child: _GlowOrb(color: topGlow, size: 220),
          ),
          Positioned(
            left: -70,
            top: 210,
            child: _GlowOrb(color: bottomGlow, size: 180),
          ),
          child,
        ],
      ),
    );
  }
}

class LiquidGlassSection extends StatelessWidget {
  const LiquidGlassSection({
    super.key,
    required this.children,
    this.dividerIndent = 72,
    this.dividerEndIndent = 0,
  });

  final List<Widget> children;
  final double dividerIndent;
  final double dividerEndIndent;

  @override
  Widget build(BuildContext context) {
    if (!isApplePlatform(context)) {
      return Column(children: children);
    }

    final fill = CupertinoDynamicColor.resolve(_liquidGlassFill, context);
    final stroke = CupertinoDynamicColor.resolve(_liquidGlassStroke, context);
    final divider = CupertinoDynamicColor.resolve(_liquidGlassDivider, context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: stroke, width: 0.5),
          ),
          child: Column(
            children: [
              for (var index = 0; index < children.length; index++) ...[
                children[index],
                if (index < children.length - 1)
                  Padding(
                    padding: EdgeInsets.only(
                      left: dividerIndent,
                      right: dividerEndIndent,
                    ),
                    child: Divider(height: 1, thickness: 0.5, color: divider),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class AdaptiveSettingsActionButton extends StatelessWidget {
  const AdaptiveSettingsActionButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    if (!isApplePlatform(context)) {
      return IconButton.filledTonal(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(icon),
      );
    }

    final tint = resolveLiquidGlassTint(context);
    final buttonSettings = glass.LiquidGlassSettings(
      blur: 18,
      thickness: 16,
      glassColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.white.withValues(alpha: 0.14)
          : Colors.white.withValues(alpha: 0.36),
      lightIntensity: 0.72,
      ambientStrength: 0.24,
      refractiveIndex: 1.16,
      saturation: 1.15,
      chromaticAberration: 0.01,
    );

    return Tooltip(
      message: tooltip,
      child: glass.GlassButton(
        label: tooltip,
        icon: Icon(icon),
        onTap: onPressed ?? () {},
        enabled: onPressed != null,
        width: 36,
        height: 36,
        iconSize: 20,
        iconColor: tint,
        settings: buttonSettings,
        useOwnLayer: false,
        quality: glass.GlassQuality.standard,
        shape: const glass.LiquidOval(),
      ),
    );
  }
}

class AdaptiveCircleButton extends StatelessWidget {
  const AdaptiveCircleButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.size = 48,
    this.iconSize = 22,
    this.enabled = true,
    this.child,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final double size;
  final double iconSize;
  final bool enabled;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = resolveAdaptiveCircleButtonBackground(context);
    final iconColor = resolveAdaptiveCircleButtonIconColor(context);
    final buttonChild =
        child ??
        Icon(
          icon,
          color: enabled
              ? iconColor
              : resolveLiquidGlassSecondaryForeground(context),
          size: iconSize,
        );

    return Tooltip(
      message: tooltip,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        onPressed: enabled ? onPressed : null,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
          ),
          child: Center(child: buttonChild),
        ),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0.0)],
          ),
        ),
      ),
    );
  }
}
