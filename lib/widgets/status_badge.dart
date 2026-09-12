import 'package:flutter/material.dart';

import '../models/prayer_status.dart';
import '../theme/app_theme.dart';

Color statusColor(PrayerStatus status) {
  return switch (status) {
    PrayerStatus.urgent => Colors.red,
    PrayerStatus.praying => accentColor,
    PrayerStatus.answered => answeredColor,
    PrayerStatus.paused => pausedColor,
  };
}

class StatusBadge extends StatefulWidget {
  final PrayerStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  State<StatusBadge> createState() => _StatusBadgeState();
}

class _StatusBadgeState extends State<StatusBadge> with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  bool get _isUrgent => widget.status == PrayerStatus.urgent;

  @override
  void initState() {
    super.initState();
    _syncController();
  }

  @override
  void didUpdateWidget(covariant StatusBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncController();
  }

  void _syncController() {
    if (_isUrgent && _controller == null) {
      _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))
        ..repeat(reverse: true);
    } else if (!_isUrgent && _controller != null) {
      _controller!.dispose();
      _controller = null;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = statusColor(widget.status);
    final badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _isUrgent ? color : color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        widget.status.label,
        style: TextStyle(
          color: _isUrgent ? Colors.white : color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );

    final controller = _controller;
    if (controller == null) return badge;

    return FadeTransition(
      opacity: Tween(begin: 1.0, end: 0.3).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      ),
      child: badge,
    );
  }
}
