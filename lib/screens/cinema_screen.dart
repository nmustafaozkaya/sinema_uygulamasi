import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sinema_uygulamasi/constant/app_color_style.dart';
import 'package:sinema_uygulamasi/api_connection/api_connection.dart';
import 'package:sinema_uygulamasi/components/cinemas.dart';

class CinemaScreen extends StatefulWidget {
  const CinemaScreen({super.key});

  @override
  State<CinemaScreen> createState() => _CinemaScreenState();
}

class _CinemaScreenState extends State<CinemaScreen> {
  List<Cinema> _allCinemas = [];
  List<Cinema> _filteredCinemas = [];
  List<String> _cities = ['All'];
  String _selectedCity = 'All';
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    fetchCinemas();
  }

  Future<void> fetchCinemas() async {
    try {
      final response = await http.get(Uri.parse(ApiConnection.cinemas));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true && jsonResponse['data'] is List) {
          final List<dynamic> data = jsonResponse['data'];
          final cinemas = data
              .map((cinemaJson) => Cinema.fromJson(cinemaJson))
              .toList();

          final cityNames = cinemas.map((e) => e.cityName).toSet().toList()
            ..sort();

          setState(() {
            _allCinemas = cinemas;
            _filteredCinemas = cinemas;
            _cities = ['All', ...cityNames];
            _isLoading = false;
          });
        } else {
          throw Exception('Beklenmeyen API yanıtı formatı.');
        }
      } else {
        throw Exception('Sunucu hatası: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterCinemas(String query) {
    final searchLower = query.toLowerCase();

    final filtered = _allCinemas.where((cinema) {
      final matchesSearch =
          cinema.cinemaName.toLowerCase().contains(searchLower) ||
          cinema.cinemaAddress.toLowerCase().contains(searchLower);
      final matchesCity =
          _selectedCity == 'All' || cinema.cityName == _selectedCity;

      return matchesSearch && matchesCity;
    }).toList();

    setState(() {
      _filteredCinemas = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorStyle.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColorStyle.appBarColor,
        title: const Text(
          'Sinema Salonları',
          style: TextStyle(
            color: AppColorStyle.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColorStyle.textPrimary),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColorStyle.primaryAccent,
              ),
            )
          : _error != null
          ? Center(
              child: Text(
                'Hata: $_error',
                style: const TextStyle(color: AppColorStyle.textPrimary),
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
                  child: DropdownButtonFormField<String>(
                    value: _selectedCity,
                    dropdownColor: AppColorStyle.appBarColor,
                    style: const TextStyle(color: AppColorStyle.textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Şehre Göre Filtrele',
                      labelStyle: const TextStyle(
                        color: AppColorStyle.textSecondary,
                      ),
                      iconColor: AppColorStyle.textSecondary,
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColorStyle.primaryAccent,
                        ),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColorStyle.secondaryAccent,
                        ),
                      ),
                    ),
                    items: _cities
                        .map(
                          (city) =>
                              DropdownMenuItem(value: city, child: Text(city)),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedCity = value);
                        _filterCinemas(_searchController.text);
                      }
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: AppColorStyle.textPrimary),
                    decoration: const InputDecoration(
                      hintText: 'Sinema ara...',
                      hintStyle: TextStyle(color: AppColorStyle.textSecondary),
                      prefixIcon: Icon(
                        Icons.search,
                        color: AppColorStyle.textSecondary,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColorStyle.primaryAccent,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColorStyle.secondaryAccent,
                        ),
                      ),
                    ),
                    onChanged: _filterCinemas,
                  ),
                ),

                // Sinema Listesi
                Expanded(
                  child: _filteredCinemas.isEmpty
                      ? const Center(
                          child: Text(
                            'Aramanıza uygun sinema bulunamadı.',
                            style: TextStyle(color: AppColorStyle.textPrimary),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _filteredCinemas.length,
                          itemBuilder: (context, index) {
                            final cinema = _filteredCinemas[index];
                            return Card(
                              color: AppColorStyle.appBarColor,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              child: ListTile(
                                title: Text(
                                  cinema.cinemaName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColorStyle.textPrimary,
                                  ),
                                ),
                                subtitle: Text(
                                  '${cinema.cityName} • ${cinema.cinemaAddress}',
                                  style: const TextStyle(
                                    color: AppColorStyle.textSecondary,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
