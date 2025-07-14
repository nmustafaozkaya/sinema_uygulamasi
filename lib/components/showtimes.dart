import 'package:intl/intl.dart';
import 'movies.dart';

class Showtime {
  final int id;
  final DateTime startTime;
  final String price;
  final Movie movie;
  final int cinemaId;
  final String hallname;

  Showtime({
    required this.id,
    required this.startTime,
    required this.price,
    required this.movie,
    required this.cinemaId,
    required this.hallname,
  });

  factory Showtime.fromJson(Map<String, dynamic> json) {
    return Showtime(
      id: json['id'],
      startTime: DateTime.parse(json['start_time']),
      price: json['price'],
      movie: Movie.fromJson(json['movie']),
      cinemaId: json['hall']['cinema']['id'],
      hallname: json['hall']['name'],
    );
  }

  DateTime get dateOnly =>
      DateTime(startTime.year, startTime.month, startTime.day);

  String get timeOnly => DateFormat('HH:mm').format(startTime);
}
