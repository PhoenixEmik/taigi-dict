import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hokkien_dictionary/core/constants/app_constants.dart';
import 'package:hokkien_dictionary/features/audio/data/download_service.dart';
import 'package:hokkien_dictionary/features/audio/domain/audio_archive.dart';
import 'package:hokkien_dictionary/features/dictionary/data/dictionary_database_builder_service.dart';

class OfflineDictionaryLibrary extends ChangeNotifier {
  OfflineDictionaryLibrary() {
    _downloadService.snapshot.addListener(notifyListeners);
  }

  final DownloadService _downloadService = DownloadService();
  final DictionaryDatabaseBuilderService _builderService =
      const DictionaryDatabaseBuilderService();

  bool _initialized = false;
  bool _initializationFailed = false;
  bool _sourceReady = false;

  bool get initialized => _initialized;

  bool get isSourceReady => _sourceReady;

  ValueListenable<DownloadSnapshot> get downloadListenable =>
      _downloadService.snapshot;

  DownloadSnapshot get downloadSnapshot => _downloadService.snapshot.value;

  DownloadState get downloadState => downloadSnapshot.state;

  String get fileName => AppConstants.dictionaryOdsFileName;

  String downloadStatus() {
    final snapshot = downloadSnapshot;
    if (snapshot.totalBytes > 0) {
      return '${formatBytes(snapshot.downloadedBytes)} / ${formatBytes(snapshot.totalBytes)}';
    }
    if (snapshot.downloadedBytes > 0) {
      return formatBytes(snapshot.downloadedBytes);
    }
    return fileName;
  }

  String downloadSpeed() {
    return formatBytesPerSecond(downloadSnapshot.speedBytesPerSecond);
  }

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    try {
      final sourceFile = await _builderService.locateDownloadedOdsFile();
      await sourceFile.parent.create(recursive: true);
      await _restoreDownloadSnapshot(sourceFile);
    } catch (_) {
      _initializationFailed = true;
    }

    _initialized = true;
    notifyListeners();
  }

  Future<AudioActionResult> handleDownloadAction() async {
    if (downloadState == DownloadState.downloading) {
      _downloadService.pause();
      return AudioActionResult(
        message: '已暫停下載 ${AppConstants.dictionaryOdsFileName}。',
      );
    }
    if (downloadState == DownloadState.completed && isSourceReady) {
      return const AudioActionResult();
    }
    return downloadSource();
  }

  Future<AudioActionResult> downloadSource() async {
    await initialize();
    if (_initializationFailed) {
      return const AudioActionResult(
        message: '目前無法初始化詞典原始檔儲存空間。',
        isError: true,
      );
    }

    if (_downloadService.isDownloading) {
      return const AudioActionResult();
    }

    final sourceFile = await _builderService.locateDownloadedOdsFile();
    final tempFile = File('${sourceFile.path}.download');

    try {
      await _downloadService.download(
        url: AppConstants.dictionaryOdsUrl,
        targetFile: tempFile,
        fallbackTotalBytes: 0,
      );

      if (await sourceFile.exists()) {
        await sourceFile.delete();
      }
      await tempFile.rename(sourceFile.path);
      final downloadedBytes = await sourceFile.length();
      _sourceReady = true;
      _downloadService.seed(
        DownloadSnapshot(
          state: DownloadState.completed,
          downloadedBytes: downloadedBytes,
          totalBytes: downloadedBytes,
          speedBytesPerSecond: 0,
        ),
      );
      notifyListeners();

      return AudioActionResult(
        message: '已下載詞典原始檔 ${AppConstants.dictionaryOdsFileName}。',
      );
    } on DioException catch (_) {
      if (downloadState == DownloadState.paused) {
        return const AudioActionResult();
      }
      return AudioActionResult(
        message: '下載詞典原始檔失敗：${downloadSnapshot.errorMessage ?? '網路連線中斷'}',
        isError: true,
      );
    } catch (error) {
      return AudioActionResult(message: '下載詞典原始檔失敗：$error', isError: true);
    }
  }

  Future<void> _restoreDownloadSnapshot(File sourceFile) async {
    if (await sourceFile.exists()) {
      final bytes = await sourceFile.length();
      _sourceReady = true;
      _downloadService.seed(
        DownloadSnapshot(
          state: DownloadState.completed,
          downloadedBytes: bytes,
          totalBytes: bytes,
          speedBytesPerSecond: 0,
        ),
      );
      return;
    }

    final tempFile = File('${sourceFile.path}.download');
    if (await tempFile.exists()) {
      final bytes = await tempFile.length();
      _sourceReady = false;
      _downloadService.seed(
        DownloadSnapshot(
          state: DownloadState.paused,
          downloadedBytes: bytes,
          totalBytes: bytes,
          speedBytesPerSecond: 0,
        ),
      );
      return;
    }

    _sourceReady = false;
    _downloadService.seed(const DownloadSnapshot.idle(totalBytes: 0));
  }

  @override
  void dispose() {
    _downloadService.dispose();
    super.dispose();
  }
}
