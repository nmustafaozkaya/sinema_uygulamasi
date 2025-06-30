class Showtime {
  final int id;
  final String time;

  Showtime({required this.id, required this.time});

  factory Showtime.fromJson(Map<String, dynamic> json) {
    return Showtime(id: json['id'], time: json['time']);
  }
}
