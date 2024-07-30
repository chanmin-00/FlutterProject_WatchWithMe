import 'movie.dart';

class Actor {
  final String name; // 배우명
  final List<Movie> movies; // 출연 영화 목록
  final String? imageUrl; // 배우 이미지 URL, 추가 필요

  Actor({required this.name, required this.movies, this.imageUrl});

  factory Actor.fromJson(Map<String, dynamic> json) {
    final movies = (json['movies'] as List<dynamic>?)
            ?.map((movie) => Movie.fromJson(movie as Map<String, dynamic>))
            .toList() ??
        [];

    return Actor(
      name: json['name'],
      movies: movies,
    );
  }
}
