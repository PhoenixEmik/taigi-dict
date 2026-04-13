import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as glass;
import 'package:taigi_dict/core/localization/app_localizations.dart';
import 'package:taigi_dict/core/preferences/app_preferences.dart';
import 'package:taigi_dict/features/settings/presentation/widgets/liquid_glass.dart';

class SettingsTextScaleTile extends StatelessWidget {
  const SettingsTextScaleTile({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final applePlatform = isApplePlatform(context);
    final trailing = Text(
      '${(value * 100).round()}%',
      style: theme.textTheme.labelLarge?.copyWith(
        color: applePlatform ? resolveLiquidGlassForeground(context) : null,
        fontWeight: FontWeight.w700,
      ),
    );
    final subtitle = Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (applePlatform)
            glass.GlassSlider(
              value: value,
              min: AppPreferences.minReadingTextScale,
              max: AppPreferences.maxReadingTextScale,
              divisions: 5,
              label: l10n.readingTextScaleLabel(value),
              activeColor: resolveLiquidGlassTint(context),
              inactiveColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: 0.16)
                  : Colors.black.withValues(alpha: 0.12),
              thumbColor: Colors.white,
              trackHeight: 4,
              thumbRadius: 13,
              quality: glass.GlassQuality.standard,
              onChanged: onChanged,
            )
          else
            Slider.adaptive(
              value: value,
              min: AppPreferences.minReadingTextScale,
              max: AppPreferences.maxReadingTextScale,
              divisions: 5,
              label: l10n.readingTextScaleLabel(value),
              onChanged: onChanged,
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.small,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: applePlatform
                      ? resolveLiquidGlassSecondaryForeground(context)
                      : null,
                ),
              ),
              Text(
                l10n.extraLarge,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: applePlatform
                      ? resolveLiquidGlassSecondaryForeground(context)
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (applePlatform) {
      return glass.GlassListTile(
        showDivider: false,
        leadingIconColor: resolveLiquidGlassTint(context),
        titleStyle: resolveGlassListTileTitleStyle(context),
        subtitleStyle: resolveGlassListTileSubtitleStyle(context),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        leading: const Icon(Icons.format_size),
        title: Text(l10n.fontSize),
        trailing: trailing,
        subtitle: subtitle,
      );
    }

    return ListTile(
      leading: Icon(Icons.format_size, color: theme.colorScheme.primary),
      title: Text(l10n.fontSize),
      trailing: trailing,
      subtitle: subtitle,
    );
  }
}
