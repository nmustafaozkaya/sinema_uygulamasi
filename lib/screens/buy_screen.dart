import 'package:flutter/material.dart';
import 'package:sinema_uygulamasi/components/cinemas.dart';
import 'package:sinema_uygulamasi/components/movies.dart';
import 'package:sinema_uygulamasi/components/show_time.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sinema_uygulamasi/screens/cinema_select.dart';

class BuyScreen extends StatefulWidget {
  final Movie? currentMovie;

  const BuyScreen({super.key, this.currentMovie});

  @override
  State<BuyScreen> createState() => _BuyScreenState();
}

class ApiServices {
  static Future<List<Showtime>> getShowtimes({
    required int cinemaId,
    required int cityId,
    required int movieId,
  }) async {
    final url = Uri.parse(
      'http://127.0.0.1:8000/api/cities/$cityId/cinemas/$cinemaId',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final List<dynamic> dataList = jsonData['data'];

      final filteredShowtimes = dataList
          .where((item) => item['movie_id'] == movieId)
          .toList();

      return filteredShowtimes.map((json) => Showtime.fromJson(json)).toList();
    } else {
      throw Exception('Seanslar yüklenemedi');
    }
  }
}

class _BuyScreenState extends State<BuyScreen> {
  Cinema? currentCinema;

  @override
  void initState() {
    super.initState();
  }

  Widget buildMoviePoster(String posterUrl) {
    if (posterUrl.isEmpty || posterUrl == 'N/A') {
      return Container(
        width: 120,
        height: 180,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.broken_image_outlined,
          size: 60,
          color: Colors.grey,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        posterUrl,
        width: 120,
        height: 180,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 120,
            height: 180,
            color: Colors.grey.shade200,
            child: const Icon(Icons.broken_image_outlined, size: 60),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final movie = widget.currentMovie;

    return Scaffold(
      appBar: AppBar(title: const Text('Sinema Seçimi'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Film Bilgileri
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (movie != null) buildMoviePoster(movie.poster),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          movie?.title ?? 'Film Adı',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('Tür: ${movie?.genre ?? '...'}'),
                        Text('Süre: ${movie?.runtime ?? '...'}'),
                        Text('Yayın Tarihi: ${movie?.releaseDate ?? '...'}'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Sinema Seçimi
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Sinema Seçimi',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () async {
                            final selectedCinema = await Navigator.push<Cinema>(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CinemaSelect(),
                              ),
                            );
                            if (selectedCinema != null) {
                              setState(() => currentCinema = selectedCinema);
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (currentCinema != null)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 20,
                            color: Colors.grey.shade700,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currentCinema!.cinemaName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  currentCinema!.cinemaAddress,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    else
                      const Text(
                        'Lütfen bir sinema seçiniz.',
                        style: TextStyle(color: Colors.blueAccent),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
