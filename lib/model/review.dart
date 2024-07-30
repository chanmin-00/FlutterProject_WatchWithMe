class Review {
  final String? reviewText; // Null safety 적용, review 글
  final double? memberRating; // Null safety 적용, 평점
  final String? memberRatingGenre; // Null safety 적용, 장르
  final String author; // 리뷰 작성자

  Review({
    required this.reviewText,
    required this.memberRating,
    required this.memberRatingGenre,
    required this.author,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      reviewText: json['reviewText'] as String?,
      memberRating: (json['memberRating'] as num?)?.toDouble(),
      memberRatingGenre: json['memberRatingGenre'] as String?,
      author: json['author'] as String,
    );
  }
}
