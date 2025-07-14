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

  @override
  void initState() {
    super.initState();
    loadSeats();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> loadSeats() async {
    try {
      if (!mounted) return;

      // Sadece gerçekten yüklenmiyorsa veya hata varsa durumu güncelle
      if (!isLoading || errorMessage != null) {
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

        List<Seat> newSelectedSeats = [];
        for (var seat in selectedSeats) {
          try {
            final updatedSeat = response.data.seats.pending.firstWhere(
              (s) => s.id == seat.id,
            );
            newSelectedSeats.add(updatedSeat);
          } catch (_) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Koltuk ${seat.displayName} durumu değişti!'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            });
          }
        }
        selectedSeats = newSelectedSeats;
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
    // URL'e seat.id'yi ekleyerek POST isteği gönder
    final url = Uri.parse(
      'http://192.168.81.1:8000/api/seats/${seat.id}/release',
    );
    final headers = {'Content-Type': 'application/json'};

    try {
      final response = await http.post(url, headers: headers);

      if (!mounted) return false;

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        // API yanıtını kontrol et
        if (jsonResponse['success'] == true) {
          // Başarılı serbest bırakma
          final releasedSeat = jsonResponse['seat'];

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Koltuk ${seat.displayName} serbest bırakıldı.'),
              backgroundColor: Colors.green,
            ),
          );

          // Serbest bırakılan koltuğu yeşile boya ve kullanıcıya +1 hak ver
          if (releasedSeat != null && releasedSeat['status'] == 'available') {
            // loadSeats() fonksiyonu çağrılacak ve koltuk yeşil olacak
            print(
              'Koltuk ID ${releasedSeat['id']} serbest bırakıldı ve available durumunda',
            );
          }

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
    if (!seat.isSelectable) return;

    final isAlreadySelected = selectedSeats.any((s) => s.id == seat.id);

    if (isAlreadySelected) {
      // Koltuk zaten seçili, serbest bırak
      final success = await unreserveSeat(seat);
      if (success) {
        // Önce selectedSeats listesinden çıkar
        setState(() {
          selectedSeats.removeWhere((s) => s.id == seat.id);
        });
        // Sonra koltukları güncelle
        await loadSeats();
      }
    } else {
      // Yeni koltuk seçimi - sadece available koltuklar seçilebilir
      if (seat.status != SeatStatus.available) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${seat.displayName} koltuğu seçilemez durumda.'),
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
    // Önce seçili koltuk kontrolü yap
    final isSelected = selectedSeats.any((s) => s.id == seat.id);

    if (isSelected) {
      return AppColorStyle.primaryAccent; // Seçili koltuk rengi
    }

    // Seçili değilse, durumuna göre renk belirle
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
                : AppColorStyle.appBarColor,
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
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    ),
                    if (selectedSeats.isNotEmpty)
                      Text(
                        'Toplam Seçili: ${selectedSeats.length} koltuk',
                        style: TextStyle(color: AppColorStyle.textSecondary),
                      ),
                    Text(
                      'Seçilmesi Gereken: ${widget.totalTicketsToSelect - selectedSeats.length} koltuk kaldı',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color:
                            selectedSeats.length == widget.totalTicketsToSelect
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ),
                    Text(
                      'Ödenecek Tutar: ${totalPrice.toStringAsFixed(2)} ₺',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColorStyle.primaryAccent,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: selectedSeats.length == widget.totalTicketsToSelect
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
                  backgroundColor:
                      selectedSeats.length == widget.totalTicketsToSelect
                      ? AppColorStyle.primaryAccent
                      : Colors.grey.shade700,
                  foregroundColor: AppColorStyle.textPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text('Devam Et'),
              ),
            ],
          ),
        ],
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
            onPressed: loadSeats,
          ),
        ],
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            color: AppColorStyle.appBarColor,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.currentMovie.title,
                    style: TextStyle(
                      fontSize: 18,
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
                          onPressed: loadSeats,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColorStyle.primaryAccent,
                            foregroundColor: AppColorStyle.textPrimary,
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
