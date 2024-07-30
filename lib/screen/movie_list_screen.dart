import 'package:flutter/material.dart';
import 'package:flutter_project/screen/sign_up_screen.dart';
import 'package:flutter_project/service/api/movie_api.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'login_screen.dart';
import '../model/movie.dart';
import 'movie_detail_screen.dart';

class MovieListScreen extends StatefulWidget {
  final bool isLoggedIn;
  final String? email;

  MovieListScreen({this.isLoggedIn = false, this.email});

  @override
  _MovieListScreenState createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  List<Movie> _movies = [];
  List<Movie> _recommendedMovies = [];
  int _currentPage = 1;
  int _totalPages = 1;
  String _searchQuery = '';
  String _genre = '';
  String _openYear = '';
  int _userRatingHigh = 5;
  int _userRatingLow = 0;
  String _sortCriteria = 'title';
  String _personSearch = '';
  bool _isLoading = false;
  bool _isLoggedIn = false;
  String? _email;
  bool _isFilterVisible = true;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _isLoggedIn = widget.isLoggedIn;
    _email = widget.email;
    _fetchMovies(_currentPage);
    _fetchRecommendedMovies();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _fetchMovies(int page) async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final moviesData = await MovieApiService.fetchTotalMovies(page);
      setState(() {
        _movies.addAll(moviesData['movies']);
        _totalPages = moviesData['totalPages'];
      });
    } catch (e) {
      throw Exception('Failed to fetch movies: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _fetchRecommendedMovies() async {
    try {
      setState(() {
        _recommendedMovies = [];
        // 추천 영화 데이터를 가져오는 로직 추가
      });
    } catch (e) {
      throw Exception('Failed to fetch recommended movies: $e');
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.minScrollExtent) {
      if (!_isFilterVisible) {
        setState(() {
          _isFilterVisible = true;
        });
      }
    } else {
      if (_isFilterVisible) {
        setState(() {
          _isFilterVisible = false;
        });
      }
    }

    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && !_isLoading) {
      if (_currentPage < _totalPages) {
        _currentPage++;
        _fetchMovies(_currentPage);
      }
    }
  }

  void _applyFilters() {
    _currentPage = 1;
    _movies.clear();
    _fetchMovies(_currentPage);
  }

  Future<void> _logout() async {
    await FlutterSecureStorage().delete(key: 'accessToken');
    setState(() {
      _isLoggedIn = false;
      _email = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Text(
              'Watch With Me',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                fontSize: 20.0,
              ),
            ),
            SizedBox(width: 10.0),
            Expanded(
              child: Text(
                '각종 최신 영화 정보를 한눈에! 우리와 함께 확인해보아요.',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 14.0,
                  color: Colors.black54,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        actions: [
          if (_isLoggedIn)
            TextButton(
              onPressed: _logout,
              child: Text('로그아웃', style: TextStyle(color: Colors.black)),
            )
          else
            TextButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
                if (result != null && result['isLoggedIn']) {
                  setState(() {
                    _isLoggedIn = result['isLoggedIn'];
                    _email = result['email'];
                  });
                }
              },
              child: Text('로그인', style: TextStyle(color: Colors.black)),
            ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SignupScreen()),
              );
            },
            child: Text('회원가입', style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () {
              // 마이페이지 버튼 동작
            },
            child: Text('마이페이지', style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () {
              // 서비스 소개 버튼 동작
            },
            child: Text('서비스 소개', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWideScreen = constraints.maxWidth > 600;
          return Row(
            children: [
              Expanded(
                flex: isWideScreen ? 3 : 4,
                child: Column(
                  children: [
                    Visibility(
                      visible: _isFilterVisible,
                      child: _buildSearchAndFilter(),
                    ),
                    Expanded(
                      child: _movies.isEmpty
                          ? Center(child: CircularProgressIndicator())
                          : GridView.builder(
                              controller: _scrollController,
                              padding: EdgeInsets.all(8.0),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                childAspectRatio: 2 / 3,
                                crossAxisSpacing: 8.0,
                                mainAxisSpacing: 8.0,
                              ),
                              itemCount: _movies.length + 1,
                              itemBuilder: (context, index) {
                                if (index == _movies.length) {
                                  return _isLoading ? Center(child: CircularProgressIndicator()) : SizedBox.shrink();
                                }
                                final movie = _movies[index];
                                return Card(
                                  color: Colors.deepPurple[50],
                                  elevation: 5,
                                  margin: EdgeInsets.symmetric(vertical: 8.0),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => MovieDetailScreen(movieId: movie.movieId),
                                        ),
                                      );
                                    },
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Container(
                                            width: double.infinity,
                                            color: Colors.grey[300],
                                            child: Icon(Icons.image, size: 50, color: Colors.grey[700]),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                movie.title,
                                                style: const TextStyle(
                                                  fontFamily: 'Pretendard',
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16.0,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                              SizedBox(height: 4.0),
                                              Text(
                                                '${movie.genre} | ${movie.openYear}',
                                                style: const TextStyle(
                                                  fontFamily: 'Pretendard',
                                                  fontSize: 14.0,
                                                ),
                                              ),
                                              SizedBox(height: 4.0),
                                              Text(
                                                '평점: ${movie.userRating?.toString() ?? 'N/A'}',
                                                style: const TextStyle(
                                                  fontFamily: 'Pretendard',
                                                  fontSize: 14.0,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ),
                  ],
                ),
              ),
              if (isWideScreen) ...[
                const VerticalDivider(),
                Expanded(
                  flex: 1,
                  child: Container(
                    color: const Color(0xFFFFF0),
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildUserInfo(),
                        const SizedBox(height: 20.0),
                        const Text(
                          '오늘의 추천 영화',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.deepPurple,
                          ),
                        ),
                        const Divider(color: Colors.deepPurple),
                        Expanded(
                          child: _recommendedMovies.isEmpty
                              ? const Center(
                                  child: Text(
                                    '추천 영화가 없습니다.',
                                    style: TextStyle(
                                      fontFamily: 'Pretendard',
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: _recommendedMovies.length,
                                  itemBuilder: (context, index) {
                                    final movie = _recommendedMovies[index];
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10.0),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 5.0,
                                          ),
                                        ],
                                      ),
                                      margin: EdgeInsets.symmetric(vertical: 8.0),
                                      child: ListTile(
                                        contentPadding: EdgeInsets.all(8.0),
                                        title: Text(
                                          movie.title,
                                          style: const TextStyle(
                                            fontFamily: 'Pretendard',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16.0,
                                          ),
                                        ),
                                        trailing: Container(
                                          width: 40,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius: BorderRadius.circular(5.0),
                                          ),
                                          child: Icon(Icons.image, size: 40, color: Colors.grey[700]),
                                        ),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => MovieDetailScreen(movieId: movie.movieId),
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildUserInfo() {
    if (_isLoggedIn) {
      return Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5.0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '반갑습니다, $_email님!',
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
            const SizedBox(height: 10.0),
            const Text(
              '내 정보',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 16.0,
              ),
            ),
            // 추가적인 사용자 정보 위젯을 여기다 추가
          ],
        ),
      );
    } else {
      return Center(
        child: ElevatedButton(
          onPressed: () {
            // 로그인 버튼 클릭 시 동작
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.black, backgroundColor: Colors.white,
            side: const BorderSide(color: Colors.black),
          ),
          child: const Text('로그인 해주세요', style: TextStyle(color: Colors.black)),
        ),
      );
    }
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Card(
        color: Colors.white, // 배경색을 흰색으로 설정
        elevation: 4.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        child: Padding(
          padding: const EdgeInsets.all(8.0), // 패딩 최소화
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: '영화 제목', // 필터 설명 추가
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(vertical: 6.0, horizontal: 6.0),
                      ),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          _personSearch = value;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: '인물 검색', // 필터 설명 추가
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(vertical: 6.0, horizontal: 6.0),
                      ),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          _openYear = value;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: '개봉 연도', // 필터 설명 추가
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(vertical: 6.0, horizontal: 6.0),
                      ),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _genre,
                      onChanged: (value) {
                        setState(() {
                          _genre = value ?? '';
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: '장르', // 필터 설명 추가
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(vertical: 6.0, horizontal: 6.0),
                      ),
                      items: const [
                        DropdownMenuItem(value: '', child: Text('모든 장르')),
                        DropdownMenuItem(value: 'Action', child: Text('액션')),
                        DropdownMenuItem(value: 'Drama', child: Text('드라마')),
                        DropdownMenuItem(value: 'Comedy', child: Text('코미디')),
                      ],
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _sortCriteria,
                      onChanged: (value) {
                        setState(() {
                          _sortCriteria = value ?? 'title';
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: '정렬 기준', // 필터 설명 추가
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(vertical: 6.0, horizontal: 6.0),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'title', child: Text('제목순')),
                        DropdownMenuItem(value: 'latest', child: Text('최신순')),
                        DropdownMenuItem(value: 'rating', child: Text('평점순')),
                      ],
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '평점 범위',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]), // 필터 설명
                        ),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 2.0,
                            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6.0),
                          ),
                          child: RangeSlider(
                            values: RangeValues(_userRatingLow.toDouble(), _userRatingHigh.toDouble()),
                            min: 0,
                            max: 5,
                            divisions: 5,
                            labels: RangeLabels(
                              _userRatingLow.toString(),
                              _userRatingHigh.toString(),
                            ),
                            onChanged: (RangeValues values) {
                              setState(() {
                                _userRatingLow = values.start.round();
                                _userRatingHigh = values.end.round();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.0), // 필터와 버튼 간의 간격
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0), // 버튼 패딩 축소
                  ),
                  child: const Text('적용', style: TextStyle(fontSize: 14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
