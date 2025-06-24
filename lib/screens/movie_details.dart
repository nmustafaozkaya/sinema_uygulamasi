import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sinema_uygulamasi/components/buy_screen.dart';
import 'package:sinema_uygulamasi/components/cinemas.dart';
import 'package:sinema_uygulamasi/components/movie_preferences.dart';
import 'package:sinema_uygulamasi/components/movies.dart';

class MovieDetails extends StatefulWidget {
  final Movie? currentMovie;
  final bool isNowShowing; // This flag determines button behavior

  const MovieDetails({
    super.key,
    this.currentMovie,
    required this.isNowShowing,
  });

  @override
  State<MovieDetails> createState() => _MovieDetailsState();
}

class _MovieDetailsState extends State<MovieDetails> {
  Cinema? currentCinema; // To store the selected cinema

  @override
  void initState() {
    super.initState();
    _loadCinema(); // Load saved cinema preference when the screen initializes
  }

  // Asynchronously loads the remembered cinema from preferences
  void _loadCinema() async {
    currentCinema = await RememberMoviePrefs.getRememberMovie();
    // After loading, update the UI to reflect if a cinema is selected
    if (mounted) {
      // Check if the widget is still in the widget tree
      setState(() {});
    }
  }

  // Helper widget to build star ratings based on a 5-point scale
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

  // Helper widget to build the movie poster, handling empty/N/A URLs
  Widget _buildMoviePoster(String posterUrl) {
    if (posterUrl.isEmpty || posterUrl == 'N/A') {
      // Placeholder for missing poster
      return Container(
        height: 300, // Fixed height for consistency
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
            // Error placeholder if image fails to load
            return Container(
              height: 300, // Fixed height for consistency
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
    final movie = widget.currentMovie;

    // Show a loading indicator or error if movie data is null
    if (movie == null) {
      return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            foregroundColor: Colors.black,
          ),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Calculate IMDb score and convert to 5-star rating
    double imdbScore = double.tryParse(movie.imdbRating) ?? 0.0;
    double starRating = (imdbScore / 10) * 5;

    // --- Dynamic button properties based on isNowShowing ---
    VoidCallback? buttonOnPressed;
    String buttonText;
    Color buttonColor;
    Color buttonTextColor = Colors.white; // Default text color for button

    if (widget.isNowShowing) {
      buttonText = "Buy Tickets"; // "Satın Al"
      buttonColor = Colors.amber;
      buttonOnPressed = () {
        if (currentCinema != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => buyScreen(currentMovie: movie),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Please select a cinema first.',
              ), // "Lütfen önce bir sinema seçin."
              backgroundColor: Colors.red,
            ),
          );
        }
      };
    } else {
      buttonText = "Coming Soon"; // "Gelecek"
      buttonColor = Colors.grey; // Grey out the button for coming soon
      buttonOnPressed = null; // Disable the button, no navigation
      // If you want a message when 'Coming Soon' button is tapped:
      // buttonOnPressed = () {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(content: Text('This movie is coming soon!')),
      //   );
      // };
    }
    // --- End of dynamic button properties ---

    return Scaffold(
      appBar: AppBar(
        title: Text(movie.title),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(), // Prevents unnecessary bouncing
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Movie Poster
            Container(
              decoration: BoxDecoration(
                border: Border.all(width: 2, color: Colors.black),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _buildMoviePoster(movie.poster),
            ),
            const SizedBox(height: 16),

            // Movie Title
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

            // Movie Plot/Description
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

            // IMDb Rating
            Row(
              children: [
                const Icon(
                  FontAwesomeIcons.star,
                  size: 20,
                  color: Colors.amber,
                ), // Star icon for rating
                const SizedBox(width: 10),
                const Text(
                  "IMDb Rating:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 5),
                _buildStarRating(starRating), // Custom star rating widget
                const SizedBox(width: 8),
                Text(imdbScore.toStringAsFixed(1)), // Display raw IMDb score
              ],
            ),
            const SizedBox(height: 12),

            // Movie Release Year/Date
            Row(
              children: [
                const Icon(FontAwesomeIcons.calendarDay, size: 20),
                const SizedBox(width: 10),
                Text("Release Date: ${movie.released}"),
              ],
            ),
            const SizedBox(height: 10),

            // Movie Genre
            Row(
              children: [
                const Icon(FontAwesomeIcons.clapperboard, size: 20),
                const SizedBox(width: 10),
                Text("Genre: ${movie.genre}"),
              ],
            ),
            const SizedBox(height: 10),

            // Movie Runtime
            Row(
              children: [
                const Icon(FontAwesomeIcons.clock, size: 20),
                const SizedBox(width: 10),
                Text("Runtime: ${movie.runtime}"),
              ],
            ),
            const SizedBox(height: 20),

            // --- Buy Tickets / Coming Soon Button ---
            ElevatedButton(
              onPressed:
                  buttonOnPressed, // Uses the dynamically set callback (null for disabled)
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor, // Uses the dynamically set color
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                buttonText, // Uses the dynamically set text
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
