class DailyCommitment {
  final String id;
  final String date; // yyyy-MM-dd
  final String text;
  final String status; // active | success | partial | missed
  final int morningCreatedAt;
  final int? eveningReviewAt;

  const DailyCommitment({
    required this.id,
    required this.date,
    required this.text,
    this.status = 'active',
    required this.morningCreatedAt,
    this.eveningReviewAt,
  });

  bool get isActive => status == 'active';
  bool get isSuccess => status == 'success';
  bool get isReviewed => eveningReviewAt != null;

  DailyCommitment copyWith({
    String? id,
    String? date,
    String? text,
    String? status,
    int? morningCreatedAt,
    int? eveningReviewAt,
  }) {
    return DailyCommitment(
      id: id ?? this.id,
      date: date ?? this.date,
      text: text ?? this.text,
      status: status ?? this.status,
      morningCreatedAt: morningCreatedAt ?? this.morningCreatedAt,
      eveningReviewAt: eveningReviewAt ?? this.eveningReviewAt,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'date': date,
    'text': text,
    'status': status,
    'morning_created_at': morningCreatedAt,
    'evening_review_at': eveningReviewAt,
  };

  factory DailyCommitment.fromMap(Map<String, dynamic> map) => DailyCommitment(
    id: map['id'] as String,
    date: map['date'] as String,
    text: map['text'] as String,
    status: map['status'] as String? ?? 'active',
    morningCreatedAt: map['morning_created_at'] as int,
    eveningReviewAt: map['evening_review_at'] as int?,
  );
}
