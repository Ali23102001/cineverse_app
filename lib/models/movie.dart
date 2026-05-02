class Movie {
  final int id;
  final String title;
  final String? posterPath;
  final String? backdropPath;
  final double voteAverage;
  final String overview;
  final String releaseDate;
  final List<int> genreIds;
  bool isFavorite;
  bool inWatchlist;

  Movie({
    required this.id,
    required this.title,
    this.posterPath,
    this.backdropPath,
    required this.voteAverage,
    required this.overview,
    required this.releaseDate,
    required this.genreIds,
    this.isFavorite = false,
    this.inWatchlist = false,
  });

  factory Movie.fromJson(Map<String, dynamic> j) => Movie(
        id: j['id'],
        title: j['title'] ?? '',
        posterPath: j['poster_path'],
        backdropPath: j['backdrop_path'],
        voteAverage: (j['vote_average'] as num).toDouble(),
        overview: j['overview'] ?? '',
        releaseDate: j['release_date'] ?? '',
        genreIds: List<int>.from(j['genre_ids'] ?? []),
      );

  String get posterUrl => posterPath != null
      ? 'https://image.tmdb.org/t/p/w500$posterPath'
      : 'https://via.placeholder.com/500x750?text=No+Image';

  String get backdropUrl => backdropPath != null
      ? 'https://image.tmdb.org/t/p/w780$backdropPath'
      : posterUrl;

  String get year =>
      releaseDate.length >= 4 ? releaseDate.substring(0, 4) : '';
}
