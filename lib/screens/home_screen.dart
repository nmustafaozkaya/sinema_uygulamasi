import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sinema_uygulamasi/api_connection/api_connection.dart';
import 'package:sinema_uygulamasi/components/auto_ImageSlider.dart';
import 'package:sinema_uygulamasi/components/promotions_screen.dart';
import 'package:sinema_uygulamasi/components/user.dart';
import 'package:sinema_uygulamasi/components/movies.dart';
import 'package:sinema_uygulamasi/screens/movie_details.dart';
import 'package:sinema_uygulamasi/components/get_promotions.dart';
import 'package:sinema_uygulamasi/screens/movies_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

Widget buildMoviePoster(String posterUrl) {
  if (posterUrl.isEmpty || posterUrl == 'N/A') {
    return Container(
      color: Colors.grey.shade300,
      child: const Center(
        child: Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
      ),
    );
  } else {
    return Image.network(
      posterUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey.shade300,
          child: const Center(
            child: Icon(Icons.broken_image, size: 60, color: Colors.grey),
          ),
        );
      },
    );
  }
}

Future<List<Movie>> fetchMovies(String url) async {
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data['status'] == true && data['data'] is List) {
      return (data['data'] as List)
          .map((json) => Movie.fromJson(json as Map<String, dynamic>))
          .toList();
    } else if (data['status'] == true && data['data'] is Map) {
      return [Movie.fromJson(data['data'] as Map<String, dynamic>)];
    } else {
      throw Exception('API response format error or status is false: $data');
    }
  } else {
    throw Exception(
      'Failed to load movies from $url with status code: ${response.statusCode}',
    );
  }
}

class HomeScreen extends StatelessWidget {
  final User currentUser;
  const HomeScreen({super.key, required this.currentUser});

  // Vizyondaki Filmler bölümü
  Widget showMoviesContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: Text(
                'Now Showing Movies',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const moviesScreen(isComingSoon: false),
                  ),
                );
              },
              child: const Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: Text(
                  'All',
                  style: TextStyle(
                    fontSize: 20,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.bold,
                  ),
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

  // Çok Yakındaki Filmler bölümü
  Widget showMoviesComingSoon(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: Text(
                'Coming Soon Movies',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const moviesScreen(isComingSoon: true),
                  ),
                );
              },
              child: const Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: Text(
                  'All',
                  style: TextStyle(
                    fontSize: 20,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        FutureBuilder<List<Movie>>(
          future: fetchMovies(ApiConnection.futureMovies),
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
                              isNowShowing: false,
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

  Widget showpromotions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: Text(
                'Promotions',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PromotionsScreen(),
                  ),
                );
              },
              child: const Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: Text(
                  'All',
                  style: TextStyle(
                    fontSize: 20,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        FutureBuilder<List<Promotion>>(
          future: fetchPromotions(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 180,
                child: Center(child: CircularProgressIndicator()),
              );
            } else if (snapshot.hasError ||
                !snapshot.hasData ||
                snapshot.data!.isEmpty) {
              return const SizedBox.shrink();
            } else {
              final promotions = snapshot.data!;
              return SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  itemCount: promotions.length,
                  itemBuilder: (context, index) {
                    final promotion = promotions[index];
                    return HorizontalPromotionCard(promotion: promotion);
                  },
                ),
              );
            }
          },
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
        title: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: SizedBox(
            height: AppBar().preferredSize.height * 0.8,
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
                  const SizedBox(height: 20),
                  showMoviesComingSoon(context),
                  const SizedBox(height: 20),
                  showpromotions(context),
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
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PromotionsScreen(),
                        ),
                      );
                    },
                    child: ListTile(
                      leading: const Icon(FontAwesomeIcons.gift),
                      title: const Text('Promotions'),
                      trailing: const Icon(Icons.arrow_right),
                    ),
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
