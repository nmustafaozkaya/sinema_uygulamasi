import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sinema_uygulamasi/components/movies.dart';
import 'package:sinema_uygulamasi/constant/app_color_style.dart';
import 'package:sinema_uygulamasi/api_connection/api_connection.dart';
import 'package:sinema_uygulamasi/components/cinemas.dart';
import 'package:sinema_uygulamasi/screens/showtimes_screen.dart';

class CinemaSelect extends StatefulWidget {
  final Movie? currentMovie2;

  const CinemaSelect({super.key, this.currentMovie2});

  @override
  State<CinemaSelect> createState() => _CinemaSelectState();
}

class _CinemaSelectState extends State<CinemaSelect> {
  List<Cinema> _allCinemas = [];
  List<Cinema> _filteredCinemas = [];
  List<String> _cities = ['Tümü'];
  String _selectedCity = 'Tümü';
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.currentMovie2 != null) {
      fetchCinemasForMovie();
    } else {
      fetchAllCinemas();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchCinemasForMovie() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final movieId = widget.currentMovie2!.id;
      final uri = Uri.parse('${ApiConnection.showtimes}?movie_id=$movieId');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          final data = jsonResponse['data'];

          // API response'unu daha güvenli şekilde parse et
          List<dynamic> showtimesList = [];

          if (data is Map && data.containsKey('data')) {
            showtimesList = data['data'] ?? [];
          } else if (data is List) {
            showtimesList = data;
          } else {
            throw Exception('Beklenmeyen veri formatı');
          }

          if (showtimesList.isEmpty) {
            setState(() {
              _isLoading = false;
              _error = "Bu film için gösterimde olan sinema bulunamadı.";
            });
            return;
          }

          // Unique cinema'ları topla
          final Map<int, Map<String, dynamic>> uniqueCinemas = {};
          final Set<String> cityNames = {};

          for (final showtime in showtimesList) {
            try {
              // Null kontrollerini daha detaylı yap
              if (showtime == null ||
                  showtime['hall'] == null ||
                  showtime['hall']['cinema'] == null) {
                continue;
              }

              final cinemaData = Map<String, dynamic>.from(
                showtime['hall']['cinema'],
              );
              final cinemaId = cinemaData['id'];

              if (cinemaId == null) continue;

              if (!uniqueCinemas.containsKey(cinemaId)) {
                // City bilgisini düzelt
                if (cinemaData['city_id'] != null) {
                  // Eğer city_id varsa ama city objesi yoksa, varsayılan city objesi oluştur
                  if (cinemaData['city'] == null) {
                    cinemaData['city'] = {
                      'id': cinemaData['city_id'],
                      'name': _getCityNameById(cinemaData['city_id']),
                    };
                  }
                }

                uniqueCinemas[cinemaId] = cinemaData;

                // City name'i topla
                final cityName =
                    cinemaData['city']?['name'] ?? 'Bilinmeyen Şehir';
                cityNames.add(cityName);
              }
            } catch (e) {
              // Tek bir showtime'da hata varsa diğerlerine devam et
              print('Showtime parse hatası: $e');
              continue;
            }
          }

          if (uniqueCinemas.isEmpty) {
            setState(() {
              _isLoading = false;
              _error = "Bu film için gösterimde olan sinema bulunamadı.";
            });
            return;
          }

          // Cinema nesnelerini oluştur
          final List<Cinema> cinemas = [];
          for (final cinemaData in uniqueCinemas.values) {
            try {
              final cinema = Cinema.fromJson(cinemaData);
              cinemas.add(cinema);
            } catch (e) {
              print('Cinema parse hatası: $e');
              continue;
            }
          }

          // Şehir listesini hazırla
          final sortedCities = cityNames.toList()..sort();

          // Sinemaları isme göre sırala
          cinemas.sort((a, b) => a.cinemaName.compareTo(b.cinemaName));

          setState(() {
            _allCinemas = cinemas;
            _filteredCinemas = cinemas;
            _cities = ['Tümü', ...sortedCities];
            _isLoading = false;
          });
        } else {
          throw Exception(
            jsonResponse['message'] ?? 'API yanıtı formatı beklenmedik.',
          );
        }
      } else {
        throw Exception('Sunucu hatası: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _error = 'Sinema bilgileri alınamadı: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> fetchAllCinemas() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Tüm sinemalar için API endpoint'i varsa kullan
      // Yoksa movie_id olmadan çağır
      final uri = Uri.parse(ApiConnection.showtimes);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          // fetchCinemasForMovie ile aynı mantık
          await _processCinemaData(jsonResponse['data']);
        } else {
          throw Exception(
            jsonResponse['message'] ?? 'API yanıtı formatı beklenmedik.',
          );
        }
      } else {
        throw Exception('Sunucu hatası: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _error = 'Sinema bilgileri alınamadı: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _processCinemaData(dynamic data) async {
    List<dynamic> showtimesList = [];

    if (data is Map && data.containsKey('data')) {
      showtimesList = data['data'] ?? [];
    } else if (data is List) {
      showtimesList = data;
    } else {
      throw Exception('Beklenmeyen veri formatı');
    }

    if (showtimesList.isEmpty) {
      setState(() {
        _isLoading = false;
        _error = "Henüz hiç sinema bulunamadı.";
      });
      return;
    }

    // Cinema processing logic'i aynı
    final Map<int, Map<String, dynamic>> uniqueCinemas = {};
    final Set<String> cityNames = {};

    for (final showtime in showtimesList) {
      try {
        if (showtime == null ||
            showtime['hall'] == null ||
            showtime['hall']['cinema'] == null) {
          continue;
        }

        final cinemaData = Map<String, dynamic>.from(
          showtime['hall']['cinema'],
        );
        final cinemaId = cinemaData['id'];

        if (cinemaId == null) continue;

        if (!uniqueCinemas.containsKey(cinemaId)) {
          if (cinemaData['city_id'] != null && cinemaData['city'] == null) {
            cinemaData['city'] = {
              'id': cinemaData['city_id'],
              'name': _getCityNameById(cinemaData['city_id']),
            };
          }

          uniqueCinemas[cinemaId] = cinemaData;

          final cityName = cinemaData['city']?['name'] ?? 'Bilinmeyen Şehir';
          cityNames.add(cityName);
        }
      } catch (e) {
        print('Showtime parse hatası: $e');
        continue;
      }
    }

    final List<Cinema> cinemas = [];
    for (final cinemaData in uniqueCinemas.values) {
      try {
        final cinema = Cinema.fromJson(cinemaData);
        cinemas.add(cinema);
      } catch (e) {
        print('Cinema parse hatası: $e');
        continue;
      }
    }

    final sortedCities = cityNames.toList()..sort();

    // Sinemaları isme göre sırala
    cinemas.sort((a, b) => a.cinemaName.compareTo(b.cinemaName));

    setState(() {
      _allCinemas = cinemas;
      _filteredCinemas = cinemas;
      _cities = ['Tümü', ...sortedCities];
      _isLoading = false;
    });
  }

  String _getCityNameById(int cityId) {
    // City ID'ye göre şehir adını döndür
    // Bu mapping'i kendi verilerinize göre güncelleyin
    final cityMap = {
      1: 'İstanbul',
      2: 'Ankara',
      3: 'Afyonkarahisar',
      4: 'İzmir',
      5: 'Bursa',
      // Diğer şehirler...
    };

    return cityMap[cityId] ?? 'Bilinmeyen Şehir';
  }

  void _filterCinemas(String query) {
    final searchLower = query.toLowerCase();

    final filtered = _allCinemas.where((cinema) {
      final matchesSearch =
          cinema.cinemaName.toLowerCase().contains(searchLower) ||
          cinema.cinemaAddress.toLowerCase().contains(searchLower);
      final matchesCity =
          _selectedCity == 'Tümü' || cinema.cityName == _selectedCity;

      return matchesSearch && matchesCity;
    }).toList();

    // Filtrelenmiş sinemaları da isme göre sırala
    filtered.sort((a, b) => a.cinemaName.compareTo(b.cinemaName));

    setState(() {
      _filteredCinemas = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorStyle.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          widget.currentMovie2 != null
              ? '${widget.currentMovie2!.title} - Sinema Seçimi'
              : 'Sinema Seçimi',
          style: const TextStyle(color: AppColorStyle.textPrimary),
        ),
        backgroundColor: AppColorStyle.appBarColor,
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
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColorStyle.textSecondary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColorStyle.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (widget.currentMovie2 != null) {
                          fetchCinemasForMovie();
                        } else {
                          fetchAllCinemas();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColorStyle.primaryAccent,
                      ),
                      child: const Text(
                        'Tekrar Dene',
                        style: TextStyle(color: AppColorStyle.textPrimary),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                // Şehir filtresi
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
                  child: DropdownButtonFormField<String>(
                    value: _selectedCity,
                    dropdownColor: AppColorStyle.appBarColor,
                    style: const TextStyle(color: AppColorStyle.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'Şehre Göre Filtrele',
                      labelStyle: TextStyle(color: AppColorStyle.textSecondary),
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
                // Arama kutusu
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
                // Sinema listesi
                Expanded(
                  child: _filteredCinemas.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: AppColorStyle.textSecondary,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Aramanıza uygun sinema bulunamadı.',
                                style: TextStyle(
                                  color: AppColorStyle.textPrimary,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 16),
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
                                onTap: () {
                                  if (widget.currentMovie2 != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ShowtimesScreen(
                                          selectedCinema: cinema,
                                          currentMovie: widget.currentMovie2!,
                                        ),
                                      ),
                                    );
                                  } else {
                                    // Sadece sinema seçimi yapıldıysa
                                    Navigator.pop(context, cinema);
                                  }
                                },
                                leading: const CircleAvatar(
                                  backgroundColor: AppColorStyle.primaryAccent,
                                  child: Icon(
                                    Icons.movie,
                                    color: AppColorStyle.textPrimary,
                                  ),
                                ),
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
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  color: AppColorStyle.textSecondary,
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
