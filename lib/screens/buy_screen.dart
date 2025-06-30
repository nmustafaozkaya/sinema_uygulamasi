import 'package:flutter/material.dart';
import 'package:sinema_uygulamasi/components/cinemas.dart';
import 'package:sinema_uygulamasi/components/movie_preferences.dart';
import 'package:sinema_uygulamasi/components/movies.dart';
import 'package:sinema_uygulamasi/components/show_time.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class buyScreen extends StatefulWidget {
  final Movie? currentMovie;
  const buyScreen({super.key, this.currentMovie});

  @override
  State<buyScreen> createState() => _buyScreenState();
}

List<Showtime> showtimes = [];
Showtime? selectedShowtime;
bool isLoadingShowtimes = false;

class ApiService {
  static Future<List<Showtime>> getShowtimes({
    required int cinemaId,
    required int movieId,
  }) async {
    final url = Uri.parse(
      'http://127.0.0.1:8000/api/cinemas/$cinemaId/movies/$movieId/showtimes',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final List showtimesJson = jsonData['data']['showtimes'];

      return showtimesJson.map((json) => Showtime.fromJson(json)).toList();
    } else {
      throw Exception('Seanslar yüklenemedi');
    }
  }
}

class _buyScreenState extends State<buyScreen> {
  Cinema? currentCinema;
  List<Showtime> showtimes = [];
  Showtime? selectedShowtime;
  bool isLoadingShowtimes = false;

  @override
  void initState() {
    super.initState();
    _loadCinema();
    _loadCinemaAndShowtimes();
  }

  void _loadCinema() async {
    Cinema? cinema = await RememberMoviePrefs.getRememberMovie();
    setState(() {
      currentCinema = cinema;
    });
  }

  Future<void> _loadCinemaAndShowtimes() async {
    Cinema? cinema = await RememberMoviePrefs.getRememberMovie();
    setState(() {
      currentCinema = cinema;
      isLoadingShowtimes = true;
    });

    if (cinema != null && widget.currentMovie != null) {
      try {
        final fetchedShowtimes = await ApiService.getShowtimes(
          cinemaId: cinema.cinemaId,
          movieId: widget.currentMovie!.id,
        );
        setState(() {
          showtimes = fetchedShowtimes;
          isLoadingShowtimes = false;
        });
      } catch (e) {
        setState(() {
          isLoadingShowtimes = false;
        });
        // İstersen hata mesajı göster
      }
    } else {
      setState(() {
        isLoadingShowtimes = false;
      });
    }
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
        child: Icon(
          Icons.broken_image_outlined,
          size: 60,
          color: Colors.grey.shade400,
        ),
      );
    } else {
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
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.broken_image_outlined,
                size: 60,
                color: Colors.grey.shade400,
              ),
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final movie = widget.currentMovie;

    return Scaffold(
      appBar: AppBar(title: const Text('Ödeme Ekranı'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                movie != null
                    ? buildMoviePoster(movie.poster)
                    : const SizedBox.shrink(),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Film Başlığı
                      Text(
                        movie?.title ?? 'Film Adı Yükleniyor...',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Text('Tür: ${movie?.genre ?? '...'}'),
                      const SizedBox(height: 4),
                      Text('Süre: ${movie?.runtime ?? '...'}'),
                      const SizedBox(height: 4),
                      Text('Tarih: ${movie?.released ?? '...'}'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 10),
            Column(
              children: [
                if (currentCinema != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 18,
                            color: Colors.grey.shade700,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              currentCinema!.cinemaName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.only(left: 22.0),
                        child: Text(
                          currentCinema!.cinemaAddress,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ),
                      const SizedBox(height: 20),

                      if (isLoadingShowtimes)
                        const CircularProgressIndicator()
                      else if (showtimes.isEmpty)
                        const Text('Bu film için seans bulunmamaktadır.')
                      else
                        DropdownButton<Showtime>(
                          hint: const Text('Seans seçiniz'),
                          value: selectedShowtime,
                          isExpanded: true,
                          items: showtimes.map((showtime) {
                            return DropdownMenuItem(
                              value: showtime,
                              child: Text(showtime.time),
                            );
                          }).toList(),
                          onChanged: (Showtime? val) {
                            setState(() {
                              selectedShowtime = val;
                            });
                            // Seçilen showtime ile koltuk seçimini veya başka işlemleri yapabilirsin
                          },
                        ),
                    ],
                  )
                else
                  Container(
                    decoration: BoxDecoration(color: Colors.black),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text("Sinema bilgisi yükleniyor..."),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
