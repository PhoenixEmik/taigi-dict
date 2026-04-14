import 'dart:async';

import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:taigi_dict/core/localization/app_localizations.dart';
import 'package:taigi_dict/core/utils/dialog_utils.dart';
import 'package:taigi_dict/features/dictionary/data/dictionary_database_builder_service.dart';
import 'package:taigi_dict/features/settings/presentation/widgets/glass_notification.dart';
import 'package:taigi_dict/features/settings/presentation/widgets/liquid_glass.dart';
import 'package:taigi_dict/features/settings/presentation/widgets/settings_section_header.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as glass;

class AdvancedSettingsScreen extends StatelessWidget {
  const AdvancedSettingsScreen({
    super.key,
    required this.onRebuildDictionaryDatabase,
  });

  final Future<void> Function() onRebuildDictionaryDatabase;



  Future<void> _confirmAndRebuild(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showAdaptiveConfirmationDialog(
      context: context,
      title: l10n.confirmRebuildDictionaryTitle,
      content: l10n.confirmRebuildDictionaryBody,
      cancelLabel: l10n.cancelAction,
      confirmLabel: l10n.confirmAction,
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    await _handleRebuildDictionaryDatabase(context);
  }

  Future<void> _handleRebuildDictionaryDatabase(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            content: Row(
              children: [
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator.adaptive(strokeWidth: 2.5),
                ),
                const SizedBox(width: 16),
                Expanded(child: Text(l10n.rebuildingDictionaryDatabase)),
              ],
            ),
          ),
        );
      },
    );

    Object? error;
    try {
      await onRebuildDictionaryDatabase();
    } catch (caught) {
      error = caught;
    }

    if (!context.mounted) {
      return;
    }

    Navigator.of(context, rootNavigator: true).pop();

    showGlassNotification(
      context,
      message: error == null
          ? l10n.rebuildDictionaryDatabaseSuccess
          : error is MissingDictionarySourceException
          ? l10n.downloadDictionarySourceFirst
          : error is CorruptedDictionarySourceException
          ? l10n.dictionarySourceCorrupted
          : error is MissingDictionarySheetException
          ? l10n.dictionarySourceSheetMissing(error.sheetName)
          : l10n.dictionaryDatabaseRebuildFailed('$error'),
      isError: error != null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final applePlatform = isApplePlatform(context);
    final sectionChildren = [
      AdaptiveListTile(
        leading: const Icon(Icons.storage_outlined),
        title: Text(l10n.rebuildDictionaryDatabase),
        subtitle: Text(l10n.rebuildDictionaryDatabaseSubtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          unawaited(_confirmAndRebuild(context));
        },
      ),
    ];

    final body = Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(
          padding: EdgeInsets.fromLTRB(16, applePlatform ? 12 : 8, 16, 28),
          children: [
            AdaptiveFormSection.insetGrouped(
              header: Text(l10n.advancedSettings),
              children: sectionChildren,
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      backgroundColor: applePlatform
          ? Colors.transparent
          : Theme.of(context).scaffoldBackgroundColor,
      appBar: applePlatform
          ? glass.GlassAppBar(
              useOwnLayer: true,
              quality: glass.GlassQuality.premium,
              backgroundColor: Theme.of(context).colorScheme.surface,
              leading: IconButton(
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                onPressed: () => Navigator.of(context).maybePop(),
                icon: Icon(
                  CupertinoIcons.back,
                  color: resolveLiquidGlassTint(context),
                  size: 22,
                ),
              ),
              title: Text(
                l10n.advancedSettings,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: resolveLiquidGlassForeground(context),
                ),
              ),
            )
          : AppBar(title: Text(l10n.advancedSettings)),
      body: applePlatform ? LiquidGlassBackground(child: body) : body,
    );
  }
}


