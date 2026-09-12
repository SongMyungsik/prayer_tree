class ProgressUpdate {
  final int? id;
  final int itemId;
  final String date;
  final String content;
  final String createdAt;

  const ProgressUpdate({
    this.id,
    required this.itemId,
    required this.date,
    required this.content,
    required this.createdAt,
  });

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'item_id': itemId,
      'date': date,
      'content': content,
      'created_at': createdAt,
    };
  }

  factory ProgressUpdate.fromMap(Map<String, Object?> map) {
    return ProgressUpdate(
      id: map['id'] as int?,
      itemId: map['item_id'] as int,
      date: map['date'] as String,
      content: map['content'] as String,
      createdAt: map['created_at'] as String,
    );
  }
}
