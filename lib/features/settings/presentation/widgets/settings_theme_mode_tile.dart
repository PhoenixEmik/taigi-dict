import 'package:flutter/material.dart';
import 'package:hokkien_dictionary/core/preferences/app_preferences.dart';

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
    return ListTile(
      title: const Text('主題'),
      subtitle: Text(value.label),
      trailing: SizedBox(
        width: 168,
        child: DropdownMenu<AppThemePreference>(
          key: ValueKey<AppThemePreference>(value),
          initialSelection: value,
          requestFocusOnTap: false,
          label: const Text('顯示模式'),
          onSelected: (selection) {
            if (selection != null) {
              onSelected(selection);
            }
          },
          dropdownMenuEntries: AppThemePreference.values
              .map((mode) {
                return DropdownMenuEntry<AppThemePreference>(
                  value: mode,
                  label: mode.label,
                );
              })
              .toList(growable: false),
        ),
      ),
    );
  }
}
