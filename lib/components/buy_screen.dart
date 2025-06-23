import 'package:flutter/material.dart';
import 'package:sinema_uygulamasi/components/cinemas.dart';
import 'package:sinema_uygulamasi/components/movie_preferences.dart';
import 'package:sinema_uygulamasi/components/movies.dart';

class buyScreen extends StatefulWidget {
  final Movie? currentMovie;
  const buyScreen({super.key, this.currentMovie});

  @override
  State<buyScreen> createState() => _buyScreenState();
}

class _buyScreenState extends State<buyScreen> {
  Cinema? currentCinema;

  @override
  void initState() {
    super.initState();
    _loadCinema();
  }

  void _loadCinema() async {
    Cinema? cinema = await RememberMoviePrefs.getRememberMovie();
    setState(() {
      currentCinema = cinema;
    });
  }

  Widget buildMoviePoster(String posterUrl) {
    if (posterUrl.isEmpty || posterUrl == 'N/A') {
      return SizedBox(
        width: 120,
        height: 180,
        child: Icon(Icons.broken_image, size: 60, color: Colors.grey),
      );
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          posterUrl,
          width: 120,
          height: 180,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return SizedBox(
              width: 120,
              height: 180,
              child: Icon(Icons.broken_image, size: 60, color: Colors.grey),
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final movie = widget.currentMovie;

    return Scaffold(
      appBar: AppBar(title: const Text('Payment'), centerTitle: false),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start, // önemli
              children: [
                movie != null
                    ? buildMoviePoster(movie.poster)
                    : const SizedBox.shrink(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start, // önemli
                    crossAxisAlignment:
                        CrossAxisAlignment.start, // opsiyonel ama iyi olur
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment
                              .start, // yazılar soldan hizalansın
                          children: [
                            Text(
                              '${movie?.title}',
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text('${movie?.genre}'),
                            Text('${movie?.runtime}'),
                            Text('${movie?.released}'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
