import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hokkien_dictionary/app/shell/main_shell.dart';
import 'package:hokkien_dictionary/app/theme/app_theme.dart';
import 'package:hokkien_dictionary/core/preferences/app_preferences.dart';

class HokkienDictionaryApp extends StatefulWidget {
  const HokkienDictionaryApp({super.key});

  @override
  State<HokkienDictionaryApp> createState() => _HokkienDictionaryAppState();
}

class _HokkienDictionaryAppState extends State<HokkienDictionaryApp> {
  final AppPreferences _appPreferences = AppPreferences();

  @override
  void initState() {
    super.initState();
    unawaited(_appPreferences.initialize());
  }

  @override
  void dispose() {
    _appPreferences.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppPreferencesScope(
      notifier: _appPreferences,
      child: ListenableBuilder(
        listenable: _appPreferences,
        builder: (context, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: '台語辭典',
            theme: buildLightAppTheme(),
            darkTheme: _appPreferences.useAmoledTheme
                ? buildAmoledAppTheme()
                : buildDarkAppTheme(),
            themeMode: _appPreferences.materialThemeMode,
            home: child,
          );
        },
        child: const MainScreen(),
      ),
    );
  }
}
