class Showtime {
  final int showtimeId;
  final DateTime startTime;
  final DateTime endTime;
  final int hallId;
  final String hallName;
  final int movieId;
  final String movieTitle;
  final int movieDuration;
  final String moviePosterUrl;

  Showtime({
    required this.showtimeId,
    required this.startTime,
    required this.endTime,
    required this.hallId,
    required this.hallName,
    required this.movieId,
    required this.movieTitle,
    required this.movieDuration,
    required this.moviePosterUrl,
  });

  factory Showtime.fromJson(Map<String, dynamic> json) {
    return Showtime(
      showtimeId: json['showtime_id'],
      startTime: DateTime.parse(json['showtime_start_time']),
      endTime: DateTime.parse(json['showtime_end_time']),
      hallId: json['hall_id'],
      hallName: json['hall_name'],
      movieId: json['movie_id'],
      movieTitle: json['movie_title'],
      movieDuration: json['movie_duration'],
      moviePosterUrl: json['movie_poster_url'],
    );
  }

  // 👇 Bunları ekle
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Showtime &&
          runtimeType == other.runtimeType &&
          showtimeId == other.showtimeId;

  @override
  int get hashCode => showtimeId.hashCode;
}
