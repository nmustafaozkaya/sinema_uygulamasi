import 'package:flutter/material.dart';
import 'package:sinema_uygulamasi/api_connection/api_connection.dart';
import 'package:sinema_uygulamasi/components/auto_ImageSlider.dart';
import 'package:sinema_uygulamasi/components/user.dart';
import 'package:sinema_uygulamasi/components/movies.dart';
import 'package:sinema_uygulamasi/screens/movie_details.dart';
import 'package:sinema_uygulamasi/screens/movies_screen.dart';

class HomeScreen extends StatelessWidget {
  final User currentUser;
  const HomeScreen({super.key, required this.currentUser});

  Widget showMoviesContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Text(
                'Now Showing Movies',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const moviesScreen()),
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: Text(
                  'All',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        FutureBuilder<List<Movie>>(
          future: fetchMovies(ApiConnection.movies),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 180,
                child: Center(child: CircularProgressIndicator()),
              );
            } else if (snapshot.hasError) {
              return SizedBox(
                height: 180,
                child: Center(child: Text("Hata: ${snapshot.error}")),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const SizedBox(
                height: 180,
                child: Center(child: Text("Film bulunamadı.")),
              );
            } else {
              final movies = snapshot.data!;
              return SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  itemCount: movies.length,
                  itemBuilder: (context, index) {
                    final movie = movies[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MovieDetails(
                              currentMovie: movie,
                              isNowShowing: true,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: 120,
                        margin: const EdgeInsets.only(right: 12),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: buildMoviePoster(movie.poster),
                        ),
                      ),
                    );
                  },
                ),
              );
            }
          },
        ),
      ],
    );
  }

  Widget showMoviesComingSoon(BuildContext context) {
    return Column();
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
              alignment: Alignment.bottomLeft,
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
              height: 150.0,
              width: double.infinity,
              color: Colors.lightBlueAccent.shade100,
              padding: const EdgeInsets.only(
                left: 16.0,
                top: 16.0,
                bottom: 8.0,
              ),
              alignment: Alignment.bottomLeft,
              child: Image.asset(
                'assets/images/logox.png',
                height: 60,
                fit: BoxFit.contain,
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
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
