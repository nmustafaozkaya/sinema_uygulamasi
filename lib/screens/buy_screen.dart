import 'package:flutter/material.dart';
import 'package:sinema_uygulamasi/components/cinemas.dart';
import 'package:sinema_uygulamasi/components/movie_preferences.dart';
import 'package:sinema_uygulamasi/components/movies.dart';
import 'package:sinema_uygulamasi/components/show_time.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sinema_uygulamasi/screens/cinema_screen.dart';
import 'package:intl/intl.dart';

class buyScreen extends StatefulWidget {
  final Movie? currentMovie;
  const buyScreen({super.key, this.currentMovie});

  @override
  State<buyScreen> createState() => _buyScreenState();
}

class ApiServices {
  static Future<List<Showtime>> getShowtimes({
    required int cinemaId,
    required int movieId,
  }) async {
    Cinema? cinema = await RememberMoviePrefs.getRememberMovie();
    final url = Uri.parse(
      'http://127.0.0.1:8000/api/cities/${cinema?.cityId}/cinemas/$cinemaId',
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

class _buyScreenState extends State<buyScreen> {
  Cinema? currentCinema;
  List<Showtime> showtimes = [];
  bool isLoadingShowtimes = false;

  DateTime? selectedDate;
  List<Showtime> filteredShowtimes = [];

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
        final fetchedShowtimes = await ApiServices.getShowtimes(
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

  List<DateTime> getNext7Days() {
    final now = DateTime.now();
    return List.generate(7, (index) {
      final date = now.add(Duration(days: index));
      return DateTime(date.year, date.month, date.day);
    });
  }

  void onDateSelected(DateTime selected) {
    setState(() {
      selectedDate = selected;

      // Eski seansları sırayla bugünkü 7 güne eşle
      final fakeDays = getNext7Days();

      // Örnek: 5 seans varsa -> [gün1, gün2, gün3, gün4, gün5]
      // 2 seans varsa -> [gün1, gün2]
      filteredShowtimes = [];

      for (int i = 0; i < showtimes.length && i < fakeDays.length; i++) {
        final fakeDay = fakeDays[i];
        final old = showtimes[i];

        // Eski startTime saatini koruyup tarihi değiştir
        final mappedTime = DateTime(
          fakeDay.year,
          fakeDay.month,
          fakeDay.day,
          old.startTime.hour,
          old.startTime.minute,
        );

        if (selected == fakeDay) {
          filteredShowtimes.add(
            Showtime(
              showtimeId: old.showtimeId,
              startTime: mappedTime,
              endTime: mappedTime.add(Duration(minutes: old.movieDuration)),
              hallId: old.hallId,
              hallName: old.hallName,
              movieId: old.movieId,
              movieTitle: old.movieTitle,
              movieDuration: old.movieDuration,
              moviePosterUrl: old.moviePosterUrl,
            ),
          );
        }
      }

      print(
        'Seçilen gün: $selectedDate, bulunan seans sayısı: ${filteredShowtimes.length}',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final movie = widget.currentMovie;
    final days = getNext7Days();

    return Scaffold(
      appBar: AppBar(title: const Text('Ödeme Ekranı'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                          movie?.title ?? 'Film Adı Yükleniyor...',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('Genre: ${movie?.genre ?? '...'}'),
                        const SizedBox(height: 4),
                        Text('Runtime: ${movie?.runtime ?? '...'}'),
                        const SizedBox(height: 4),
                        Text('Released: ${movie?.released ?? '...'}'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
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
                        const SizedBox(width: 180),
                        GestureDetector(
                          child: Icon(Icons.change_circle_outlined),
                          onTap: () async {
                            final selectedCinema = await Navigator.push<Cinema>(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CinemaScreen(),
                              ),
                            );
                            if (selectedCinema != null) {
                              setState(() {
                                currentCinema = selectedCinema;
                                _loadCinemaAndShowtimes();
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    Column(children: [Text(currentCinema!.cinemaAddress)]),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 60,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: days.length,
                        itemBuilder: (context, index) {
                          final day = days[index];
                          final isSelected =
                              selectedDate != null &&
                              day.year == selectedDate!.year &&
                              day.month == selectedDate!.month &&
                              day.day == selectedDate!.day;

                          return GestureDetector(
                            onTap: () => onDateSelected(day),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.blue
                                    : Colors.grey[300],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      DateFormat.E().format(day),
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      DateFormat.d().format(day),
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (isLoadingShowtimes)
                      const Center(child: CircularProgressIndicator())
                    else if (showtimes.isEmpty)
                      const Text('Bu film için seans bulunmamaktadır.')
                    else if (selectedDate == null)
                      const Text('Lütfen üstteki günlerden birini seçin.')
                    else if (filteredShowtimes.isEmpty)
                      const Text('Seçilen gün için seans bulunmamaktadır.')
                    else
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: filteredShowtimes.map((showtime) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              DateFormat.Hm().format(showtime.startTime),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                )
              else
                Container(
                  decoration: const BoxDecoration(color: Colors.black),
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: const [
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
        ),
      ),
    );
  }
}
