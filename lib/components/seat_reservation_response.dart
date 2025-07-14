class SeatReservationResponse {
  final bool success;
  final String message;
  final SeatReservationData data;

  SeatReservationResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory SeatReservationResponse.fromJson(Map<String, dynamic> json) {
    return SeatReservationResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: SeatReservationData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'message': message, 'data': data.toJson()};
  }
}

class SeatReservationData {
  final ReservedSeat seat;
  final DateTime expiresAt;

  SeatReservationData({required this.seat, required this.expiresAt});

  factory SeatReservationData.fromJson(Map<String, dynamic> json) {
    return SeatReservationData(
      seat: ReservedSeat.fromJson(json['seat'] as Map<String, dynamic>),
      expiresAt: DateTime.parse(json['expires_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {'seat': seat.toJson(), 'expires_at': expiresAt.toIso8601String()};
  }
}

class ReservedSeat {
  final int id;
  final int hallId;
  final String row;
  final int number;
  final String status;
  final DateTime reservedAt;
  final DateTime reservedUntil;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReservedSeat({
    required this.id,
    required this.hallId,
    required this.row,
    required this.number,
    required this.status,
    required this.reservedAt,
    required this.reservedUntil,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReservedSeat.fromJson(Map<String, dynamic> json) {
    return ReservedSeat(
      id: json['id'] as int,
      hallId: json['hall_id'] as int,
      row: json['row'] as String,
      number: json['number'] as int,
      status: json['status'] as String,
      reservedAt: DateTime.parse(json['reserved_at'] as String),
      reservedUntil: DateTime.parse(json['reserved_until'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hall_id': hallId,
      'row': row,
      'number': number,
      'status': status,
      'reserved_at': reservedAt.toIso8601String(),
      'reserved_until': reservedUntil.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
