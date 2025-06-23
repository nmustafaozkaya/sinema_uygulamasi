class Cinema {
  final int cityId;
  final String cityName;
  final int cinemaId;
  final String cinemaName;
  final String cinemaAddress;
  final String cinemaPhone;
  final String cinemaEmail;
  final int hallCount;
  final int totalCapacity;
  final int activeHalls;

  Cinema({
    required this.cityId,
    required this.cityName,
    required this.cinemaId,
    required this.cinemaName,
    required this.cinemaAddress,
    required this.cinemaPhone,
    required this.cinemaEmail,
    required this.hallCount,
    required this.totalCapacity,
    required this.activeHalls,
  });

  factory Cinema.fromJson(Map<String, dynamic> json) {
    return Cinema(
      cityId: json['city_id'],
      cityName: json['city_name'],
      cinemaId: json['cinema_id'],
      cinemaName: json['cinema_name'],
      cinemaAddress: json['cinema_address'],
      cinemaPhone: json['cinema_phone'],
      cinemaEmail: json['cinema_email'],
      hallCount: json['hall_count'],
      totalCapacity: json['total_capacity'],
      activeHalls: json['active_halls'],
    );
  }
}
