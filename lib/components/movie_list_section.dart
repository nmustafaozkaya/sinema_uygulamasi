// lib/components/movie_list_section.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sinema_uygulamasi/components/movies.dart';
import 'package:sinema_uygulamasi/screens/movie_details.dart';

class MovieListSection extends StatelessWidget {
  final List<Movie> movies;
  final Function(Movie) onMovieTap;
  final bool isForNowShowing;

  const MovieListSection({
    super.key,
    required this.movies,
    required this.onMovieTap,
    required this.isForNowShowing,
  });

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) {
      return const Center(child: Text('Film bulunamadı.'));
    }

    return ListView.builder(
      itemCount: movies.length,
      itemBuilder: (context, index) {
        final movie = movies[index];

        return ListTile(
          leading: (movie.poster.isNotEmpty && movie.poster != 'N/A')
              ? Image.network(movie.poster, width: 50, fit: BoxFit.cover)
              : const Icon(Icons.movie),
          title: Text(movie.title),
          subtitle: Text(DateFormat('dd.MM.yyyy').format(movie.releaseDate)),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MovieDetails(
                  currentMovie: movie,
                  isNowShowing: isForNowShowing,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
