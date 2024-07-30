import 'package:flutter_project/model/review.dart';

class Member {
  final int memberId;
  final String email;
  final String name;
  final String mobile;
  final List<String>? favoriteGenre;
  final List<String>? favoriteActor;
  final List<String>? favoriteDirector;
  final List<Review>? reviewList;

  Member({
    required this.memberId,
    required this.email,
    required this.name,
    required this.mobile,
    required this.favoriteGenre,
    required this.favoriteActor,
    required this.favoriteDirector,
    required this.reviewList,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    final reviewList = (json['reviewList'] as List<dynamic>?)
            ?.map((review) => Review.fromJson(review as Map<String, dynamic>))
            .toList() ??
        [];

    return Member(
      memberId: json['memberId'] as int,
      email: json['email'] as String,
      name: json['name'] as String,
      mobile: json['mobile'] as String,
      favoriteGenre: (json['favoriteGenre'] as List<dynamic>?)
              ?.map((genre) => genre as String)
              .toList() ??
          [],
      favoriteActor: (json['favoriteActor'] as List<dynamic>?)
              ?.map((actor) => actor as String)
              .toList() ??
          [],
      favoriteDirector: (json['favoriteDirector'] as List<dynamic>?)
              ?.map((director) => director as String)
              .toList() ??
          [],
      reviewList: reviewList,
    );
  }
}
