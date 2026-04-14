import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
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

    return AdaptiveListTile(
      leading: const Icon(Icons.language),
      title: Text(l10n.languageSetting),
      trailing: trailing,
    );
  }
}
