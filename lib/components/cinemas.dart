class Cinema {
  final int cityId;
  final String cityName;
  final int cinemaId;
  final String cinemaName;
  final String cinemaAddress;
  final String cinemaPhone;
  final String cinemaEmail;

  Cinema({
    required this.cityId,
    required this.cityName,
    required this.cinemaId,
    required this.cinemaName,
    required this.cinemaAddress,
    required this.cinemaPhone,
    required this.cinemaEmail,
  });

  factory Cinema.fromJson(Map<String, dynamic> json) {
    return Cinema(
      cityId: json['city']['id'],
      cityName: json['city']['name'],
      cinemaId: json['id'],
      cinemaName: json['name'],
      cinemaAddress: json['address'],
      cinemaPhone: json['phone'],
      cinemaEmail: json['email'],
    );
  }
}
