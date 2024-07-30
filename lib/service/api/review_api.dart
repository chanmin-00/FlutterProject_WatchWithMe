import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../model/movie.dart';
import '../../model/review.dart';
import 'package:http/http.dart' as http;

class ReviewApiService {
  static final String _baseUrl = dotenv.env['BASE_URL']!;

  static Future<Movie> fetchMovie(int id) async {
    final response =
        await http.get(Uri.parse('$_baseUrl/api/v1/movie/findOne/$id'));

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes))['data'];
      return Movie.fromJson(jsonResponse);
    } else {
      throw Exception('Failed to load movie');
    }
  }

  static Future<List<Review>> fetchReviews(int movieId, int page) async {
    final response = await http.get(
        Uri.parse('$_baseUrl/api/v1/review/findByMovie/$movieId?page=$page'));

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes))['data'];
      List<Review> newReviews = [];

      if (jsonResponse != null && jsonResponse is List) {
        newReviews =
            jsonResponse.map((review) => Review.fromJson(review)).toList();
      }

      return newReviews;
    } else {
      throw Exception('Failed to load reviews');
    }
  }

  static Future<Map<String, dynamic>> submitReview({
    required String email,
    required String reviewText,
    required int memberRating,
    required String memberRatingGenre,
    required int movieId,
  }) async {
    final url = Uri.parse('$_baseUrl/api/v1/review/write');

    final requestBody = jsonEncode({
      'email': email,
      'reviewText': reviewText,
      'memberRating': memberRating,
      'memberRatingGenre': memberRatingGenre,
      'movieId': movieId,
    });

    try {
      final response = await http.put(
        url,
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
        },
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {'success': true, 'message': responseData['message']};
      } else {
        final responseData = jsonDecode(response.body);
        return {
          'success': false,
          'message': responseData['message'] ?? 'Unknown error'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Failed to submit review: $e'};
    }
  }
}
