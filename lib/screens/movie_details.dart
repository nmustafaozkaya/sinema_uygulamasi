import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sinema_uygulamasi/constant/app_color_style.dart';
import 'package:sinema_uygulamasi/screens/buy_screen.dart';
import 'package:sinema_uygulamasi/components/movies.dart';
import 'package:sinema_uygulamasi/components/cinemas.dart';
import 'package:sinema_uygulamasi/components/showtimes.dart';

class MovieDetails extends StatefulWidget {
  static const String routeName = '/movie-details';

  final Movie? currentMovie;
  final bool isNowShowing;

  const MovieDetails({
    super.key,
    this.currentMovie,
    required this.isNowShowing,
  });

  @override
  State<MovieDetails> createState() => _MovieDetailsState();
}

class _MovieDetailsState extends State<MovieDetails> {
  Cinema? selectedCinema;
  Showtime? selectedShowtime;

  Widget _buildStarRating(double rating, {double size = 24}) {
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

  Widget _buildMoviePoster(String posterUrl) {
    if (posterUrl.isEmpty || posterUrl == 'N/A') {
      return Container(
        height: 300,
        color: AppColorStyle.appBarColor,
        child: const Center(
          child: Icon(
            Icons.image_not_supported,
            size: 100,
            color: AppColorStyle.secondaryAccent,
          ),
        ),
      );
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          posterUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 300,
              color: AppColorStyle.appBarColor,
              child: const Center(
                child: Icon(
                  Icons.broken_image,
                  size: 100,
                  color: AppColorStyle.secondaryAccent,
                ),
              ),
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
      return Scaffold(
        backgroundColor: AppColorStyle.scaffoldBackground,
        appBar: AppBar(
          backgroundColor: AppColorStyle.appBarColor,
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppColorStyle.primaryAccent),
        ),
      );
    }

    double imdbScore = double.tryParse(movie.imdbRating) ?? 0.0;
    double starRating = (imdbScore / 10) * 5;

    VoidCallback? buttonOnPressed;
    String buttonText;
    Color buttonColor;
    Color buttonTextColor = AppColorStyle.textPrimary;

    if (widget.isNowShowing) {
      buttonText = "Buy Ticket";
      buttonColor = Colors.amber;
      buttonOnPressed = () async {
        final result = await Navigator.push<Map<String, dynamic>>(
          context,
          MaterialPageRoute(
            builder: (context) => BuyScreen(
              currentMovie: movie,
              currentCinema: null,
              selectedShowtime: null,
            ),
          ),
        );

        if (result != null && mounted) {
          setState(() {
            selectedCinema = result['cinema'];
            selectedShowtime = result['showtime'];
          });
        }
      };
    } else {
      buttonText = "Buy Ticket (Coming Soon)";
      buttonColor = AppColorStyle.primaryAccent;
      buttonTextColor = AppColorStyle.textSecondary;
      buttonOnPressed = null;
    }

    return Scaffold(
      backgroundColor: AppColorStyle.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          "Movie Details",
          style: const TextStyle(color: AppColorStyle.textPrimary),
        ),
        backgroundColor: AppColorStyle.appBarColor,
        elevation: 0,
        foregroundColor: AppColorStyle.textPrimary,
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  width: 2,
                  color: AppColorStyle.primaryAccent,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _buildMoviePoster(movie.poster),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                movie.title,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColorStyle.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColorStyle.appBarColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                movie.plot,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColorStyle.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Icon(
                  FontAwesomeIcons.star,
                  size: 20,
                  color: Colors.amber,
                ),
                const SizedBox(width: 10),
                const Text(
                  "IMDb Rating:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColorStyle.textPrimary,
                  ),
                ),
                const SizedBox(width: 5),
                _buildStarRating(starRating, size: 20),
                const SizedBox(width: 8),
                Text(
                  imdbScore.toStringAsFixed(1),
                  style: const TextStyle(color: AppColorStyle.textPrimary),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  FontAwesomeIcons.calendarDay,
                  size: 18,
                  color: AppColorStyle.secondaryAccent,
                ),
                const SizedBox(width: 10),
                Text(
                  "Release Date: ${movie.releaseDate}",
                  style: const TextStyle(color: AppColorStyle.textPrimary),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  FontAwesomeIcons.clapperboard,
                  size: 18,
                  color: AppColorStyle.secondaryAccent,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Genre: ${movie.genre}",
                    style: const TextStyle(color: AppColorStyle.textPrimary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  FontAwesomeIcons.clock,
                  size: 18,
                  color: AppColorStyle.secondaryAccent,
                ),
                const SizedBox(width: 10),
                Text(
                  "Run Time: ${movie.runtime}",
                  style: const TextStyle(color: AppColorStyle.textPrimary),
                ),
              ],
            ),
            const SizedBox(height: 20),

            if (selectedCinema != null || selectedShowtime != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColorStyle.primaryAccent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Seçilen Rezervasyon',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColorStyle.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (selectedCinema != null)
                      Text(
                        'Sinema: ${selectedCinema!.cinemaName}',
                        style: const TextStyle(
                          color: AppColorStyle.textSecondary,
                        ),
                      ),
                    if (selectedShowtime != null)
                      Text(
                        'Seans: ${selectedShowtime!.hallname} - ${selectedShowtime!.startTime}',
                        style: const TextStyle(
                          color: AppColorStyle.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
            ],

            ElevatedButton(
              onPressed: buttonOnPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                buttonText,
                style: TextStyle(
                  color: buttonTextColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
