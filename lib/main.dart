import 'package:flutter/material.dart';
import 'package:taigi_dict/app/app.dart';
import 'package:taigi_dict/core/licenses/font_licenses.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  registerBundledFontLicenses();
  runApp(const HokkienDictionaryApp());
}
