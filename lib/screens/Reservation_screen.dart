import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sinema_uygulamasi/components/cinemas.dart';
import 'package:sinema_uygulamasi/components/movies.dart';
import 'package:sinema_uygulamasi/components/seat.dart';
import 'package:sinema_uygulamasi/components/showtimes.dart';
import 'package:sinema_uygulamasi/constant/app_color_style.dart';
import 'package:sinema_uygulamasi/components/taxes.dart';
import 'package:sinema_uygulamasi/screens/payment_screen.dart';

class ReservationScreen extends StatefulWidget {
  final Cinema cinema;
  final Movie movie;
  final Showtime showtime;
  final List<Seat> selectedSeats;
  final List<Map<String, dynamic>> selectedTicketDetails;
  final double totalPrice;

  const ReservationScreen({
    super.key,
    required this.cinema,
    required this.movie,
    required this.showtime,
    required this.selectedSeats,
    required this.selectedTicketDetails,
    required this.totalPrice,
  });

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  List<Tax> taxes = [];
  double taxAmount = 0.0;
  double finalTotal = 0.0;

  @override
  void initState() {
    super.initState();
    _loadTaxes();
  }

  void _loadTaxes() async {
    try {
      List<Tax> loadedTaxes = await TaxService.fetchActiveTaxesSorted();

      setState(() {
        taxes = loadedTaxes;
      });

      _calculateTaxes();
    } catch (e) {
      print('Vergi yükleme hatası: $e');

      setState(() {
        taxes = [
          Tax(
            id: 1,
            name: 'KDV',
            type: 'percentage',
            rate: '20.00',
            status: 'active',
            priority: 1,
            description: 'Katma Değer Vergisi %20',
          ),
          Tax(
            id: 2,
            name: 'Hizmet Bedeli',
            type: 'fixed',
            rate: '2.00',
            status: 'active',
            priority: 2,
            description: 'Bilet başına hizmet bedeli',
          ),
          Tax(
            id: 3,
            name: 'İşlem Ücreti',
            type: 'fixed_total',
            rate: '5.00',
            status: 'active',
            priority: 3,
            description: 'Toplam işlem ücreti',
          ),
        ];
      });

      _calculateTaxes();
    }
  }

  void _calculateTaxes() {
    double calculatedTaxAmount = 0.0;

    for (Tax tax in taxes) {
      if (tax.status == 'active') {
        calculatedTaxAmount += TaxService.calculateTaxAmount(
          tax,
          widget.totalPrice,
        );
      }
    }

    setState(() {
      taxAmount = calculatedTaxAmount;
      finalTotal = widget.totalPrice + taxAmount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorStyle.scaffoldBackground,
      appBar: AppBar(
        title: Text('Rezervasyon'),
        backgroundColor: AppColorStyle.appBarColor,
        foregroundColor: AppColorStyle.textPrimary,
      ),
      body: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    color: AppColorStyle.primaryAccent,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 120,
                            height: 180,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                widget.movie.poster,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 120,
                                    height: 180,
                                    color: AppColorStyle.appBarColor,
                                    child: const Icon(
                                      Icons.broken_image_outlined,
                                      size: 60,
                                      color: AppColorStyle.secondaryAccent,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Movie: ${widget.movie.title}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColorStyle.textPrimary,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Cinema: ${widget.cinema.cinemaName}',
                                  style: TextStyle(
                                    color: AppColorStyle.textSecondary,
                                  ),
                                ),
                                Text(
                                  'Showtime: ${DateFormat('dd MMM - HH:mm').format(widget.showtime.startTime)}',
                                  style: TextStyle(
                                    color: AppColorStyle.textSecondary,
                                  ),
                                ),
                                Text(
                                  'Selected Seats: ${widget.selectedSeats.map((s) => s.displayName).join(', ')}',
                                  style: TextStyle(
                                    color: AppColorStyle.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  Card(
                    color: AppColorStyle.primaryAccent,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ticket Details:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColorStyle.textPrimary,
                            ),
                          ),
                          SizedBox(height: 8),
                          ...widget.selectedTicketDetails.map(
                            (detail) => Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 2.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${(detail['ticketType'] as dynamic).name} x${detail['count']}',
                                    style: TextStyle(
                                      color: AppColorStyle.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    '${(detail['totalPrice'] as double).toStringAsFixed(2)} ₺',
                                    style: TextStyle(
                                      color: AppColorStyle.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Divider(color: AppColorStyle.secondaryAccent),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Subtotal:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColorStyle.textPrimary,
                                ),
                              ),
                              Text(
                                '${widget.totalPrice.toStringAsFixed(2)} ₺',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColorStyle.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  Card(
                    color: AppColorStyle.primaryAccent,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Taxes and Fees',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColorStyle.textPrimary,
                            ),
                          ),
                          SizedBox(height: 8),
                          ...taxes.where((tax) => tax.status == 'active').map((
                            tax,
                          ) {
                            double taxValue = TaxService.calculateTaxAmount(
                              tax,
                              widget.totalPrice,
                            );
                            String displayRate = tax.type == 'percentage'
                                ? '${tax.rate}%'
                                : tax.type == 'fixed_total'
                                ? 'Sabit'
                                : '${tax.rate} ₺';

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 2.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${tax.name} ($displayRate)',
                                    style: TextStyle(
                                      color: AppColorStyle.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    '${taxValue.toStringAsFixed(2)} ₺',
                                    style: TextStyle(
                                      color: AppColorStyle.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          Divider(color: AppColorStyle.secondaryAccent),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Fees:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColorStyle.textPrimary,
                                ),
                              ),
                              Text(
                                '${taxAmount.toStringAsFixed(2)} ₺',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColorStyle.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  Card(
                    color: AppColorStyle.appBarColor,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Amount',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColorStyle.textPrimary,
                            ),
                          ),
                          Text(
                            '${finalTotal.toStringAsFixed(2)} ₺',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColorStyle.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Spacer(),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _processPayment();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColorStyle.appBarColor,
                        foregroundColor: AppColorStyle.textPrimary,
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        'Proceed to Payment (${finalTotal.toStringAsFixed(2)} ₺)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _processPayment() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          cinema: widget.cinema,
          movie: widget.movie,
          showtime: widget.showtime,
          selectedSeats: widget.selectedSeats,
          selectedTicketDetails: widget.selectedTicketDetails,
          totalPrice: widget.totalPrice,
          taxes: taxes,
          taxAmount: taxAmount,
          finalTotal: finalTotal,
        ),
      ),
    );
  }
}
