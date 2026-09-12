class PrayerCategory {
  final int? id;
  final String name;
  final int color;
  final int sortOrder;

  const PrayerCategory({
    this.id,
    required this.name,
    required this.color,
    required this.sortOrder,
  });

  PrayerCategory copyWith({int? id, String? name, int? color, int? sortOrder}) {
    return PrayerCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'color': color,
      'sort_order': sortOrder,
    };
  }

  factory PrayerCategory.fromMap(Map<String, Object?> map) {
    return PrayerCategory(
      id: map['id'] as int?,
      name: map['name'] as String,
      color: map['color'] as int,
      sortOrder: map['sort_order'] as int,
    );
  }
}
