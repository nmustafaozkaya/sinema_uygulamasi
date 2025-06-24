import 'package:flutter/material.dart';
import 'package:sinema_uygulamasi/components/auto_ImageSlider.dart';
import 'package:sinema_uygulamasi/components/user.dart';
import 'package:sinema_uygulamasi/components/movies.dart';
import 'package:sinema_uygulamasi/screens/movie_details.dart';

class HomeScreen extends StatelessWidget {
  final User currentUser;
  const HomeScreen({super.key, required this.currentUser});

  Widget buildMoviePoster(String posterUrl) {
    if (posterUrl.isEmpty || posterUrl == 'N/A') {
      return SizedBox.shrink();
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

  Widget showMoviesContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'List of Movies',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<List<Movie>>(
            future: fetchMovies(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text("Hata: ${snapshot.error}"));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("Film bulunamadı."));
              } else {
                final movies = snapshot.data!;

                return GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: movies.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                                child: buildMoviePoster(movie.poster),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                movie.title,
                                style: const TextStyle(
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
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              color: Colors.black,
            );
          },
        ),
        title: Center(
          child: SizedBox(
            height: AppBar().preferredSize.height * 0.7,
            child: Image.asset('assets/images/logox.png', fit: BoxFit.contain),
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Explore Movies',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  AutoImageSlider(),
                  const SizedBox(height: 10),
                  showMoviesContent(context),
                ],
              ),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Container(
              height: 120.0,
              width: double.infinity,
              color: Colors.lightBlueAccent.shade100,
              child: Align(
                alignment: Alignment
                    .bottomLeft, // Align the padded image to bottom-left
                child: Padding(
                  // Wrap the Image with Padding for top margin
                  padding: const EdgeInsets.only(
                    top: 20.0,
                  ), // Adjust this value for desired top "margin"
                  child: Image.asset(
                    'assets/images/logox.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                physics: const ClampingScrollPhysics(),
                children: [
                  ListTile(
                    leading: const Icon(Icons.place),
                    title: const Text('Konum'),
                    trailing: const Icon(Icons.arrow_right),
                  ),
                  ExpansionTile(
                    leading: const Icon(Icons.adjust),
                    title: const Text('Hakkımızda'),
                    trailing: const Icon(Icons.arrow_drop_down),
                    children: [
                      ListTile(
                        title: const Text('Biz Kimiz?'),
                        onTap: () => Navigator.pop(context),
                      ),
                      ListTile(
                        title: const Text('Sertifikalarımız'),
                        onTap: () => Navigator.pop(context),
                      ),
                      ListTile(
                        title: const Text('Misyonumuz'),
                        onTap: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
