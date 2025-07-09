import 'dart:convert';
import 'package:http/http.dart' as http;
//
// Make sure this is the Movie class you are importing and using.
//

class Movie {
  final int id;
  final String title;
  final String releaseDate;
  final String runtime;
  final String genre;
  final String plot;
  final String language;
  final String poster;
  final String imdbRating;

  Movie({
    required this.id,
    required this.title,
    required this.releaseDate,
    required this.runtime,
    required this.genre,
    required this.plot,
    required this.language,
    required this.poster,
    required this.imdbRating,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      releaseDate: json['release_date'] ?? '',
      runtime: (json['duration'] != null) ? '${json['duration']} dk' : '',
      genre: json['genre'] ?? '',
      plot: json['description'] ?? '',
      language: json['language'] ?? '',
      poster: json['poster_url'] ?? '',
      imdbRating:
          json['imdb_raiting'] ??
          '', // Note: Typo in 'raiting' might need to match API
    );
  }
}

Future<List<Movie>> fetchMovies(String url) async {
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = jsonDecode(response.body);

    if (data['success'] == true &&
        data['data'] is Map<String, dynamic> &&
        data['data']['data'] is List) {
      final List<dynamic> moviesJson = data['data']['data'];

      return moviesJson
          .map((json) => Movie.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('API response format error or success is false: $data');
    }
  } else {
    throw Exception(
      'Failed to load movies from $url with status code: ${response.statusCode}',
    );
  }
}
