import "package:sinema_uygulamasi/components/cinemas.dart";

class Hall {
  final int id;
  final String name;
  final int cinemaId;
  final int capacity;
  final Cinema cinema;

  Hall({
    required this.id,
    required this.name,
    required this.cinemaId,
    required this.capacity,
    required this.cinema,
  });

  factory Hall.fromJson(Map<String, dynamic> json) {
    return Hall(
      id: json['id'],
      name: json['name'],
      cinemaId: json['cinema_id'],
      capacity: json['capacity'],
      cinema: Cinema.fromJson(json['cinema']),
    );
  }
}
