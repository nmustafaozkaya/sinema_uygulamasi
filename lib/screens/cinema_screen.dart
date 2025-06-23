import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sinema_uygulamasi/components/cities.dart';
import 'package:sinema_uygulamasi/components/cinemas.dart';
import 'package:sinema_uygulamasi/components/movie_preferences.dart';
import 'package:sinema_uygulamasi/constant/app_text_style.dart';
import 'package:sinema_uygulamasi/api_connection/api_connection.dart';
import 'package:sinema_uygulamasi/components/movie_list_section.dart';
import 'package:sinema_uygulamasi/screens/all_cinemas.dart';

class CinemaScreen extends StatefulWidget {
  const CinemaScreen({super.key});

  @override
  State<CinemaScreen> createState() => _CinemaScreenState();
}

class _CinemaScreenState extends State<CinemaScreen> {
  List<City> cities = [];
  List<Cinema> cinemas = [];

  int? selectedCityId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCities();
  }

  Future<void> fetchCities() async {
    setState(() {
      isLoading = true;
    });

    try {
      final res = await http.get(
        Uri.parse(ApiConnection.cities),
        headers: {'Content-Type': 'application/json'},
      );

      if (res.statusCode == 200) {
        final resBody = jsonDecode(res.body);
        if (resBody['status'] == true) {
          final List<dynamic> data = resBody['data'];
          setState(() {
            cities = data.map((json) => City.fromJson(json)).toList();
            isLoading = false;
          });
        }
      } else {
        print('Şehirler çekilirken hata kodu: ${res.statusCode}');
      }
    } catch (e) {
      print('Şehirler çekilirken Exception: $e');
    }
  }

  Future<void> fetchCinemas(int cityId) async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(ApiConnection.cinemas(cityId)),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final resBody = jsonDecode(response.body);
        if (resBody['status'] == true) {
          final List<dynamic> data = resBody['data'];
          setState(() {
            cinemas = data.map((json) => Cinema.fromJson(json)).toList();
            selectedCityId = cityId;
            isLoading = false;
          });
        }
      } else {
        print('Sinemalar çekilirken hata kodu: ${response.statusCode}');
      }
    } catch (e) {
      print('Sinemalar çekilirken Exception: $e');
    }
  }

  void goBackToCities() {
    setState(() {
      selectedCityId = null;
      cinemas = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cinemas', style: AppTextStyle.TOP_HEADER_),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AllCinemas()),
            ),
            icon: Icon(Icons.movie),
          ),
        ],
        leading: selectedCityId != null
            ? IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: goBackToCities,
              )
            : null,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: selectedCityId == null
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
                  : cinemas.isEmpty
                  ? Center(child: Text('Bu şehirde sinema bulunamadı.'))
                  : ListView.builder(
                      itemCount: cinemas.length,
                      itemBuilder: (context, index) {
                        final cinema = cinemas[index];

                        return ListTile(
                          title: Text(cinema.cinemaName),
                          subtitle: Text(cinema.cinemaAddress),
                          onTap: () async {
                            await RememberMoviePrefs.saveRememberMovie(cinema);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MovieListSection(),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
    );
  }
}
