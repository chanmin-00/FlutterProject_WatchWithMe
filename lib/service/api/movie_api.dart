import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../../model/movie.dart';

class MovieApiService {
  static final String _baseUrl = dotenv.env['BASE_URL']!;

  static Future<Map<String, dynamic>> fetchTotalMovies(int page) async {
    final response =
        await http.get(Uri.parse('$_baseUrl/api/v1/movie/findList?page=$page'));

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse =
          jsonDecode(utf8.decode(response.bodyBytes));

      if (jsonResponse['isSuccess'] == true) {
        List<dynamic> moviesList = jsonResponse['data']['movieResponseDtoList'];
        List<Movie> movies =
            moviesList.map((movie) => Movie.fromJson(movie)).toList();
        int totalPages = jsonResponse['data']['totalPage'];

        return {
          'movies': movies,
          'totalPages': totalPages,
        };
      } else {
        throw Exception('Failed to fetch movies: ${jsonResponse['message']}');
      }
    } else {
      throw Exception('Failed to load movies');
    }
  }
}
