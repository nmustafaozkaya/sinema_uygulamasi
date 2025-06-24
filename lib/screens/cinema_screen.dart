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
  const CinemaScreen({super.key});

  @override
  State<CinemaScreen> createState() => _CinemaScreenState();
}

class _CinemaScreenState extends State<CinemaScreen> {
  List<City> cities = [];
  List<Cinema> allCinemas = [];
  List<Cinema> displayedCinemas = [];
  int? selectedCityId;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchCities();
    fetchAllCinemas();
  }

  Future<void> fetchCities() async {
    final response = await http.get(Uri.parse(ApiConnection.cities));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == true) {
        setState(() {
          cities = (data['data'] as List)
              .map((json) => City.fromJson(json))
              .toList();
        });
      }
    }
  }

  Future<void> fetchAllCinemas() async {
    setState(() => isLoading = true);
    final response = await http.get(Uri.parse(ApiConnection.allCinemasapi));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == true) {
        setState(() {
          allCinemas = (data['data'] as List)
              .map((json) => Cinema.fromJson(json))
              .toList();
          displayedCinemas = allCinemas;
        });
      }
    }
    setState(() => isLoading = false);
  }

  void filterCinemasByCity(int? cityId) {
    setState(() {
      selectedCityId = cityId;
      if (cityId == null) {
        displayedCinemas = allCinemas;
      } else {
        displayedCinemas = allCinemas
            .where((cinema) => cinema.cityId == cityId)
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cinemas', style: AppTextStyle.TOP_HEADER_),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: DropdownButtonHideUnderline(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: DropdownButton<int?>(
                        value: selectedCityId,
                        hint: Text("Şehir Seçin"),
                        onChanged: (value) {
                          filterCinemasByCity(value);
                        },
                        items: [
                          DropdownMenuItem<int?>(
                            value: null,
                            child: Row(
                              children: [
                                Icon(Icons.public, color: Colors.black),
                                SizedBox(width: 8),
                                Text("Tümü"),
                              ],
                            ),
                          ),
                          ...cities.map((city) {
                            return DropdownMenuItem<int?>(
                              value: city.id,
                              child: Row(
                                children: [
                                  Icon(Icons.location_city, color: Colors.blue),
                                  SizedBox(width: 8),
                                  Text(city.name),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                        isExpanded: true,
                        dropdownColor: Colors.white,
                      ),
                    ),
                  ),
                ),

                const Divider(),

                Expanded(
                  child: ListView.builder(
                    itemCount: displayedCinemas.length,
                    itemBuilder: (context, index) {
                      final cinema = displayedCinemas[index];
                      return ListTile(
                        title: Text(cinema.cinemaName),
                        subtitle: Text(cinema.cinemaAddress),
                        onTap: () async {
                          RememberMoviePrefs.saveRememberMovie(cinema);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
