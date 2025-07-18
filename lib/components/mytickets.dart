// models/ticket_models.dart

class MyTicketsResponse {
  final bool success;
  final TicketData data;

  MyTicketsResponse({required this.success, required this.data});

  factory MyTicketsResponse.fromJson(Map<String, dynamic> json) {
    return MyTicketsResponse(
      success: json['success'] ?? false,
      data: TicketData.fromJson(json['data']),
    );
  }
}

class TicketData {
  final int currentPage;
  final List<Ticket> tickets;
  final int total;
  final int perPage;
  final String? nextPageUrl;
  final String? prevPageUrl;

  TicketData({
    required this.currentPage,
    required this.tickets,
    required this.total,
    required this.perPage,
    this.nextPageUrl,
    this.prevPageUrl,
  });

  factory TicketData.fromJson(Map<String, dynamic> json) {
    return TicketData(
      currentPage: json['current_page'] ?? 1,
      tickets: (json['data'] as List<dynamic>)
          .map((item) => Ticket.fromJson(item))
          .toList(),
      total: json['total'] ?? 0,
      perPage: json['per_page'] ?? 10,
      nextPageUrl: json['next_page_url'],
      prevPageUrl: json['prev_page_url'],
    );
  }
}

class Ticket {
  final int id;
  final int showtimeId;
  final int seatId;
  final int userId;
  final int saleId;
  final double price;
  final String customerType;
  final double discountRate;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Showtime showtime;
  final Seat seat;

  Ticket({
    required this.id,
    required this.showtimeId,
    required this.seatId,
    required this.userId,
    required this.saleId,
    required this.price,
    required this.customerType,
    required this.discountRate,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.showtime,
    required this.seat,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'],
      showtimeId: json['showtime_id'],
      seatId: json['seat_id'],
      userId: json['user_id'],
      saleId: json['sale_id'],
      price: double.parse(json['price'].toString()),
      customerType: json['customer_type'],
      discountRate: double.parse(json['discount_rate'].toString()),
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      showtime: Showtime.fromJson(json['showtime']),
      seat: Seat.fromJson(json['seat']),
    );
  }
}

class Showtime {
  final int id;
  final int movieId;
  final int hallId;
  final double price;
  final DateTime startTime;
  final DateTime endTime;
  final DateTime date;
  final String status;
  final Movie movie;
  final Hall hall;

  Showtime({
    required this.id,
    required this.movieId,
    required this.hallId,
    required this.price,
    required this.startTime,
    required this.endTime,
    required this.date,
    required this.status,
    required this.movie,
    required this.hall,
  });

  factory Showtime.fromJson(Map<String, dynamic> json) {
    return Showtime(
      id: json['id'],
      movieId: json['movie_id'],
      hallId: json['hall_id'],
      price: double.parse(json['price'].toString()),
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      date: DateTime.parse(json['date']),
      status: json['status'],
      movie: Movie.fromJson(json['movie']),
      hall: Hall.fromJson(json['hall']),
    );
  }
}

class Movie {
  final int id;
  final String title;
  final String description;
  final int duration;
  final String language;
  final String releaseDate;
  final String genre;
  final String posterUrl;
  final String imdbRating;
  final String status;

  Movie({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.language,
    required this.releaseDate,
    required this.genre,
    required this.posterUrl,
    required this.imdbRating,
    required this.status,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      duration: json['duration'],
      language: json['language'],
      releaseDate: json['release_date'],
      genre: json['genre'],
      posterUrl: json['poster_url'],
      imdbRating: json['imdb_raiting'], // API'de typo var
      status: json['status'],
    );
  }
}

class Hall {
  final int id;
  final String name;
  final int cinemaId;
  final int capacity;
  final String status;
  final Cinema cinema;

  Hall({
    required this.id,
    required this.name,
    required this.cinemaId,
    required this.capacity,
    required this.status,
    required this.cinema,
  });

  factory Hall.fromJson(Map<String, dynamic> json) {
    return Hall(
      id: json['id'],
      name: json['name'],
      cinemaId: json['cinema_id'],
      capacity: json['capacity'],
      status: json['status'],
      cinema: Cinema.fromJson(json['cinema']),
    );
  }
}

class Cinema {
  final int id;
  final String name;
  final String address;
  final String phone;
  final String email;
  final int cityId;

  Cinema({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
    required this.cityId,
  });

  factory Cinema.fromJson(Map<String, dynamic> json) {
    return Cinema(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      phone: json['phone'],
      email: json['email'],
      cityId: json['city_id'],
    );
  }
}

class Seat {
  final int id;
  final int hallId;
  final String row;
  final int number;
  final String status;
  final DateTime? reservedAt;
  final DateTime? reservedUntil;

  Seat({
    required this.id,
    required this.hallId,
    required this.row,
    required this.number,
    required this.status,
    this.reservedAt,
    this.reservedUntil,
  });

  factory Seat.fromJson(Map<String, dynamic> json) {
    return Seat(
      id: json['id'],
      hallId: json['hall_id'],
      row: json['row'],
      number: json['number'],
      status: json['status'],
      reservedAt: json['reserved_at'] != null
          ? DateTime.parse(json['reserved_at'])
          : null,
      reservedUntil: json['reserved_until'] != null
          ? DateTime.parse(json['reserved_until'])
          : null,
    );
  }
}
