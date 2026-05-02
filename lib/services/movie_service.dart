import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

class MovieService {
  static const _key = '1576fe0c64fd7dd98be461233764f9ac';
  static const _base = 'https://api.themoviedb.org/3';

  // Map of genre id → name
  static const Map<int, String> genres = {
    28: 'Action', 12: 'Adventure', 16: 'Animation',
    35: 'Comedy', 80: 'Crime', 99: 'Documentary',
    18: 'Drama', 10751: 'Family', 14: 'Fantasy',
    36: 'History', 27: 'Horror', 10402: 'Music',
    9648: 'Mystery', 10749: 'Romance', 878: 'Sci-Fi',
    10770: 'TV Movie', 53: 'Thriller', 10752: 'War',
    37: 'Western',
  };

  Future<List<Movie>> fetchPopular({int page = 1}) =>
      _fetch('$_base/movie/popular?api_key=$_key&page=$page');

  Future<List<Movie>> fetchTopRated({int page = 1}) =>
      _fetch('$_base/movie/top_rated?api_key=$_key&page=$page');

  Future<List<Movie>> fetchNowPlaying({int page = 1}) =>
      _fetch('$_base/movie/now_playing?api_key=$_key&page=$page');

  Future<List<Movie>> fetchUpcoming({int page = 1}) =>
      _fetch('$_base/movie/upcoming?api_key=$_key&page=$page');

  Future<List<Movie>> searchMovies(String query) =>
      _fetch('$_base/search/movie?api_key=$_key&query=${Uri.encodeComponent(query)}');

  Future<List<Movie>> fetchSimilar(int movieId) =>
      _fetch('$_base/movie/$movieId/similar?api_key=$_key');

  Future<List<Movie>> _fetch(String url) async {
    final res = await http.get(Uri.parse(url));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return (data['results'] as List).map((m) => Movie.fromJson(m)).toList();
    }
    throw Exception('API Error ${res.statusCode}');
  }
}
