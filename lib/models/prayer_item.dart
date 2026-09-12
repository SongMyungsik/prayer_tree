import 'prayer_status.dart';

class PrayerItem {
  final int? id;
  final int categoryId;
  final String title;
  final String? personName;
  final String? description;
  final PrayerStatus status;
  final String createdAt;
  final String updatedAt;

  const PrayerItem({
    this.id,
    required this.categoryId,
    required this.title,
    this.personName,
    this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  PrayerItem copyWith({
    int? categoryId,
    String? title,
    String? personName,
    String? description,
    PrayerStatus? status,
    String? updatedAt,
  }) {
    return PrayerItem(
      id: id,
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      personName: personName ?? this.personName,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'category_id': categoryId,
      'title': title,
      'person_name': personName,
      'description': description,
      'status': status.name,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory PrayerItem.fromMap(Map<String, Object?> map) {
    return PrayerItem(
      id: map['id'] as int?,
      categoryId: map['category_id'] as int,
      title: map['title'] as String,
      personName: map['person_name'] as String?,
      description: map['description'] as String?,
      status: PrayerStatus.fromValue(map['status'] as String),
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }
}
