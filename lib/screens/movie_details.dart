import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sinema_uygulamasi/screens/buy_screen.dart';
// import 'package:sinema_uygulamasi/components/cinemas.dart'; // No longer needed
import 'package:sinema_uygulamasi/components/movies.dart';

class MovieDetails extends StatelessWidget {
  // Changed to StatelessWidget
  final Movie? currentMovie;
  final bool isNowShowing;

  const MovieDetails({
    super.key,
    this.currentMovie,
    required this.isNowShowing,
  });

  // Helper function for building the star rating
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

  // Helper function for building the movie poster
  Widget _buildMoviePoster(String posterUrl) {
    if (posterUrl.isEmpty || posterUrl == 'N/A') {
      return Container(
        height: 300,
        color: Colors.grey.shade300,
        child: const Center(
          child: Icon(Icons.image_not_supported, size: 100, color: Colors.grey),
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
              color: Colors.grey.shade300,
              child: const Center(
                child: Icon(Icons.broken_image, size: 100, color: Colors.grey),
              ),
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Access properties directly, without 'widget.'
    final movie = currentMovie;

    if (movie == null) {
      return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            foregroundColor: Colors.black,
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    double imdbScore = double.tryParse(movie.imdbRating) ?? 0.0;
    double starRating = (imdbScore / 10) * 5;

    VoidCallback? buttonOnPressed;
    String buttonText;
    Color buttonColor;
    Color buttonTextColor = Colors.white;

    if (isNowShowing) {
      buttonText = "Buy Tickets";
      buttonColor = Colors.amber;
      // The button now directly navigates to the BuyScreen without checking for a cinema
      buttonOnPressed = () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BuyScreen(currentMovie: movie),
          ),
        );
      };
    } else {
      buttonText = "Buy Tickets (Currently Unavailable)";
      buttonColor = Colors.grey;
      buttonOnPressed = null;
    }

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
              child: _buildMoviePoster(movie.poster),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                movie.title,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
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
                const Icon(
                  FontAwesomeIcons.star,
                  size: 20,
                  color: Colors.amber,
                ),
                const SizedBox(width: 10),
                const Text(
                  "IMDb Rating:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 5),
                _buildStarRating(starRating),
                const SizedBox(width: 8),
                Text(imdbScore.toStringAsFixed(1)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(FontAwesomeIcons.calendarDay, size: 20),
                const SizedBox(width: 10),
                Text("Release Date: ${movie.releaseDate}"),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(FontAwesomeIcons.clapperboard, size: 20),
                const SizedBox(width: 10),
                Text("Genre: ${movie.genre}"),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(FontAwesomeIcons.clock, size: 20),
                const SizedBox(width: 10),
                Text("Runtime: ${movie.runtime}"),
              ],
            ),
            const SizedBox(height: 20),
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
