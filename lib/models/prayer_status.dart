enum PrayerStatus {
  praying,
  answered,
  paused;

  static PrayerStatus fromValue(String value) =>
      PrayerStatus.values.firstWhere((s) => s.name == value, orElse: () => PrayerStatus.praying);

  String get label => switch (this) {
        PrayerStatus.praying => '기도 중',
        PrayerStatus.answered => '응답됨',
        PrayerStatus.paused => '보류',
      };
}
