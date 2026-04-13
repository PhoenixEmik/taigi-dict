import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as glass;
import 'package:taigi_dict/core/localization/app_localizations.dart';
import 'package:taigi_dict/features/settings/presentation/widgets/liquid_glass.dart';
import 'package:taigi_dict/features/settings/presentation/widgets/settings_glass_option_menu.dart';

class SettingsLocaleTile extends StatelessWidget {
  const SettingsLocaleTile({
    super.key,
    required this.value,
    required this.onSelected,
  });

  final Locale value;
  final ValueChanged<Locale> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final applePlatform = isApplePlatform(context);
    final trailing = applePlatform
        ? SettingsGlassOptionMenu<Locale>(
            value: value,
            label: l10n.localeLabel(value),
            items: AppLocalizations.supportedLocales,
            itemLabel: l10n.localeLabel,
            onSelected: onSelected,
          )
        : DropdownButtonHideUnderline(
            child: DropdownButton<Locale>(
              value: value,
              icon: const Icon(Icons.arrow_drop_down),
              onChanged: (selection) {
                if (selection != null) {
                  onSelected(selection);
                }
              },
              items: AppLocalizations.supportedLocales
                  .map((locale) {
                    return DropdownMenuItem<Locale>(
                      value: locale,
                      child: Text(l10n.localeLabel(locale)),
                    );
                  })
                  .toList(growable: false),
            ),
          );

    if (applePlatform) {
      return glass.GlassListTile(
        showDivider: false,
        leadingIconColor: resolveLiquidGlassTint(context),
        titleStyle: resolveGlassListTileTitleStyle(context),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        leading: const Icon(Icons.language),
        title: Text(l10n.languageSetting),
        trailing: trailing,
      );
    }

    return ListTile(
      leading: Icon(Icons.language, color: colorScheme.primary),
      title: Text(l10n.languageSetting),
      trailing: trailing,
    );
  }
}
