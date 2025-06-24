import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sinema_uygulamasi/components/cities.dart';
import 'package:sinema_uygulamasi/components/cinemas.dart';
import 'package:sinema_uygulamasi/components/movie_preferences.dart';
import 'package:sinema_uygulamasi/components/movies.dart';
import 'package:sinema_uygulamasi/constant/app_text_style.dart';
import 'package:sinema_uygulamasi/api_connection/api_connection.dart';
import 'package:sinema_uygulamasi/components/movie_list_section.dart';

class CinemaScreen extends StatefulWidget {
  const CinemaScreen({Key? key}) : super(key: key);

  @override
  State<CinemaScreen> createState() => _CinemaScreenState();
}

class _CinemaScreenState extends State<CinemaScreen> {
  List<City> cities = [];
  List<Cinema> cinemas = [];
  List<Movie> movies = [];

  int? selectedCityId;
  bool isLoading = false;
  bool isLoadingMovies = false;

  @override
  void initState() {
    super.initState();
    fetchCities();
  }

  Future<void> fetchCities() async {
    setState(() => isLoading = true);

    try {
      final response = await http.get(
        Uri.parse(ApiConnection.cities),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true && data['data'] is List) {
          // Added type check
          setState(() {
            cities = (data['data'] as List)
                .map((json) => City.fromJson(json))
                .toList();
            isLoading = false;
          });
        } else {
          print('Şehirler API yanıt formatı hatası veya statüs false: $data');
          setState(() => isLoading = false);
        }
      } else {
        print('Şehirler çekilirken HTTP hatası: ${response.statusCode}');
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('Şehirler çekilirken genel hata: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchCinemas(int cityId) async {
    setState(() {
      isLoading = true;
      selectedCityId = cityId;
      cinemas = [];
      movies = [];
    });

    try {
      final response = await http.get(
        Uri.parse(ApiConnection.cinemas(cityId)),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true && data['data'] is List) {
          // Added type check
          setState(() {
            cinemas = (data['data'] as List)
                .map((json) => Cinema.fromJson(json))
                .toList();
            isLoading = false;
          });
        } else {
          print('Sinemalar API yanıt formatı hatası veya statüs false: $data');
          setState(() => isLoading = false);
        }
      } else {
        print('Sinemalar çekilirken HTTP hatası: ${response.statusCode}');
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('Sinemalar çekilirken genel hata: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchMoviesByCinema(int cityId, int cinemaId) async {
    setState(() {
      isLoadingMovies = true;
      movies = [];
    });

    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConnection.hostConnection}/cities/$cityId/cinemas/$cinemaId',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true && data['data'] is Map) {
          // Added type check
          final showtimes =
              data['data']['showtimes'] as List? ??
              []; // Handle null or non-list
          final movieIds = showtimes
              .map<int>((e) => e['movie_id'] as int)
              .toSet() // Use toSet to get unique IDs
              .toList();

          List<Movie> fetchedMovies = [];
          for (var id in movieIds) {
            // --- CRUCIAL FIX HERE ---
            // Use ApiConnection.movieById(id) to fetch each movie by its ID
            final movieRes = await http.get(
              Uri.parse(
                ApiConnection.movieById(id),
              ), // <-- Use the specific movie ID here!
              headers: {'Content-Type': 'application/json'},
            );

            if (movieRes.statusCode == 200) {
              final movieData = jsonDecode(movieRes.body);
              // Ensure 'data' exists and is a Map for a single movie object
              if (movieData['status'] == true && movieData['data'] is Map) {
                fetchedMovies.add(Movie.fromJson(movieData['data']));
              } else {
                print(
                  'Film ID $id için API yanıt formatı hatası veya statüs false: $movieData',
                );
              }
            } else {
              print(
                'Film ID $id çekilirken HTTP hatası: ${movieRes.statusCode}',
              );
            }
          }

          setState(() {
            movies = fetchedMovies;
            isLoadingMovies = false;
          });
          return; // Exit after successful fetch and state update
        } else {
          print(
            'Sinema detayları API yanıt formatı hatası veya statüs false: $data',
          );
        }
      } else {
        print(
          'Sinema detayları çekilirken HTTP hatası: ${response.statusCode}',
        );
      }
      // If any error or unexpected format, ensure loading states are false and movies list is empty
      setState(() {
        movies = [];
        isLoadingMovies = false;
      });
    } catch (e) {
      print('Filmler çekilirken genel hata: $e');
      setState(() {
        movies = [];
        isLoadingMovies = false;
      });
    }
  }

  void backToCities() {
    setState(() {
      selectedCityId = null;
      cinemas = [];
      movies = [];
      isLoadingMovies = false; // Reset movie loading state too
      isLoading = false; // This will be set true again by fetchCities if called
    });
    fetchCities(); // Re-fetch cities when going back
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cinemas', style: AppTextStyle.TOP_HEADER_),
        leading: selectedCityId != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: backToCities,
              )
            : null,
      ),
      body:
          isLoading // Overall loading for cities/cinemas
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child:
                  selectedCityId ==
                      null // Show cities if no city selected
                  ? ListView.builder(
                      itemCount: cities.length,
                      itemBuilder: (context, index) {
                        final city = cities[index];
                        return ListTile(
                          title: Text(city.name),
                          onTap: () => fetchCinemas(city.id),
                        );
                      },
                    )
                  : movies
                        .isNotEmpty // If a cinema is selected AND movies are loaded
                  ? isLoadingMovies // Show loading indicator specifically for movies
                        ? const Center(child: CircularProgressIndicator())
                        : MovieListSection(movies: movies) // Display movies
                  : ListView.builder(
                      // Show cinemas if a city is selected but no movies yet
                      itemCount: cinemas.length,
                      itemBuilder: (context, index) {
                        final cinema = cinemas[index];
                        return ListTile(
                          title: Text(cinema.cinemaName),
                          subtitle: Text(cinema.cinemaAddress),
                          onTap: () async {
                            await RememberMoviePrefs.saveRememberMovie(cinema);
                            await fetchMoviesByCinema(
                              selectedCityId!,
                              cinema.cinemaId,
                            );
                          },
                        );
                      },
                    ),
            ),
    );
  }
}
