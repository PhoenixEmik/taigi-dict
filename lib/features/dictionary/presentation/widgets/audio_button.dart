import 'package:flutter/material.dart';
import 'package:hokkien_dictionary/offline_audio.dart';

class AudioButton extends StatelessWidget {
  const AudioButton({
    super.key,
    required this.type,
    required this.audioId,
    required this.audioLibrary,
    required this.onPressed,
    this.compact = false,
  });

  final AudioArchiveType type;
  final String audioId;
  final OfflineAudioLibrary audioLibrary;
  final Future<void> Function(AudioArchiveType type, String clipId) onPressed;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isLoading = audioLibrary.isClipLoading(type, audioId);
    final isPlaying = audioLibrary.isClipPlaying(type, audioId);
    final archiveReady = audioLibrary.isArchiveReady(type);
    const buttonSize = 48.0;
    final clipLabel = type == AudioArchiveType.word ? '詞目音檔' : '例句音檔';
    final actionLabel = switch ((isLoading, isPlaying, archiveReady)) {
      (true, _, _) => '正在載入$clipLabel',
      (false, true, _) => '停止播放$clipLabel',
      (false, false, true) => '播放$clipLabel',
      (false, false, false) => '下載$clipLabel',
    };

    return Semantics(
      button: true,
      enabled: !isLoading,
      label: actionLabel,
      child: Tooltip(
        message: actionLabel,
        child: SizedBox(
          width: buttonSize,
          height: buttonSize,
          child: FilledButton.tonal(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF0E2F35).withValues(alpha: 0.08),
              foregroundColor: const Color(0xFF0E2F35),
              padding: EdgeInsets.zero,
              minimumSize: const Size(48, 48),
            ),
            onPressed: isLoading ? null : () => onPressed(type, audioId),
            child: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    isPlaying
                        ? Icons.stop_circle_outlined
                        : archiveReady
                        ? Icons.volume_up_outlined
                        : Icons.download_outlined,
                    size: compact ? 20 : 22,
                  ),
          ),
        ),
      ),
    );
  }
}
