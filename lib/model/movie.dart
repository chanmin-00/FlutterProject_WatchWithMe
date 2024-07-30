import 'actor.dart';
import 'director.dart';

class Movie {
  final int movieId;
  final String title;
  final String openYear;
  final double? userRating; // Null safety 적용
  final String genre;
  final List<Actor>? actors; // Null safety 적용
  final List<Director>? directors; // Null safety 적용

  Movie({
    required this.movieId,
    required this.title,
    required this.openYear,
    required this.userRating,
    required this.genre,
    required this.actors,
    required this.directors,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    final actorList = (json['movieActorDtoList'] as List<dynamic>?)
            ?.map((actor) {
              if (actor is Map<String, dynamic> &&
                  actor['actorResponseDto'] != null) {
                return Actor.fromJson(
                    actor['actorResponseDto'] as Map<String, dynamic>);
              }
              return null;
            })
            .whereType<Actor>()
            .toList() ??
        [];

    final directorList = (json['movieDirectorDtoList'] as List<dynamic>?)
            ?.map((director) {
              if (director is Map<String, dynamic> &&
                  director['directorResponseDto'] != null) {
                return Director.fromJson(
                    director['directorResponseDto'] as Map<String, dynamic>);
              }
              return null;
            })
            .whereType<Director>() // null 필터링
            .toList() ??
        []; // null인 경우 빈 리스트로 초기화

    return Movie(
      movieId: json['movieId'] as int,
      title: json['title'] as String,
      openYear: json['openYear'] as String,
      userRating: (json['userRating'] as num?)?.toDouble(),
      // num을 double로 변환
      genre: json['genre'] as String,
      actors: actorList,
      directors: directorList,
    );
  }
}
