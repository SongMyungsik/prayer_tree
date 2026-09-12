import 'package:flutter/material.dart';

import '../models/prayer_status.dart';
import '../theme/app_theme.dart';

Color statusColor(PrayerStatus status) {
  return switch (status) {
    PrayerStatus.praying => accentColor,
    PrayerStatus.answered => answeredColor,
    PrayerStatus.paused => pausedColor,
  };
}

class StatusBadge extends StatelessWidget {
  final PrayerStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
