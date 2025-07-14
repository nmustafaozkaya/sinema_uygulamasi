import 'package:sinema_uygulamasi/components/seat.dart';

class SeatReleaseResponse {
  final bool success;
  final String message;
  final Seat seat;

  SeatReleaseResponse({
    required this.success,
    required this.message,
    required this.seat,
  });

  factory SeatReleaseResponse.fromJson(Map<String, dynamic> json) {
    return SeatReleaseResponse(
      success: json['success'],
      message: json['message'],
      seat: Seat.fromJson(json['seat']),
    );
  }
}
