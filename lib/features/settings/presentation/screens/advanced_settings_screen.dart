import 'dart:async';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:taigi_dict/core/core.dart';
import 'package:taigi_dict/features/dictionary/dictionary.dart';
import 'package:taigi_dict/features/settings/settings.dart';


class AdvancedSettingsScreen extends StatelessWidget {
  const AdvancedSettingsScreen({
    super.key,
    required this.onRebuildDictionaryDatabase,
  });

  final Future<void> Function() onRebuildDictionaryDatabase;

  Future<void> _confirmAndRebuild(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmationDialog(
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
    final closeProgressDialog = await showAdaptiveBlockingProgressDialog(
      context: context,
      title: l10n.rebuildingDictionaryDatabase,
      actionLabel: l10n.confirmAction,
      icon: const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator.adaptive(strokeWidth: 2.5),
      ),
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

    if (context.mounted) {
      closeProgressDialog();
    }

    showAppNotification(
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
    final topBodyInset = PlatformInfo.isIOS
        ? MediaQuery.paddingOf(context).top + kToolbarHeight
        : 0.0;

    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(
        title: l10n.advancedSettings,
        useNativeToolbar: true,
      ),
      body: Padding(
        padding: EdgeInsets.only(top: topBodyInset),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
          children: [
            AdaptiveFormSection.insetGrouped(
              children: [
                AdaptiveListTile(
                  leading: const Icon(Icons.storage_outlined),
                  title: Text(l10n.rebuildDictionaryDatabase),
                  subtitle: Text(l10n.rebuildDictionaryDatabaseSubtitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    unawaited(_confirmAndRebuild(context));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


