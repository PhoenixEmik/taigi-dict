import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as glass;
import 'package:taigi_dict/core/localization/app_localizations.dart';
import 'package:taigi_dict/core/preferences/app_preferences.dart';
import 'package:taigi_dict/features/settings/presentation/widgets/liquid_glass.dart';
import 'package:taigi_dict/features/settings/presentation/widgets/settings_glass_option_menu.dart';

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
    final colorScheme = Theme.of(context).colorScheme;
    final applePlatform = isApplePlatform(context);
    final trailing = applePlatform
        ? SettingsGlassOptionMenu<AppThemePreference>(
            value: value,
            label: _themeLabel(value, l10n),
            items: AppThemePreference.values,
            itemLabel: (mode) => _themeLabel(mode, l10n),
            onSelected: onSelected,
          )
        : DropdownButtonHideUnderline(
            child: DropdownButton<AppThemePreference>(
              value: value,
              icon: const Icon(Icons.arrow_drop_down),
              onChanged: (selection) {
                if (selection != null) {
                  onSelected(selection);
                }
              },
              items: AppThemePreference.values
                  .map((mode) {
                    return DropdownMenuItem<AppThemePreference>(
                      value: mode,
                      child: Text(_themeLabel(mode, l10n)),
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
        leading: const Icon(Icons.palette),
        title: Text(l10n.theme),
        trailing: trailing,
      );
    }

    return ListTile(
      leading: Icon(Icons.palette, color: colorScheme.primary),
      title: Text(l10n.theme),
      trailing: trailing,
    );
  }
}

String _themeLabel(AppThemePreference value, AppLocalizations l10n) {
  return l10n.themeLabel(switch (value) {
    AppThemePreference.system => AppThemePreferenceProxy.system,
    AppThemePreference.light => AppThemePreferenceProxy.light,
    AppThemePreference.dark => AppThemePreferenceProxy.dark,
    AppThemePreference.amoled => AppThemePreferenceProxy.amoled,
  });
}
