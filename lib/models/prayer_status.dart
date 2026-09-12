enum PrayerStatus {
  urgent,
  praying,
  answered,
  paused;

  static PrayerStatus fromValue(String value) =>
      PrayerStatus.values.firstWhere((s) => s.name == value, orElse: () => PrayerStatus.praying);

  String get label => switch (this) {
        PrayerStatus.urgent => '긴급',
        PrayerStatus.praying => '기도 중',
        PrayerStatus.answered => '응답됨',
        PrayerStatus.paused => '보류',
      };
}
