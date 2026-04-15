import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taigi_dict/core/core.dart';
import 'package:taigi_dict/features/audio/audio.dart';
import 'package:taigi_dict/features/dictionary/dictionary.dart';

void main() {
  group('dictionary search functions', () {
    test('normalizeQuery folds tones, punctuation, and separators', () {
      expect(normalizeQuery('  Tsìt4-tsi̍t8/【狗】  '), 'tsit tsit 狗');
      expect(normalizeQuery('母仔（bó-á）, foo_bar'), '母仔 bo a foo bar');
      expect(normalizeQuery('o͘ ⁿ óo'), 'o n oo');
    });

    test(
      'searchDictionaryEntryIds ranks exact headwords before longer and definition matches',
      () {
        final index = buildDictionarySearchIndex([
          _entry(
            id: 10,
            hanji: '人民族',
            romanization: 'jin-bin-tso̍k',
            definition: '民族',
          ),
          _entry(
            id: 20,
            hanji: '人民',
            romanization: 'jin-bin',
            definition: '人民',
          ),
          _entry(
            id: 30,
            hanji: '政權',
            romanization: 'tsing-khuan',
            definition: '人民的權力',
          ),
          _entry(
            id: 40,
            hanji: '新人民',
            romanization: 'sin-jin-bin',
            definition: '新人民',
          ),
        ]);

        expect(searchDictionaryEntryIds(index, normalizeQuery('人民')), [
          20,
          10,
          40,
          30,
        ]);
      },
    );

    test(
      'findLinkedEntry prefers exact and variant headwords before romanization',
      () {
        final bundle = DictionaryBundle(
          entryCount: 3,
          senseCount: 3,
          exampleCount: 0,
          entries: [
            _entry(id: 1, hanji: '母', romanization: 'bo', definition: '母親'),
            _entry(
              id: 2,
              hanji: '無',
              romanization: 'bo',
              definition: '沒有',
              variantChars: const ['毋'],
            ),
            _entry(id: 3, hanji: '母仔', romanization: 'bo-a', definition: '雌性'),
          ],
        );

        final repository = DictionaryRepository();

        expect(repository.findLinkedEntry(bundle, '毋')?.id, 2);
        expect(repository.findLinkedEntry(bundle, 'bo')?.id, 1);
        expect(repository.findLinkedEntry(bundle, '母仔')?.id, 3);
        expect(repository.findLinkedEntry(bundle, '母親'), isNull);
      },
    );

    test('entriesByIdsAsync preserves unique requested id order', () async {
      final bundle = DictionaryBundle(
        entryCount: 3,
        senseCount: 3,
        exampleCount: 0,
        entries: [
          _entry(id: 1, hanji: '一', romanization: 'tsi̍t', definition: '數字一'),
          _entry(id: 2, hanji: '狗', romanization: 'kau', definition: '狗'),
          _entry(id: 3, hanji: '貓', romanization: 'niau', definition: '貓'),
        ],
      );

      final results = await DictionaryRepository().entriesByIdsAsync(bundle, [
        3,
        1,
        3,
        99,
        2,
      ]);

      expect(results.map((entry) => entry.id), [3, 1, 2]);
    });
  });

  group('definition parsing functions', () {
    test('parseDefinitionSegments handles multiple linked words', () {
      final segments = parseDefinitionSegments('參見【母】與【母仔】。');

      expect(segments.map((segment) => segment.displayText), [
        '參見',
        '【母】',
        '與',
        '【母仔】',
        '。',
      ]);
      expect(
        segments
            .where((segment) => segment.isActionable)
            .map((segment) => segment.actionWord),
        ['母', '母仔'],
      );
    });

    test(
      'parseDefinitionSegments treats empty bracket content as plain text',
      () {
        final segments = parseDefinitionSegments('無效【   】連結');

        expect(segments, hasLength(3));
        expect(segments[1].displayText, '【   】');
        expect(segments[1].isActionable, isFalse);
      },
    );
  });

  group('audio formatting functions', () {
    test('formatBytes uses compact binary units', () {
      expect(formatBytes(-1), '0 B');
      expect(formatBytes(999), '999 B');
      expect(formatBytes(1536), '1.5 KB');
      expect(formatBytes(1048576), '1.0 MB');
      expect(formatBytes(1073741824), '1.0 GB');
    });

    test('formatBytesPerSecond rounds before formatting', () {
      expect(formatBytesPerSecond(0), '0 B/s');
      expect(formatBytesPerSecond(1535.6), '1.5 KB/s');
    });
  });

  group('localization helper functions', () {
    test('resolveLocale maps Chinese variants and unknown locales', () {
      expect(
        AppLocalizations.resolveLocale(
          const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
        ),
        AppLocalizations.traditionalChineseLocale,
      );
      expect(
        AppLocalizations.resolveLocale(const Locale('zh', 'SG')),
        AppLocalizations.simplifiedChineseLocale,
      );
      expect(
        AppLocalizations.resolveLocale(const Locale('fr', 'FR')),
        AppLocalizations.englishLocale,
      );
    });

    test('locale storage conversion accepts only supported app locales', () {
      expect(
        AppLocalizations.localeStorageValue(const Locale('zh', 'SG')),
        'zh-CN',
      );
      expect(
        AppLocalizations.localeFromStorage('zh-TW'),
        AppLocalizations.traditionalChineseLocale,
      );
      expect(AppLocalizations.localeFromStorage('fr-FR'), isNull);
    });

    test('labels return current Traditional Chinese strings', () {
      const l10n = AppLocalizations(AppLocalizations.traditionalChineseLocale);

      expect(l10n.readingTextScaleLabel(0.9), '較小');
      expect(l10n.readingTextScaleLabel(1.0), '標準');
      expect(l10n.readingTextScaleLabel(1.2), '較大');
      expect(l10n.readingTextScaleLabel(1.4), '特大');
      expect(l10n.localeLabel(const Locale('zh', 'CN')), '简体中文');
      expect(l10n.audioArchiveLabel(true), '詞目音檔');
      expect(l10n.downloadApproximateSize('1.0 MB'), '大小約 1.0 MB');
    });
  });

  group('preference state functions', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test(
      'AppThemePreference parses storage values and exposes theme modes',
      () {
        expect(
          AppThemePreferenceX.fromStorageValue('amoled'),
          AppThemePreference.amoled,
        );
        expect(
          AppThemePreferenceX.fromStorageValue('bad-value'),
          AppThemePreference.system,
        );
        expect(AppThemePreference.amoled.storageValue, 'amoled');
        expect(AppThemePreference.amoled.materialThemeMode, ThemeMode.dark);
      },
    );

    test(
      'AppPreferences clamps and snaps reading text scale changes',
      () async {
        final preferences = AppPreferences();
        await preferences.initialize();

        await preferences.setReadingTextScale(0.2);
        expect(
          preferences.readingTextScale,
          AppPreferences.minReadingTextScale,
        );

        await preferences.setReadingTextScale(1.16);
        expect(preferences.readingTextScale, 1.2);

        await preferences.setReadingTextScale(9);
        expect(
          preferences.readingTextScale,
          AppPreferences.maxReadingTextScale,
        );
      },
    );

    test('LocaleProvider clears stored locale preferences', () async {
      SharedPreferences.setMockInitialValues({'interface_locale': 'zh-CN'});

      final provider = LocaleProvider();
      await provider.initialize();
      expect(provider.locale, AppLocalizations.simplifiedChineseLocale);

      await provider.clearLocalePreference();

      final preferences = await SharedPreferences.getInstance();
      expect(provider.locale, isNull);
      expect(preferences.getString('interface_locale'), isNull);
    });
  });
}

DictionaryEntry _entry({
  required int id,
  required String hanji,
  required String romanization,
  required String definition,
  List<String> variantChars = const [],
}) {
  return DictionaryEntry(
    id: id,
    type: '',
    hanji: hanji,
    romanization: romanization,
    category: '',
    audioId: '',
    variantChars: variantChars,
    hokkienSearch: '$hanji $romanization',
    mandarinSearch: definition,
    senses: [
      DictionarySense(partOfSpeech: '', definition: definition, examples: []),
    ],
  );
}
