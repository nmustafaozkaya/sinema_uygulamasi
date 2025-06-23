import 'package:flutter/material.dart';
import 'package:sinema_uygulamasi/components/movies.dart';
import 'package:sinema_uygulamasi/screens/movie_details.dart';
import 'package:sinema_uygulamasi/constant/app_text_style.dart';

Widget _buildMoviePoster(String posterUrl) {
  if (posterUrl.isEmpty || posterUrl == 'N/A') {
    return Center(child: Icon(Icons.movie, size: 50, color: Colors.grey));
  } else {
    return Image.network(
      posterUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        print('Resim yüklenemedi: $posterUrl - Hata: $error');
        return Center(
          child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
        );
      },
    );
  }
}

class MovieListSection extends StatefulWidget {
  final int? cinemaId;

  const MovieListSection({Key? key, this.cinemaId}) : super(key: key);

  @override
  State<MovieListSection> createState() => _MovieListSectionState();
}

class _MovieListSectionState extends State<MovieListSection> {
  late Future<List<Movie>> _moviesFuture;

  @override
  void initState() {
    super.initState();
    _moviesFuture = _fetchMoviesForSection();
  }

  Future<List<Movie>> _fetchMoviesForSection() async {
    if (widget.cinemaId != null) {
      return fetchMovies();
    } else {
      return fetchMovies();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        title: Text('List of All Movies', style: AppTextStyle.TOP_HEADER_),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: FutureBuilder<List<Movie>>(
                future: _moviesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Hata: ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text("Film bulunamadı."));
                  } else {
                    final movies = snapshot.data!;

                    return GridView.builder(
                      itemCount: movies.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 0.65,
                      ),
                      itemBuilder: (context, index) {
                        final movie = movies[index];
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    MovieDetails(currentMovie: movie),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(12),
                                    ),
                                    child: _buildMoviePoster(movie.poster),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    movie.title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
