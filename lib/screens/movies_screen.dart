import 'package:flutter/material.dart';
import 'package:sinema_uygulamasi/api_connection/api_connection.dart';
import 'package:sinema_uygulamasi/components/movies.dart';
import 'package:sinema_uygulamasi/constant/app_text_style.dart';
import 'package:sinema_uygulamasi/screens/movie_details.dart';

Widget buildMoviePoster(String posterUrl) {
  if (posterUrl.isEmpty || posterUrl == 'N/A') {
    return Center(
      child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
    );
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
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
    );
  }
}

Widget _buildMovieGridSliver(BuildContext context, String apiurl) {
  return FutureBuilder<List<Movie>>(
    future: fetchMovies(apiurl),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return SliverFillRemaining(
          child: Center(child: CircularProgressIndicator()),
        );
      } else if (snapshot.hasError) {
        return SliverFillRemaining(
          child: Center(child: Text("Hata: ${snapshot.error}")),
        );
      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return SliverFillRemaining(
          child: Center(child: Text("Film bulunamadı.")),
        );
      } else {
        final movies = snapshot.data!;

        return SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.6,
          ),
          delegate: SliverChildBuilderDelegate((context, index) {
            final movie = movies[index];
            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        MovieDetails(currentMovie: movie, isNowShowing: true),
                  ),
                );
              },
              child: Card(
                elevation: 0,
                color: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: buildMoviePoster(movie.poster),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        movie.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      movie.runtime,
                      style: TextStyle(
                        fontWeight: FontWeight.w300,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      movie.genre.split(',')[0].trim(),
                      style: TextStyle(
                        fontWeight: FontWeight.w300,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          }, childCount: movies.length),
        );
      }
    },
  );
}

class _CategoryHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  _CategoryHeaderDelegate({
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GestureDetector(
            onTap: () => onCategorySelected('Now Showing'),
            child: Text(
              'Now Showing',
              style: AppTextStyle.BASIC_HEADER_.copyWith(
                fontWeight: selectedCategory == 'Now Showing'
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: selectedCategory == 'Now Showing'
                    ? Colors.blue
                    : Colors.black,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => onCategorySelected('Coming Soon'),
            child: Text(
              'Coming Soon',
              style: AppTextStyle.BASIC_HEADER_.copyWith(
                fontWeight: selectedCategory == 'Coming Soon'
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: selectedCategory == 'Coming Soon'
                    ? Colors.blue
                    : Colors.black,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => onCategorySelected('Pre Order'),
            child: Text(
              'Pre Order',
              style: AppTextStyle.BASIC_HEADER_.copyWith(
                fontWeight: selectedCategory == 'Pre Order'
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: selectedCategory == 'Pre Order'
                    ? Colors.blue
                    : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 48.0;
  @override
  double get minExtent => 48.0;

  @override
  bool shouldRebuild(_CategoryHeaderDelegate oldDelegate) {
    return oldDelegate.selectedCategory != selectedCategory;
  }
}

class moviesScreen extends StatefulWidget {
  const moviesScreen({super.key});

  @override
  State<moviesScreen> createState() => _moviesScreenState();
}

class _moviesScreenState extends State<moviesScreen> {
  String selectedCategory = 'Now Showing';

  void _onCategorySelected(String category) {
    setState(() {
      selectedCategory = category;
    });
  }

  bool isNowPlaying = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('All Movies'),
        backgroundColor: Colors.white,
      ),
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            delegate: _CategoryHeaderDelegate(
              selectedCategory: selectedCategory,
              onCategorySelected: _onCategorySelected,
            ),
            floating: false,
            pinned: false,
          ),
          SliverPadding(
            padding: const EdgeInsets.all(12),
            sliver: Builder(
              builder: (context) {
                if (selectedCategory == 'Now Showing') {
                  isNowPlaying = true;
                  return _buildMovieGridSliver(context, ApiConnection.movies);
                } else if (selectedCategory == 'Coming Soon') {
                  isNowPlaying = false;
                  return _buildMovieGridSliver(
                    context,
                    ApiConnection.futureMovies,
                  );
                } else if (selectedCategory == 'Pre Order') {
                  return SliverFillRemaining(
                    child: Center(
                      child: Text('No Pre Order movies available.'),
                    ),
                  );
                } else {
                  return SliverFillRemaining(
                    child: Center(child: Text('Seçim bulunamadı.')),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
