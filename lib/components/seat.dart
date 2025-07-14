class CinemaSeatResponse {
  final bool success;
  final CinemaSeatData data;

  CinemaSeatResponse({required this.success, required this.data});

  factory CinemaSeatResponse.fromJson(Map<String, dynamic> json) {
    return CinemaSeatResponse(
      success: json['success'] ?? false,
      data: CinemaSeatData.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'data': data.toJson()};
  }
}

class CinemaSeatData {
  final ShowtimeInfo showtime;
  final SeatInfo seats;
  final SeatCounts counts;

  CinemaSeatData({
    required this.showtime,
    required this.seats,
    required this.counts,
  });

  factory CinemaSeatData.fromJson(Map<String, dynamic> json) {
    return CinemaSeatData(
      showtime: ShowtimeInfo.fromJson(json['showtime']),
      seats: SeatInfo.fromJson(json['seats']),
      counts: SeatCounts.fromJson(json['counts']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'showtime': showtime.toJson(),
      'seats': seats.toJson(),
      'counts': counts.toJson(),
    };
  }
}

class ShowtimeInfo {
  final int id;
  final String movie;
  final String hall;
  final String cinema;
  final DateTime startTime;
  final String price;

  ShowtimeInfo({
    required this.id,
    required this.movie,
    required this.hall,
    required this.cinema,
    required this.startTime,
    required this.price,
  });

  factory ShowtimeInfo.fromJson(Map<String, dynamic> json) {
    return ShowtimeInfo(
      id: json['id'],
      movie: json['movie'],
      hall: json['hall'],
      cinema: json['cinema'],
      startTime: DateTime.parse(json['start_time']),
      price: json['price'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'movie': movie,
      'hall': hall,
      'cinema': cinema,
      'start_time': startTime.toIso8601String(),
      'price': price,
    };
  }
}

class SeatInfo {
  final List<Seat> available;
  final List<Seat> occupied;
  final List<Seat> pending;

  SeatInfo({
    required this.available,
    required this.occupied,
    required this.pending,
  });

  factory SeatInfo.fromJson(Map<String, dynamic> json) {
    return SeatInfo(
      available: (json['available'] as List)
          .map((seat) => Seat.fromJson(seat))
          .toList(),
      occupied: (json['occupied'] as List)
          .map((seat) => Seat.fromJson(seat))
          .toList(),
      pending: (json['pending'] as List)
          .map((seat) => Seat.fromJson(seat))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'available': available.map((seat) => seat.toJson()).toList(),
      'occupied': occupied.map((seat) => seat.toJson()).toList(),
      'pending': pending.map((seat) => seat.toJson()).toList(),
    };
  }

  List<Seat> getAllSeats() {
    return [...available, ...occupied, ...pending];
  }

  List<Seat> getSeatsByRow(String row) {
    return getAllSeats().where((seat) => seat.row == row).toList();
  }

  Map<String, List<Seat>> getSeatsByRowGrouped() {
    final Map<String, List<Seat>> groupedSeats = {};
    for (final seat in getAllSeats()) {
      if (!groupedSeats.containsKey(seat.row)) {
        groupedSeats[seat.row] = [];
      }
      groupedSeats[seat.row]!.add(seat);
    }

    groupedSeats.forEach((key, value) {
      value.sort((a, b) => a.number.compareTo(b.number));
    });

    return groupedSeats;
  }
}

class Seat {
  final int id;
  final int hallId;
  final String row;
  final int number;
  final SeatStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Seat({
    required this.id,
    required this.hallId,
    required this.row,
    required this.number,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Seat.fromJson(Map<String, dynamic> json) {
    return Seat(
      id: json['id'],
      hallId: json['hall_id'],
      row: json['row'],
      number: json['number'],
      status: SeatStatus.fromString(json['status']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hall_id': hallId,
      'row': row,
      'number': number,
      'status': status.toString().split('.').last,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get displayName => '$row$number';

  bool get isSelectable => status == SeatStatus.available;
}

enum SeatStatus {
  available,
  occupied,
  pending;

  static SeatStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return SeatStatus.available;
      case 'occupied':
        return SeatStatus.occupied;
      case 'pending':
        return SeatStatus.pending;
      default:
        throw ArgumentError('Unknown seat status: $status');
    }
  }

  String get displayName {
    switch (this) {
      case SeatStatus.available:
        return 'Müsait';
      case SeatStatus.occupied:
        return 'Dolu';
      case SeatStatus.pending:
        return 'Bekliyor';
    }
  }
}

class SeatCounts {
  final int total;
  final int available;
  final int occupied;
  final int pending;

  SeatCounts({
    required this.total,
    required this.available,
    required this.occupied,
    required this.pending,
  });

  factory SeatCounts.fromJson(Map<String, dynamic> json) {
    return SeatCounts(
      total: json['total'],
      available: json['available'],
      occupied: json['occupied'],
      pending: json['pending'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'available': available,
      'occupied': occupied,
      'pending': pending,
    };
  }

  double get occupancyRate => total > 0 ? (occupied + pending) / total : 0.0;

  double get availabilityRate => total > 0 ? available / total : 0.0;
}
