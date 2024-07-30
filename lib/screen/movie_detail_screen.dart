import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../model/movie.dart';
import '../../model/review.dart';
import '../../service/api/review_api.dart';
import '../service/api/member_api.dart';

class MovieDetailScreen extends StatefulWidget {
  final int movieId;

  MovieDetailScreen({required this.movieId});

  @override
  _MovieDetailScreenState createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  late Future<Movie> movie;
  List<Review> reviews = [];
  int currentPage = 1;
  bool isLoading = false;
  bool hasMoreReviews = true;
  String userEmail = '';
  bool isSubmittingReview = false;

  final TextEditingController reviewController = TextEditingController();
  final TextEditingController memberRatingGenreController =
      TextEditingController();
  double rating = 1.0;
  final List<double> ratingOptions = [1.0, 2.0, 3.0, 4.0, 5.0];
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    movie = ReviewApiService.fetchMovie(widget.movieId);
    fetchReviews(widget.movieId, currentPage);
    loadUserEmail();
  }

  Future<void> loadUserEmail() async {
    final userId = await secureStorage.read(key: 'userId');
    final token = await secureStorage.read(key: 'accessToken');

    if (userId != null && token != null) {
      final response = await MemberApiService.fetchUserEmail(userId, token);
      setState(() {
        userEmail = response;
      });
    }
  }

  Future<void> fetchReviews(int movieId, int page) async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      List<Review> newReviews =
          await ReviewApiService.fetchReviews(movieId, page);

      setState(() {
        reviews.addAll(newReviews);
        isLoading = false;
        hasMoreReviews = newReviews.isNotEmpty;
        if (hasMoreReviews) {
          currentPage++;
        }
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      throw Exception('Failed to load reviews');
    }
  }

  Future<void> _submitReview() async {
    setState(() {
      isSubmittingReview = true;
    });

    final reviewText = reviewController.text;
    final memberRatingGenre = memberRatingGenreController.text;

    if (userEmail.isNotEmpty && reviewText.isNotEmpty) {
      try {
        await ReviewApiService.submitReview(
          email: userEmail,
          reviewText: reviewText,
          memberRating: rating.toInt(),
          memberRatingGenre: memberRatingGenre,
          movieId: widget.movieId,
        );

        setState(() {
          isSubmittingReview = false;
          reviewController.clear();
          memberRatingGenreController.clear();
          rating = ratingOptions.first;
          fetchReviews(widget.movieId, currentPage);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review submitted successfully!')),
        );
      } catch (e) {
        setState(() {
          isSubmittingReview = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit review')),
        );
      }
    } else {
      setState(() {
        isSubmittingReview = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<Movie>(
          future: movie,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('');
            } else if (snapshot.hasError) {
              return const Text('Error', style: TextStyle(color: Colors.black));
            } else if (snapshot.hasData) {
              return Text(
                snapshot.data!.title,
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontStyle: FontStyle.italic,
                ),
              );
            } else {
              return const Text(
                'Movie Detail',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontStyle: FontStyle.italic,
                ),
              );
            }
          },
        ),
        backgroundColor: Colors.white,
        centerTitle: false,
      ),
      backgroundColor: Colors.white,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: FutureBuilder<Movie>(
                future: movie,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('Failed to load movie'));
                  } else if (snapshot.hasData) {
                    final movie = snapshot.data!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          movie.title,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontFamily: 'Pretendard',
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Release Year: ${movie.openYear}',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Genre: ${movie.genre}',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Rating: ${movie.userRating?.toString() ?? 'N/A'}',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Cast:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontFamily: 'Pretendard',
                          ),
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: movie.actors!.map((actor) {
                              return Card(
                                margin: EdgeInsets.symmetric(horizontal: 8),
                                color: Colors.deepPurple[50],
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.network(
                                      actor.imageUrl ??
                                          'https://picsum.photos/80/120',
                                      width: 80,
                                      height: 120,
                                      fit: BoxFit.cover,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        actor.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                          fontFamily: 'Pretendard',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Directors:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontFamily: 'Pretendard',
                          ),
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: movie.directors!.map((director) {
                              return Card(
                                margin: EdgeInsets.symmetric(horizontal: 8),
                                color: Colors.deepPurple[50],
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.network(
                                      director.imageUrl ??
                                          'https://picsum.photos/80/120',
                                      width: 80,
                                      height: 120,
                                      fit: BoxFit.cover,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        director.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                          fontFamily: 'Pretendard',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 32), // Space for review form
                        const Text(
                          'Write a Review:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontFamily: 'Pretendard',
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: reviewController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Your Review',
                          ),
                          maxLines: 4,
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: memberRatingGenreController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Genre Rating',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Text('Rating:'),
                            const SizedBox(width: 8),
                            DropdownButton<double>(
                              value: ratingOptions.contains(rating)
                                  ? rating
                                  : ratingOptions.first,
                              items: ratingOptions.map((e) {
                                return DropdownMenuItem<double>(
                                  value: e,
                                  child: Text(e.toString()),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  rating = value ?? ratingOptions.first;
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: isSubmittingReview ? null : _submitReview,
                          child: isSubmittingReview
                              ? const CircularProgressIndicator()
                              : const Text('Submit Review'),
                        ),
                      ],
                    );
                  } else {
                    return const Center(child: Text('No data'));
                  }
                },
              ),
            ),
          ),
          VerticalDivider(
            width: 1,
            color: Colors.deepPurple[50],
          ),
          Expanded(
            flex: 1,
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (scrollInfo.metrics.pixels ==
                        scrollInfo.metrics.maxScrollExtent &&
                    !isLoading &&
                    hasMoreReviews) {
                  fetchReviews(widget.movieId, currentPage);
                }
                return false;
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: reviews.length + (isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == reviews.length) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (reviews.isEmpty) {
                    return const Center(
                      child: Text(
                        'No reviews yet.',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          color: Colors.black,
                        ),
                      ),
                    );
                  }
                  final review = reviews[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 3,
                    color: Colors.deepPurple[50],
                    child: ListTile(
                      title: Text(
                        review.author,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontFamily: 'Pretendard',
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            review.reviewText ?? '',
                            style: const TextStyle(
                              fontFamily: 'Pretendard',
                              color: Colors.black,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                review.memberRating?.toString() ?? 'N/A',
                                style: const TextStyle(
                                  fontFamily: 'Pretendard',
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
