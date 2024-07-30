import 'movie.dart';

class Director {
  final String name; // 감독명
  final List<Movie> movies; // 감독 작품 목록
  final String? imageUrl; // 감독 이미지 URL, 추가 필요

  Director({required this.name, required this.movies, this.imageUrl});

  factory Director.fromJson(Map<String, dynamic> json) {
    final movies = (json['movies'] as List<dynamic>?)
            ?.map((movie) => Movie.fromJson(movie as Map<String, dynamic>))
            .toList() ??
        [];

    return Director(
      name: json['name'],
      movies: movies,
    );
  }
}
