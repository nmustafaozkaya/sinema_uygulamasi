import 'package:flutter/material.dart';
import 'package:sinema_uygulamasi/components/cinemas.dart';
import 'package:sinema_uygulamasi/components/movies.dart';
import 'package:sinema_uygulamasi/components/showtimes.dart';

class SeatScreen extends StatefulWidget {
  final Movie currentMovie;
  final Showtime selectedShowtime;
  final Cinema currentCinema;

  const SeatScreen({
    super.key,
    required this.currentMovie,
    required this.selectedShowtime,
    required this.currentCinema,
  });

  @override
  State<SeatScreen> createState() => _SeatScreenState();
}

class _SeatScreenState extends State<SeatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Koltuk Seçimi")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Film: ${widget.currentMovie.title}"),
            Text("Sinema: ${widget.currentCinema.cinemaName}"),
            Text("Seans: ${widget.selectedShowtime.startTime}"),
            const SizedBox(height: 20),
            const Text(
              "Koltuklar burada listelenecek...",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
