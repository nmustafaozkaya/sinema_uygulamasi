import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sinema_uygulamasi/components/buy_screen.dart';
import 'package:sinema_uygulamasi/components/cinemas.dart';
import 'package:sinema_uygulamasi/components/movie_preferences.dart';
import 'package:sinema_uygulamasi/components/movies.dart';
import 'package:sinema_uygulamasi/constant/app_text_style.dart';

class MovieDetails extends StatefulWidget {
  final Movie? currentMovie;

  const MovieDetails({super.key, this.currentMovie});

  @override
  State<MovieDetails> createState() => _MovieDetailsState();
}

class _MovieDetailsState extends State<MovieDetails> {
  Cinema? currentCinema;

  @override
  void initState() {
    super.initState();
    _loadCinema();
  }

  void _loadCinema() async {
    currentCinema = await RememberMoviePrefs.getRememberMovie();
    setState(() {}); // state'i güncelle
  }

  Widget buildStarRating(double rating, {double size = 24}) {
    int fullStars = rating.floor();
    bool hasHalfStar = (rating - fullStars) >= 0.5;
    int emptyStars = 5 - fullStars - (hasHalfStar ? 1 : 0);

    List<Widget> stars = [];

    for (var i = 0; i < fullStars; i++) {
      stars.add(Icon(Icons.star, size: size, color: Colors.amber));
    }
    if (hasHalfStar) {
      stars.add(Icon(Icons.star_half, size: size, color: Colors.amber));
    }
    for (var i = 0; i < emptyStars; i++) {
      stars.add(Icon(Icons.star_border, size: size, color: Colors.amber));
    }

    return Row(mainAxisSize: MainAxisSize.min, children: stars);
  }

  Widget buildMoviePoster(String posterUrl) {
    if (posterUrl.isEmpty || posterUrl == 'N/A') {
      return SizedBox.shrink();
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          posterUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(
              Icons.broken_image,
              size: 100,
              color: Colors.grey,
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final movie = widget.currentMovie;

    if (movie == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    double imdbScore = double.tryParse(movie.imdbRating) ?? 0.0;
    double starRating = (imdbScore / 10) * 5;

    return Scaffold(
      appBar: AppBar(
        title: Text(movie.title),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(width: 2, color: Colors.black),
                borderRadius: BorderRadius.circular(8),
              ),
              child: buildMoviePoster(movie.poster),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                movie.title,
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                movie.plot,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(FontAwesomeIcons.star),
                const SizedBox(width: 10),
                const Text(
                  "IMDb Rating",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                buildStarRating(starRating),
                const SizedBox(width: 8),
                Text(imdbScore.toStringAsFixed(1)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(FontAwesomeIcons.calendarDay),
                const SizedBox(width: 10),
                Text("Movie Year: ${movie.released}"),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(FontAwesomeIcons.clapperboard),
                const SizedBox(width: 10),
                Text("Genre: ${movie.genre}"),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(FontAwesomeIcons.clock),
                const SizedBox(width: 10),
                Text("Runtime: ${movie.runtime}"),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (currentCinema != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => buyScreen(currentMovie: movie),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select one cinemas')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
              child: Text('Buy Ticket', style: AppTextStyle.MIDDLE_BOLD_HEADER),
            ),
          ],
        ),
      ),
    );
  }
}
