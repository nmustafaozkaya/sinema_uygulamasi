import 'package:flutter/material.dart';
import 'package:sinema_uygulamasi/components/cinemas.dart';
import 'package:sinema_uygulamasi/components/movies.dart';
import 'package:sinema_uygulamasi/components/seat.dart';
import 'package:sinema_uygulamasi/components/showtimes.dart';

class ReservationScreen extends StatelessWidget {
  final Cinema cinema;
  final Movie movie;
  final Showtime showtime;
  final List<Seat> selectedSeats;
  final List<Map<String, dynamic>> selectedTicketDetails; // <-- New property
  final double totalPrice; // <-- New property

  const ReservationScreen({
    super.key,
    required this.cinema,
    required this.movie,
    required this.showtime,
    required this.selectedSeats,
    required this.selectedTicketDetails, // <-- Required
    required this.totalPrice, // <-- Required
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Rezervasyon')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Rezervasyon ekranı burada olacak'),
            Text('Movie: ${movie.title}'),
            Text('Showtime: ${showtime.startTime}'),
            Text(
              'Selected Seats: ${selectedSeats.map((s) => s.displayName).join(', ')}',
            ),
            Text('Total Price: ${totalPrice.toStringAsFixed(2)} ₺'),
            // You can display selectedTicketDetails here as well
            Text('Ticket Details:'),
            ...selectedTicketDetails
                .map(
                  (detail) => Text(
                    '  ${(detail['ticketType'] as dynamic).name} x${detail['count']} = ${(detail['totalPrice'] as double).toStringAsFixed(2)} ₺',
                  ),
                )
                .toList(),
            // Add your payment logic here
          ],
        ),
      ),
    );
  }
}
