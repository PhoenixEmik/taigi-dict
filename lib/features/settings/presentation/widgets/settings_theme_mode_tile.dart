import 'package:flutter/material.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:taigi_dict/core/core.dart';

class SettingsThemeModeTile extends StatelessWidget {
  const SettingsThemeModeTile({
    super.key,
    required this.value,
    required this.onSelected,
  });

  final AppThemePreference value;
  final ValueChanged<AppThemePreference> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isApplePlatform =
        PlatformInfo.isIOS || Theme.of(context).platform == TargetPlatform.macOS;
    final availablePreferences = isApplePlatform
        ? const [
            AppThemePreference.system,
            AppThemePreference.light,
            AppThemePreference.dark,
          ]
        : const [
            AppThemePreference.system,
            AppThemePreference.light,
            AppThemePreference.dark,
            AppThemePreference.amoled,
          ];

    return AdaptiveListTile(
      leading: const Icon(Icons.dark_mode_outlined),
      title: Text(l10n.theme),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_themeLabel(value, l10n, isApplePlatform: isApplePlatform)),
          AdaptivePopupMenuButton.icon<AppThemePreference>(
            icon: PlatformInfo.isIOS
                ? 'chevron.up.chevron.down'
                : Icons.arrow_drop_down,
            items: availablePreferences
                .map(
                  (preference) => AdaptivePopupMenuItem<AppThemePreference>(
                    label: _themeLabel(
                      preference,
                      l10n,
                      isApplePlatform: isApplePlatform,
                    ),
                    value: preference,
                  ),
                )
                .toList(growable: false),
            onSelected: (index, entry) {
              final selectedPreference = entry.value;
              if (selectedPreference != null) {
                onSelected(selectedPreference);
              }
            },
          ),
        ],
      ),
    );
  }
}

String _themeLabel(
  AppThemePreference value,
  AppLocalizations l10n, {
  required bool isApplePlatform,
}) {
  final effectiveValue =
      isApplePlatform && value == AppThemePreference.amoled
      ? AppThemePreference.dark
      : value;

  return l10n.themeLabel(switch (effectiveValue) {
    AppThemePreference.system => AppThemePreferenceProxy.system,
    AppThemePreference.light => AppThemePreferenceProxy.light,
    AppThemePreference.dark => AppThemePreferenceProxy.dark,
    AppThemePreference.amoled => AppThemePreferenceProxy.amoled,
  });
}
