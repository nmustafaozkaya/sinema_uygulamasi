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
import 'package:sinema_uygulamasi/screens/reservation_screen.dart';

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
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    loadSeats();
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        loadSeats(isManualRefresh: false);
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> loadSeats({bool isManualRefresh = true}) async {
    try {
      if (!mounted) return;

      if (isManualRefresh) {
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

        List<Seat> newlySelectedSeats = [];
        List<Seat> removedSeats = [];

        for (var selectedSeat in selectedSeats) {
          bool stillAvailableOrPending =
              response.data.seats.available.any(
                (s) => s.id == selectedSeat.id,
              ) ||
              response.data.seats.pending.any((s) => s.id == selectedSeat.id);

          if (stillAvailableOrPending) {
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
              } catch (_) {}
            }
            if (updatedSeat != null) {
              newlySelectedSeats.add(updatedSeat);
            } else {
              removedSeats.add(selectedSeat);
            }
          } else {
            removedSeats.add(selectedSeat);
          }
        }

        selectedSeats = newlySelectedSeats;

        if (removedSeats.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              for (var seat in removedSeats) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Seat ${seat.displayName} was reserved by another user!',
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
          throw Exception('Empty response received from server.');
        }
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return CinemaSeatResponse.fromJson(jsonResponse);
      } else {
        throw Exception(
          'Server error: ${response.statusCode}. response: ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error while fetching seat data: $e');
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
              content: Text('Seat ${seat.displayName} successfully reserved.'),
              backgroundColor: Colors.green,
            ),
          );
          return true;
        } else {
          String message = reservationResponse.message;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${seat.displayName} could not be reserved: $message',
              ),
              backgroundColor: Colors.red,
            ),
          );
          return false;
        }
      } else {
        String errorMsg = 'Seat reserve server error';
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
              '${seat.displayName} could not be reserved: $errorMsg',
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
          content: Text('${seat.displayName} reserve request failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }

  Future<bool> unreserveSeat(Seat seat) async {
    final url = Uri.parse(ApiConnection.releaseSeatUrl(seat.id));
    final headers = {'Content-Type': 'application/json'};

    try {
      final response = await http.post(url, headers: headers);

      if (!mounted) return false;

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Seat ${seat.displayName} has been released.'),
              backgroundColor: Colors.green,
            ),
          );
          return true;
        } else {
          String message = jsonResponse['message'] ?? 'Unknown error!';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${seat.displayName} could not be released: $message',
              ),
              backgroundColor: Colors.red,
            ),
          );
          return false;
        }
      } else {
        String errorMsg = 'Server error! Could not be released';
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
              '${seat.displayName} could not be released: $errorMsg',
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
          content: Text('${seat.displayName} release request failed: $e'),
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
              '${seat.displayName} not selectable or already reserved.',
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
              'You can only select ${widget.totalTicketsToSelect} seat(s).',
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
      return AppColorStyle.primaryAccent;
    }

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
                errorMessage ?? 'Failed to load seat map.',
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
              'Screen This Way ↑',
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
                        const SizedBox(width: 8),
                        ...seats.map((seat) => buildSeatButton(seat)).toList(),
                      ],
                    ),
                  );
                }),
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
            _buildLegendItem(Colors.green, 'Available'),
            _buildLegendItem(AppColorStyle.primaryAccent, 'Selected'),
            _buildLegendItem(Colors.orange, 'Pending'),
            _buildLegendItem(Colors.red, 'Occupied'),
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
            color: Colors.black,
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
                        'Selected Seats: ${selectedSeats.map((s) => s.displayName).join(', ')}',
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
                            'Total Selected: ${selectedSeats.length}',
                            style: TextStyle(
                              color: AppColorStyle.textSecondary,
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(
                          'Seats Remaining: ${widget.totalTicketsToSelect - selectedSeats.length} more to select',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSelectionComplete
                                ? Colors.green
                                : Colors.orange,
                          ),
                        ),
                      ),
                      Text(
                        'Subtotal Amount: ${totalPrice.toStringAsFixed(2)} ₺',
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
                        ? Colors.amber.shade700
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
                  child: const Text('Proceed', style: TextStyle(fontSize: 16)),
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
          'Select Seat',
          style: TextStyle(color: AppColorStyle.textPrimary),
        ),

        backgroundColor: AppColorStyle.appBarColor,
        foregroundColor: AppColorStyle.textPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColorStyle.textPrimary),
            onPressed: () async {
              for (var seat in List<Seat>.from(selectedSeats)) {
                final success = await unreserveSeat(seat);
                if (success) {
                  setState(() {
                    selectedSeats.removeWhere((s) => s.id == seat.id);
                  });
                }
              }

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
                    'Cinema: ${widget.currentCinema.cinemaName}',
                    style: TextStyle(color: AppColorStyle.textSecondary),
                  ),
                  Text(
                    'Hall: ${widget.selectedShowtime.hallname}',
                    style: TextStyle(color: AppColorStyle.textSecondary),
                  ),
                  Text(
                    'Showtime: ${DateFormat('dd.MM.yyyy HH:mm').format(widget.selectedShowtime.startTime)}',
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
                          'Error: $errorMessage',
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
                          child: const Text('Try again'),
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
