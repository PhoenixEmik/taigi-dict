import 'package:flutter/material.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:taigi_dict/core/core.dart';

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
    return AdaptiveListTile(
      leading: const Icon(Icons.language),
      title: Text(l10n.languageSetting),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.localeLabel(value)),
          AdaptivePopupMenuButton.icon<Locale>(
            icon: PlatformInfo.isIOS
                ? 'chevron.up.chevron.down'
                : Icons.arrow_drop_down,
            items: AppLocalizations.supportedLocales
                .map(
                  (locale) => AdaptivePopupMenuItem<Locale>(
                    label: l10n.localeLabel(locale),
                    value: locale,
                  ),
                )
                .toList(growable: false),
            onSelected: (index, entry) {
              final selectedLocale = entry.value;
              if (selectedLocale != null) {
                onSelected(selectedLocale);
              }
            },
          ),
        ],
      ),
    );
  }
}
