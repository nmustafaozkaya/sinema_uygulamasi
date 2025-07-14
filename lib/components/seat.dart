class Seat {
  final int id;
  final int hallId;
  final String row;
  final int number;
  final String status;

  Seat({
    required this.id,
    required this.hallId,
    required this.row,
    required this.number,
    required this.status,
  });

  factory Seat.fromJson(Map<String, dynamic> json) {
    return Seat(
      id: json['id'],
      hallId: json['hall_id'],
      row: json['row'],
      number: json['number'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hall_id': hallId,
      'row': row,
      'number': number,
      'status': status,
    };
  }
}
