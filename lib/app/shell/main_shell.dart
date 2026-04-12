import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:taigi_dict/app/initialization/app_initialization_controller.dart';
import 'package:taigi_dict/app/initialization/app_initialization_screen.dart';
import 'package:taigi_dict/core/localization/app_localizations.dart';
import 'package:taigi_dict/features/bookmarks/application/bookmark_store.dart';
import 'package:taigi_dict/features/bookmarks/presentation/screens/bookmarks_screen.dart';
import 'package:taigi_dict/features/dictionary/data/dictionary_database_builder_service.dart';
import 'package:taigi_dict/features/dictionary/data/dictionary_repository.dart';
import 'package:taigi_dict/features/dictionary/data/offline_dictionary_library.dart';
import 'package:taigi_dict/features/dictionary/presentation/screens/dictionary_screen.dart';
import 'package:taigi_dict/features/settings/presentation/screens/settings_screen.dart';
import 'package:taigi_dict/features/settings/presentation/widgets/liquid_glass.dart';
import 'package:taigi_dict/offline_audio.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as glass;
import 'package:shared_preferences/shared_preferences.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final DictionaryRepository _repository = DictionaryRepository();
  final DictionaryDatabaseBuilderService _dictionaryDatabaseBuilderService =
      const DictionaryDatabaseBuilderService();
  final OfflineDictionaryLibrary _dictionaryLibrary =
      OfflineDictionaryLibrary();
  final OfflineAudioLibrary _audioLibrary = OfflineAudioLibrary();
  final BookmarkStore _bookmarkStore = BookmarkStore();
  late final AppInitializationController _initializationController =
      AppInitializationController(
        builderService: _dictionaryDatabaseBuilderService,
        dictionaryLibrary: _dictionaryLibrary,
      );

  int _selectedIndex = 0;
  bool _startupRequested = false;
  bool _startupGateResolved = false;
  bool _shouldBlockInitialization = true;

  @override
  void initState() {
    super.initState();
    unawaited(_audioLibrary.initialize());
    unawaited(_bookmarkStore.initialize());
    unawaited(_prepareStartupGate());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_startupRequested || !_startupGateResolved) {
      return;
    }
    _startupRequested = true;
    unawaited(_startInitialization());
  }

  @override
  void dispose() {
    _initializationController.dispose();
    _bookmarkStore.dispose();
    _dictionaryLibrary.dispose();
    _audioLibrary.dispose();
    super.dispose();
  }

  Future<void> _startInitialization() async {
    try {
      await _initializationController.initialize(AppLocalizations.of(context));
    } catch (_) {
      // The blocking startup screen reads the controller error state directly.
    }
  }

  Future<void> _prepareStartupGate() async {
    final preferences = await SharedPreferences.getInstance();
    final readyFlag =
        preferences.getBool(
          AppInitializationController.databaseReadyPreferenceKey,
        ) ??
        false;
    final hasDatabase = await _dictionaryDatabaseBuilderService
        .hasBuiltDatabase();

    if (!mounted) {
      return;
    }

    setState(() {
      _shouldBlockInitialization = !readyFlag || !hasDatabase;
      _startupGateResolved = true;
    });

    if (!_startupRequested) {
      _startupRequested = true;
      unawaited(_startInitialization());
    }
  }

  Future<void> _retryInitialization() async {
    try {
      await _initializationController.retry(AppLocalizations.of(context));
    } catch (_) {
      // The blocking startup screen reads the controller error state directly.
    }
  }

  Future<void> _handleArchiveDownloadAction(AudioArchiveType type) async {
    final l10n = AppLocalizations.of(context);
    final result = await _audioLibrary.handleDownloadAction(type, l10n);
    _showResult(result);
  }

  Future<void> _handleDictionarySourceDownloadAction() async {
    final l10n = AppLocalizations.of(context);
    final result = await _dictionaryLibrary.handleDownloadAction(l10n);
    _showResult(result);

    final snapshot = _dictionaryLibrary.downloadSnapshot;
    if (result.isError ||
        _dictionaryLibrary.downloadState != DownloadState.completed ||
        !_dictionaryLibrary.isSourceReady ||
        snapshot.totalBytes <= 0 ||
        snapshot.downloadedBytes != snapshot.totalBytes) {
      return;
    }

    try {
      await _rebuildDictionaryDatabaseInternal();
      _showResult(AudioActionResult(message: l10n.dictionaryDatabaseRebuilt));
    } catch (error) {
      _showResult(
        AudioActionResult(
          message: _describeDatabaseRebuildError(error, l10n),
          isError: true,
        ),
      );
    }
  }

  Future<void> _rebuildDictionaryDatabase() async {
    await _rebuildDictionaryDatabaseInternal();
  }

  Future<void> _rebuildDictionaryDatabaseInternal() async {
    await _dictionaryDatabaseBuilderService.rebuildFromDownloadedOds();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(
      AppInitializationController.databaseReadyPreferenceKey,
      true,
    );
    DictionaryRepository.clearBundleCache();
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  void _showResult(AudioActionResult result) {
    final message = result.message;
    if (!mounted || message == null || message.isEmpty) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: result.isError
              ? const Color(0xFF8A3B1F)
              : const Color(0xFF0E2F35),
        ),
      );
  }

  String _describeDatabaseRebuildError(Object error, AppLocalizations l10n) {
    if (error is MissingDictionarySourceException) {
      return l10n.downloadDictionarySourceFirst;
    }
    if (error is CorruptedDictionarySourceException) {
      return l10n.dictionarySourceCorrupted;
    }
    if (error is MissingDictionarySheetException) {
      return l10n.dictionarySourceSheetMissing(error.sheetName);
    }
    return l10n.dictionaryDatabaseRebuildFailed('$error');
  }

  Widget _buildAppleFloatingDock(BuildContext context, AppLocalizations l10n) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final brightness = Theme.of(context).brightness;
    final settings = glass.LiquidGlassSettings(
      blur: 30,
      thickness: 26,
      glassColor: brightness == Brightness.dark
          ? Colors.black.withValues(alpha: 0.15)
          : Colors.white.withValues(alpha: 0.20),
      lightIntensity: brightness == Brightness.dark ? 0.42 : 0.68,
      ambientStrength: brightness == Brightness.dark ? 0.05 : 0.02,
      refractiveIndex: 1.18,
      saturation: brightness == Brightness.dark ? 1.20 : 1.08,
      chromaticAberration: 0.008,
      specularSharpness: glass.GlassSpecularSharpness.medium,
    );

    return Positioned(
      left: 0,
      right: 0,
      bottom: bottomInset + 24,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: glass.GlassCard(
          useOwnLayer: true,
          quality: glass.GlassQuality.premium,
          settings: settings,
          margin: EdgeInsets.zero,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: const glass.LiquidRoundedSuperellipse(borderRadius: 50),
          clipBehavior: Clip.antiAlias,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildAppleDockTab(
                context,
                index: 0,
                label: l10n.dictionaryTab,
                icon: CupertinoIcons.book,
                selectedIcon: CupertinoIcons.book_fill,
              ),
              const SizedBox(width: 10),
              _buildAppleDockTab(
                context,
                index: 1,
                label: l10n.bookmarksTab,
                icon: CupertinoIcons.bookmark,
                selectedIcon: CupertinoIcons.bookmark_fill,
              ),
              const SizedBox(width: 10),
              _buildAppleDockTab(
                context,
                index: 2,
                label: l10n.settingsTab,
                icon: CupertinoIcons.gear,
                selectedIcon: CupertinoIcons.gear_solid,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppleDockTab(
    BuildContext context, {
    required int index,
    required String label,
    required IconData icon,
    required IconData selectedIcon,
  }) {
    final selected = _selectedIndex == index;
    final foregroundColor = selected
        ? CupertinoColors.activeBlue.resolveFrom(context)
        : CupertinoColors.systemGrey.resolveFrom(context);

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Tooltip(
        message: label,
        child: CupertinoButton(
          minimumSize: const Size(54, 48),
          padding: EdgeInsets.zero,
          borderRadius: BorderRadius.circular(24),
          onPressed: () {
            setState(() {
              _selectedIndex = index;
            });
          },
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOutCubic,
            style:
                Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: foregroundColor,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0,
                ) ??
                TextStyle(
                  color: foregroundColor,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0,
                ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  selected ? selectedIcon : icon,
                  size: 22,
                  color: foregroundColor,
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget? _buildRootAppBar(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    switch (_selectedIndex) {
      case 1:
        if (isApplePlatform(context)) {
          return glass.GlassAppBar(
            useOwnLayer: true,
            quality: glass.GlassQuality.premium,
            backgroundColor: Theme.of(context).colorScheme.surface,
            title: Text(
              l10n.bookmarksTitle,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: resolveLiquidGlassForeground(context),
              ),
            ),
          );
        }
        return AppBar(title: Text(l10n.bookmarksTitle));
      case 2:
        if (isApplePlatform(context)) {
          return glass.GlassAppBar(
            useOwnLayer: true,
            quality: glass.GlassQuality.premium,
            backgroundColor: Theme.of(context).colorScheme.surface,
            title: Text(
              l10n.settingsTitle,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: resolveLiquidGlassForeground(context),
              ),
            ),
          );
        }
        return AppBar(title: Text(l10n.settingsTitle));
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bypassInitialization =
        !DictionaryRepository.preferLocalDatabase &&
        DictionaryRepository.hasDebugFallbackBundle;

    return AnimatedBuilder(
      animation: Listenable.merge([
        _initializationController,
        _dictionaryLibrary,
      ]),
      builder: (context, child) {
        if (!_startupGateResolved && !bypassInitialization) {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: const SizedBox.expand(),
          );
        }

        if (_shouldBlockInitialization &&
            !_initializationController.isReady &&
            !bypassInitialization) {
          return AppInitializationScreen(
            controller: _initializationController,
            dictionaryLibrary: _dictionaryLibrary,
            onRetry: _retryInitialization,
          );
        }

        final screens = [
          DictionaryScreen(
            key: ValueKey(
              'dictionary-${_initializationController.databaseGeneration}',
            ),
            repository: _repository,
            audioLibrary: _audioLibrary,
            bookmarkStore: _bookmarkStore,
            onActionResult: _showResult,
          ),
          BookmarksScreen(
            key: ValueKey(
              'bookmarks-${_initializationController.databaseGeneration}',
            ),
            repository: _repository,
            audioLibrary: _audioLibrary,
            bookmarkStore: _bookmarkStore,
            onActionResult: _showResult,
            showOwnScaffold: false,
          ),
          SettingsScreen(
            audioLibrary: _audioLibrary,
            dictionaryLibrary: _dictionaryLibrary,
            onDownloadArchive: _handleArchiveDownloadAction,
            onDownloadDictionarySource: _handleDictionarySourceDownloadAction,
            onRebuildDictionaryDatabase: _rebuildDictionaryDatabase,
            showOwnScaffold: false,
          ),
        ];

        if (isApplePlatform(context)) {
          return Scaffold(
            extendBody: true,
            backgroundColor: Colors.transparent,
            appBar: _buildRootAppBar(context, l10n),
            body: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: IndexedStack(index: _selectedIndex, children: screens),
                ),
                _buildAppleFloatingDock(context, l10n),
              ],
            ),
          );
        }

        return Scaffold(
          appBar: _buildRootAppBar(context, l10n),
          body: IndexedStack(index: _selectedIndex, children: screens),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.menu_book_outlined),
                selectedIcon: const Icon(Icons.menu_book),
                label: l10n.dictionaryTab,
              ),
              NavigationDestination(
                icon: const Icon(Icons.bookmark_border),
                selectedIcon: const Icon(Icons.bookmark),
                label: l10n.bookmarksTab,
              ),
              NavigationDestination(
                icon: const Icon(Icons.settings_outlined),
                selectedIcon: const Icon(Icons.settings),
                label: l10n.settingsTab,
              ),
            ],
          ),
        );
      },
    );
  }
}
