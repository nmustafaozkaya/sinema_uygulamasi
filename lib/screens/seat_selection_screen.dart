import 'package:flutter/material.dart';
import 'package:sinema_uygulamasi/api_connection/api_connection.dart';
import 'package:sinema_uygulamasi/components/cinemas.dart';
import 'package:sinema_uygulamasi/components/movies.dart';
import 'package:sinema_uygulamasi/components/seat.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:sinema_uygulamasi/constant/app_color_style.dart';
import 'package:intl/intl.dart';
import 'package:sinema_uygulamasi/components/showtimes.dart';
import 'package:sinema_uygulamasi/components/seat_reservation_response.dart';
import 'package:sinema_uygulamasi/screens/Reservation_screen.dart';

class SeatSelectionScreen extends StatefulWidget {
  final Cinema currentCinema;
  final Movie currentMovie;
  final Showtime selectedShowtime;
  final int totalTicketsToSelect;
  final List<Map<String, dynamic>> selectedTicketDetails;

  const SeatSelectionScreen({
    super.key,
    required this.currentCinema,
    required this.currentMovie,
    required this.selectedShowtime,
    required this.totalTicketsToSelect,
    required this.selectedTicketDetails,
  });

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  CinemaSeatResponse? seatResponse;
  List<Seat> selectedSeats = [];
  bool isLoading = true;
  String? errorMessage;
  Timer? _refreshTimer; // Add a timer for periodic refresh

  @override
  void initState() {
    super.initState();
    loadSeats();
    // Start a timer to periodically refresh seat availability
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        // Only refresh if the widget is still in the tree
        loadSeats(
          isManualRefresh: false,
        ); // Auto-refresh, no loading indicator for this
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel(); // Cancel the timer to prevent memory leaks
    super.dispose();
  }

  Future<void> loadSeats({bool isManualRefresh = true}) async {
    try {
      if (!mounted) return;

      if (isManualRefresh) {
        // Only show loading indicator for manual refresh
        setState(() {
          isLoading = true;
          errorMessage = null;
        });
      }

      final response = await getAvailableSeats(widget.selectedShowtime.id);

      if (!mounted) return;

      setState(() {
        seatResponse = response;
        isLoading = false;

        // Filter selectedSeats based on the current API response
        // This ensures that if a selected seat becomes occupied by someone else,
        // it's removed from our local 'selectedSeats' list and a message is shown.
        List<Seat> newlySelectedSeats = [];
        List<Seat> removedSeats = [];

        for (var selectedSeat in selectedSeats) {
          // Check if the selected seat is still available or pending in the new response
          bool stillAvailableOrPending =
              response.data.seats.available.any(
                (s) => s.id == selectedSeat.id,
              ) ||
              response.data.seats.pending.any((s) => s.id == selectedSeat.id);

          if (stillAvailableOrPending) {
            // Find the updated seat object from the response to keep its status fresh
            Seat? updatedSeat;
            try {
              updatedSeat = response.data.seats.available.firstWhere(
                (s) => s.id == selectedSeat.id,
              );
            } catch (_) {
              try {
                updatedSeat = response.data.seats.pending.firstWhere(
                  (s) => s.id == selectedSeat.id,
                );
              } catch (_) {
                // If it's not found in either, it must have been taken.
              }
            }
            if (updatedSeat != null) {
              newlySelectedSeats.add(updatedSeat);
            } else {
              // This case implies it was in selectedSeats but not found in available/pending,
              // which means its status changed to occupied.
              removedSeats.add(selectedSeat);
            }
          } else {
            removedSeats.add(selectedSeat);
          }
        }

        selectedSeats = newlySelectedSeats; // Update the list

        // Show snackbars for seats that were removed because they were taken by someone else
        if (removedSeats.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              for (var seat in removedSeats) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Koltuk ${seat.displayName} başka kullanıcı tarafından rezerve edildi!',
                    ),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            }
          });
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  Future<CinemaSeatResponse> getAvailableSeats(int showtimeId) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConnection.getAvailableSeatsUrl(showtimeId)),
      );

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          throw Exception('Sunucudan boş yanıt alındı.');
        }
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return CinemaSeatResponse.fromJson(jsonResponse);
      } else {
        throw Exception(
          'Sunucu hatası: ${response.statusCode}. Yanıt: ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Koltuk bilgileri alınırken hata oluştu: $e');
    }
  }

  Future<bool> reserveSeat(Seat seat) async {
    final url = Uri.parse(
      ApiConnection.reserveSeatUrl(widget.selectedShowtime.id),
    );
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'seat_id': seat.id.toString()});

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (!mounted) return false;

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final SeatReservationResponse reservationResponse =
            SeatReservationResponse.fromJson(jsonResponse);

        if (reservationResponse.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Koltuk ${seat.displayName} başarıyla rezerve edildi.',
              ),
              backgroundColor: Colors.green,
            ),
          );
          return true;
        } else {
          String message = reservationResponse.message;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${seat.displayName} rezerve edilemedi: $message'),
              backgroundColor: Colors.red,
            ),
          );
          return false;
        }
      } else {
        String errorMsg = 'Koltuk rezervasyonunda sunucu hatası';
        try {
          final errorJson = json.decode(response.body);
          if (errorJson['message'] != null) {
            errorMsg = errorJson['message'];
          } else if (errorJson['error'] != null) {
            errorMsg = errorJson['error'];
          } else {
            errorMsg = 'HTTP ${response.statusCode}: ${response.body}';
          }
        } catch (_) {
          errorMsg = 'HTTP ${response.statusCode}: ${response.body}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${seat.displayName} rezerve edilemedi: $errorMsg'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    } catch (e) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${seat.displayName} rezervasyon isteği başarısız oldu: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }

  Future<bool> unreserveSeat(Seat seat) async {
    final url = Uri.parse(
      'http://192.168.81.1:8000/api/seats/${seat.id}/release', // Ensure this URL is correct for your backend
    );
    final headers = {'Content-Type': 'application/json'};

    try {
      final response = await http.post(url, headers: headers);

      if (!mounted) return false;

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Koltuk ${seat.displayName} serbest bırakıldı.'),
              backgroundColor: Colors.green,
            ),
          );
          return true;
        } else {
          String message = jsonResponse['message'] ?? 'Bilinmeyen hata';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${seat.displayName} serbest bırakılamadı: $message',
              ),
              backgroundColor: Colors.red,
            ),
          );
          return false;
        }
      } else {
        String errorMsg = 'Koltuk serbest bırakmada sunucu hatası';
        try {
          final errorJson = json.decode(response.body);
          if (errorJson['message'] != null) {
            errorMsg = errorJson['message'];
          } else if (errorJson['error'] != null) {
            errorMsg = errorJson['error'];
          } else {
            errorMsg = 'HTTP ${response.statusCode}: ${response.body}';
          }
        } catch (_) {
          errorMsg = 'HTTP ${response.statusCode}: ${response.body}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${seat.displayName} serbest bırakılamadı: $errorMsg',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    } catch (e) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${seat.displayName} serbest bırakma isteği başarısız oldu: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }

  void toggleSeatSelection(Seat seat) async {
    final isAlreadySelected = selectedSeats.any((s) => s.id == seat.id);

    if (isAlreadySelected) {
      final success = await unreserveSeat(seat);
      if (success) {
        setState(() {
          selectedSeats.removeWhere((s) => s.id == seat.id);
        });

        await loadSeats();
      }
    } else {
      if (!seat.isSelectable) return;

      if (seat.status != SeatStatus.available) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${seat.displayName} koltuğu seçilemez durumda veya zaten rezerve edilmiş.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      if (selectedSeats.length >= widget.totalTicketsToSelect) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Sadece ${widget.totalTicketsToSelect} koltuk seçebilirsiniz.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final success = await reserveSeat(seat);
      if (success) {
        setState(() {
          selectedSeats.add(seat);
        });
        await loadSeats();
      }
    }
  }

  Color getSeatColor(Seat seat) {
    final isSelected = selectedSeats.any((s) => s.id == seat.id);
    if (isSelected) {
      return AppColorStyle.primaryAccent; // Color for locally selected seats
    }

    // Colors based on the actual backend status
    switch (seat.status) {
      case SeatStatus.available:
        return Colors.green;
      case SeatStatus.occupied:
        return Colors.red;
      case SeatStatus.pending:
        return Colors.orange;
    }
  }

  Widget buildSeatButton(Seat seat) {
    return GestureDetector(
      onTap: () => toggleSeatSelection(seat),
      child: Container(
        width: 35,
        height: 35,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: getSeatColor(seat),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: seat.isSelectable
                ? AppColorStyle.textSecondary
                : AppColorStyle
                      .appBarColor, // Less prominent for non-selectable
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            seat.displayName,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSeatMap() {
    if (seatResponse == null) {
      return Center(
        child: isLoading
            ? CircularProgressIndicator(color: AppColorStyle.primaryAccent)
            : Text(
                errorMessage ?? 'Koltuk haritası yüklenemedi.',
                style: const TextStyle(color: Colors.red),
              ),
      );
    }

    final groupedSeats = seatResponse!.data.seats.getSeatsByRowGrouped();
    final sortedRows = groupedSeats.keys.toList()..sort();

    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 30,
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColorStyle.appBarColor,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Center(
            child: Text(
              'EKRAN',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColorStyle.textPrimary,
              ),
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                ...sortedRows.map((row) {
                  final seats = groupedSeats[row]!;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 30,
                          alignment: Alignment.center,
                          child: Text(
                            row,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColorStyle.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ), // Spacing between row label and seats
                        ...seats.map((seat) => buildSeatButton(seat)).toList(),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildLegend() {
    return Card(
      margin: const EdgeInsets.all(16),
      color: AppColorStyle.appBarColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildLegendItem(Colors.green, 'Müsait'),
            _buildLegendItem(AppColorStyle.primaryAccent, 'Seçili'),
            _buildLegendItem(Colors.orange, 'Bekleyen'),
            _buildLegendItem(Colors.red, 'Dolu'),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: AppColorStyle.textSecondary),
        ),
      ],
    );
  }

  Widget buildBottomBar() {
    double totalPrice = 0;
    for (var detail in widget.selectedTicketDetails) {
      totalPrice += detail['totalPrice'] as double;
    }

    final isSelectionComplete =
        selectedSeats.length == widget.totalTicketsToSelect;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColorStyle.appBarColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Seçili Koltuklar: ${selectedSeats.map((s) => s.displayName).join(', ')}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColorStyle.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (selectedSeats.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            'Toplam Seçili: ${selectedSeats.length} koltuk',
                            style: TextStyle(
                              color: AppColorStyle.textSecondary,
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(
                          'Seçilmesi Gereken: ${widget.totalTicketsToSelect - selectedSeats.length} koltuk kaldı',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSelectionComplete
                                ? Colors.green
                                : Colors.orange,
                          ),
                        ),
                      ),
                      Text(
                        'Ödenecek Tutar: ${totalPrice.toStringAsFixed(2)} ₺',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppColorStyle.primaryAccent,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: isSelectionComplete
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReservationScreen(
                                cinema: widget.currentCinema,
                                movie: widget.currentMovie,
                                showtime: widget.selectedShowtime,
                                selectedSeats: selectedSeats,
                                selectedTicketDetails:
                                    widget.selectedTicketDetails,
                                totalPrice: totalPrice,
                              ),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelectionComplete
                        ? AppColorStyle.primaryAccent
                        : Colors.grey.shade700,
                    foregroundColor: AppColorStyle.textPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Devam Et', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorStyle.scaffoldBackground,
      appBar: AppBar(
        title: const Text(
          'Koltuk Seçimi',
          style: TextStyle(color: AppColorStyle.textPrimary),
        ),

        backgroundColor: AppColorStyle.appBarColor,
        foregroundColor: AppColorStyle.textPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColorStyle.textPrimary),
            onPressed: () async {
              // Tüm seçili koltukları serbest bırak
              for (var seat in List<Seat>.from(selectedSeats)) {
                final success = await unreserveSeat(seat);
                if (success) {
                  setState(() {
                    selectedSeats.removeWhere((s) => s.id == seat.id);
                  });
                }
              }

              // Sonra koltukları yeniden yükle
              await loadSeats(isManualRefresh: true);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            color: AppColorStyle.appBarColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.currentMovie.title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColorStyle.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sinema: ${widget.currentCinema.cinemaName}',
                    style: TextStyle(color: AppColorStyle.textSecondary),
                  ),
                  Text(
                    'Salon: ${widget.selectedShowtime.hallname}',
                    style: TextStyle(color: AppColorStyle.textSecondary),
                  ),
                  Text(
                    'Seans: ${DateFormat('dd.MM.yyyy HH:mm').format(widget.selectedShowtime.startTime)}',
                    style: TextStyle(color: AppColorStyle.textSecondary),
                  ),
                ],
              ),
            ),
          ),
          buildLegend(),
          Expanded(
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: AppColorStyle.primaryAccent,
                    ),
                  )
                : errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Hata: $errorMessage',
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => loadSeats(isManualRefresh: true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColorStyle.primaryAccent,
                            foregroundColor: AppColorStyle.textPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Tekrar Dene'),
                        ),
                      ],
                    ),
                  )
                : buildSeatMap(),
          ),
        ],
      ),
      bottomNavigationBar: buildBottomBar(),
    );
  }
}
