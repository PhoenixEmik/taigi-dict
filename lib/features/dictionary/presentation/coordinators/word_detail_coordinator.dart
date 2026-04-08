import 'package:flutter/material.dart';
import 'package:hokkien_dictionary/features/bookmarks/application/bookmark_store.dart';
import 'package:hokkien_dictionary/features/dictionary/data/dictionary_repository.dart';
import 'package:hokkien_dictionary/features/dictionary/domain/dictionary_models.dart';
import 'package:hokkien_dictionary/features/dictionary/presentation/screens/word_detail_screen.dart';
import 'package:hokkien_dictionary/offline_audio.dart';

class WordDetailCoordinator {
  const WordDetailCoordinator._();

  static Future<void> playClip({
    required OfflineAudioLibrary audioLibrary,
    required AudioArchiveType type,
    required String clipId,
    required ValueChanged<AudioActionResult> onActionResult,
  }) async {
    final result = await audioLibrary.playClip(type, clipId);
    onActionResult(result);
  }

  static Future<void> showWordDetail({
    required BuildContext context,
    required DictionaryEntry entry,
    required DictionaryRepository repository,
    required DictionaryBundle bundle,
    required OfflineAudioLibrary audioLibrary,
    required BookmarkStore bookmarkStore,
    required ValueChanged<AudioActionResult> onActionResult,
  }) async {
    Future<void> onPlayClip(AudioArchiveType type, String clipId) {
      return playClip(
        audioLibrary: audioLibrary,
        type: type,
        clipId: clipId,
        onActionResult: onActionResult,
      );
    }

    Future<void> onWordTapped(String word) async {
      final linkedEntry = repository.findLinkedEntry(bundle, word);
      if (linkedEntry == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('找不到詞條：$word')));
        return;
      }

      await showWordDetail(
        context: context,
        entry: linkedEntry,
        repository: repository,
        bundle: bundle,
        audioLibrary: audioLibrary,
        bookmarkStore: bookmarkStore,
        onActionResult: onActionResult,
      );
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => WordDetailScreen(
          entry: entry,
          audioLibrary: audioLibrary,
          bookmarkStore: bookmarkStore,
          onPlayClip: onPlayClip,
          onWordTapped: onWordTapped,
        ),
      ),
    );
  }
}
