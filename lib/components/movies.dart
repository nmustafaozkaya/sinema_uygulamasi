import 'dart:convert';
import 'package:http/http.dart' as http;

class Movie {
  final int id;
  final String title;
  final String year;
  final String released;
  final String runtime;
  final String genre;
  final String plot;
  final String language;
  final String poster;
  final String imdbRating;

  Movie({
    required this.id,
    required this.title,
    required this.year,
    required this.released,
    required this.runtime,
    required this.genre,
    required this.plot,
    required this.language,
    required this.poster,
    required this.imdbRating,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      title: json['title'] ?? '',
      year: json['release_date']?.toString().split('-').first ?? '',
      released: json['release_date'] ?? '',
      runtime: '${json['duration']} dk',
      genre: json['genre'] ?? '',
      plot: json['description'] ?? '',
      language: json['language'] ?? '',
      poster: json['poster_url'] ?? '',
      imdbRating: json['imdb_raiting'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'Title': title,
      'Year': year,
      'Released': released,
      'Runtime': runtime,
      'Genre': genre,
      'Plot': plot,
      'Language': language,
      'Poster': poster,
      'imdbRating': imdbRating,
    };
  }
}

Future<List<Movie>> fetchMovies(String apiUrl) async {
  try {
    final res = await http.get(Uri.parse(apiUrl));

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);

      if (data.containsKey('future_movies') && data['future_movies'] is List) {
        final List<dynamic> movieList = data['future_movies'];
        List<Movie> movies = movieList.map((json) {
          final movie = Movie.fromJson(json);
          return movie;
        }).toList();
        return movies;
      }

      if (data.containsKey('status') &&
          data['status'] == true &&
          data.containsKey('data') &&
          data['data'] is List) {
        final List<dynamic> movieList = data['data'];
        List<Movie> movies = movieList
            .map((json) => Movie.fromJson(json))
            .toList();
        return movies;
      }

      print('Beklenmedik JSON formatı: $data');
      return [];
    } else {
      print('Sunucu hatası: ${res.statusCode}');
      return [];
    }
  } catch (e) {
    print('Bir hata oluştu: $e');
    return [];
  }
}
