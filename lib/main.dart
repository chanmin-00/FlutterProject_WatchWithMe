import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_project/screen/movie_list_screen.dart';


Future<void> main() async {
  await dotenv.load(); // 환경 변수 로드
  runApp(MyApp());
}

class MyApp extends StatelessWidget  {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Watch With Me',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        fontFamily: 'NotoSansKR',
      ),
      home: MovieListScreen(),
    );
  }
}



