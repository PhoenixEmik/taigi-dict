import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as glass;
import 'package:taigi_dict/features/settings/presentation/widgets/liquid_glass.dart';

OverlayEntry? _activeGlassNotification;

void showGlassNotification(
  BuildContext context, {
  required String message,
  bool isError = false,
  Duration duration = const Duration(milliseconds: 2600),
}) {
  final overlay = Overlay.maybeOf(context);
  if (overlay == null || message.isEmpty) {
    return;
  }

  _activeGlassNotification?.remove();
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) => _GlassNotificationOverlay(
      message: message,
      isError: isError,
      duration: duration,
      onDismissed: () {
        if (identical(_activeGlassNotification, entry)) {
          _activeGlassNotification = null;
        }
        entry.remove();
      },
    ),
  );
  _activeGlassNotification = entry;
  overlay.insert(entry);
}

class _GlassNotificationOverlay extends StatefulWidget {
  const _GlassNotificationOverlay({
    required this.message,
    required this.isError,
    required this.duration,
    required this.onDismissed,
  });

  final String message;
  final bool isError;
  final Duration duration;
  final VoidCallback onDismissed;

  @override
  State<_GlassNotificationOverlay> createState() =>
      _GlassNotificationOverlayState();
}

class _GlassNotificationOverlayState extends State<_GlassNotificationOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  Timer? _dismissTimer;
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
      reverseDuration: const Duration(milliseconds: 180),
    );
    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    _slide = Tween<Offset>(begin: const Offset(0, -0.45), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          ),
        );
    unawaited(_controller.forward());
    _dismissTimer = Timer(widget.duration, _dismiss);
  }

  Future<void> _dismiss() async {
    if (_dismissed) {
      return;
    }
    _dismissed = true;
    _dismissTimer?.cancel();
    if (mounted) {
      await _controller.reverse();
    }
    widget.onDismissed();
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top + 12;

    return Positioned(
      top: top,
      left: 18,
      right: 18,
      child: SafeArea(
        top: false,
        child: SlideTransition(
          position: _slide,
          child: FadeTransition(
            opacity: _fade,
            child: Align(
              alignment: Alignment.topCenter,
              child: GestureDetector(
                onTap: () => unawaited(_dismiss()),
                child: _GlassNotificationPill(
                  message: widget.message,
                  isError: widget.isError,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassNotificationPill extends StatelessWidget {
  const _GlassNotificationPill({required this.message, required this.isError});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isError
        ? CupertinoColors.systemRed.resolveFrom(context)
        : CupertinoColors.activeBlue.resolveFrom(context);
    final foreground = resolveLiquidGlassForeground(context);

    return Semantics(
      liveRegion: true,
      label: message,
      child: glass.GlassPanel(
        useOwnLayer: true,
        quality: glass.GlassQuality.premium,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        shape: const glass.LiquidRoundedSuperellipse(borderRadius: 999),
        settings: glass.LiquidGlassSettings(
          blur: 22,
          thickness: 22,
          glassColor: isDark
              ? Colors.black.withValues(alpha: 0.32)
              : Colors.white.withValues(alpha: 0.68),
          lightIntensity: 0.78,
          ambientStrength: 0.28,
          refractiveIndex: 1.18,
          saturation: isDark ? 1.22 : 1.08,
          chromaticAberration: 0.012,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isError
                  ? CupertinoIcons.xmark_circle_fill
                  : CupertinoIcons.check_mark_circled_solid,
              color: accent,
              size: 20,
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
