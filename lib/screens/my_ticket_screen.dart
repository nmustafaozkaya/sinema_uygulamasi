import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sinema_uygulamasi/api_connection/api_connection.dart';
import 'dart:convert';
import "package:sinema_uygulamasi/components/mytickets.dart";
import 'package:sinema_uygulamasi/components/user_preferences.dart';
import 'package:sinema_uygulamasi/constant/app_color_style.dart';

class MyTicketsPage extends StatefulWidget {
  const MyTicketsPage({super.key});

  @override
  State<MyTicketsPage> createState() => _MyTicketsPageState();
}

class _MyTicketsPageState extends State<MyTicketsPage> {
  List<Ticket> tickets = [];
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';

  dynamic currentUser;
  String? _userToken;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _initializeData() async {
    await _loadUserDataAndToken();
    await fetchMyTickets();
  }

  Future<void> _loadUserDataAndToken() async {
    final fetchedUser = await UserPreferences.readData();
    final fetchedToken = await UserPreferences.getToken();

    if (mounted) {
      setState(() {
        currentUser = fetchedUser;
        _userToken = fetchedToken;
      });
    }
  }

  Future<void> fetchMyTickets() async {
    try {
      setState(() {
        isLoading = true;
        hasError = false;
      });

      if (_userToken == null || _userToken!.isEmpty) {
        setState(() {
          hasError = true;
          errorMessage =
              'Kullanıcı oturumu bulunamadı. Lütfen tekrar giriş yapın.';
          isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse(ApiConnection.myTickets),
        headers: {
          'Authorization': 'Bearer $_userToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        if (response.body.trim().startsWith('{') ||
            response.body.trim().startsWith('[')) {
          try {
            final jsonData = json.decode(response.body);
            final ticketsResponse = MyTicketsResponse.fromJson(jsonData);

            setState(() {
              tickets = ticketsResponse.data.tickets;
              isLoading = false;
            });
          } catch (jsonError) {
            setState(() {
              hasError = true;
              errorMessage = 'JSON parse hatası: $jsonError';
              isLoading = false;
            });
          }
        } else {
          setState(() {
            hasError = true;
            errorMessage =
                'Sunucu beklenmedik bir yanıt döndürdü (HTML formatında)';
            isLoading = false;
          });
        }
      } else if (response.statusCode == 401) {
        setState(() {
          hasError = true;
          errorMessage = 'Oturum süreniz dolmuş. Lütfen tekrar giriş yapın.';
          isLoading = false;
        });
      } else {
        setState(() {
          hasError = true;
          errorMessage =
              'Biletler yüklenemedi. Kod: ${response.statusCode}\nMesaj: ${response.body}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        errorMessage = 'Bağlantı hatası: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorStyle.scaffoldBackground,
      appBar: AppBar(
        title: const Text('My Tickets'),
        backgroundColor: AppColorStyle.appBarColor,
        foregroundColor: AppColorStyle.textPrimary,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: fetchMyTickets,
        color: AppColorStyle.primaryAccent,
        backgroundColor: AppColorStyle.scaffoldBackground,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColorStyle.primaryAccent),
      );
    }

    if (hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColorStyle.errorColor,
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              style: const TextStyle(
                fontSize: 16,
                color: AppColorStyle.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: fetchMyTickets,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColorStyle.primaryAccent,
                foregroundColor: AppColorStyle.textPrimary,
              ),
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
    }

    if (tickets.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.movie_outlined,
              size: 64,
              color: AppColorStyle.textSecondary,
            ),
            SizedBox(height: 16),
            Text(
              'Henüz biletiniz yok',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColorStyle.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Film biletleriniz burada görünecek',
              style: TextStyle(color: AppColorStyle.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tickets.length,
      itemBuilder: (context, index) {
        return TicketCard(ticket: tickets[index]);
      },
    );
  }
}

class TicketCard extends StatelessWidget {
  final Ticket ticket;

  const TicketCard({Key? key, required this.ticket}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      color: AppColorStyle.appBarColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Film Posteri
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    ticket.showtime.movie.posterUrl,
                    width: 60,
                    height: 90,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 60,
                        height: 90,
                        color: AppColorStyle.secondaryAccent,
                        child: const Icon(
                          Icons.movie,
                          color: AppColorStyle.textSecondary,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ticket.showtime.movie.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColorStyle.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ticket.showtime.hall.cinema.name,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColorStyle.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ticket.showtime.hall.name,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColorStyle.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Fiyat
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColorStyle.primaryAccent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '₺${ticket.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColorStyle.textPrimary,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColorStyle.scaffoldBackground,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColorStyle.primaryAccent),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildDetailItem(
                        'Date',
                        _formatDate(ticket.showtime.date),
                      ),
                      _buildDetailItem(
                        'Time',
                        _formatTime(ticket.showtime.startTime),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildDetailItem(
                        'Seat',
                        '${ticket.seat.row}${ticket.seat.number}',
                      ),
                      const SizedBox(width: 15, height: 15),
                      _buildDetailItem(
                        'Ticket Type',
                        _getCustomerTypeText(ticket.customerType),
                      ),
                    ],
                  ),
                  if (ticket.discountRate >= 0) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildDetailItem(
                          'Discount',
                          '%${ticket.discountRate.toStringAsFixed(0)}',
                        ),
                        _buildDetailItem(
                          'Original Price',
                          '      ₺${ticket.showtime.price.toStringAsFixed(2)}',
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Durum
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(ticket.status),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _getStatusText(ticket.status),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColorStyle.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColorStyle.textSecondary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColorStyle.textPrimary,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _getCustomerTypeText(String type) {
    switch (type.toLowerCase()) {
      case 'adult':
        return 'Adult';
      case 'student':
        return 'Student';
      case 'child':
        return 'Child';
      case 'senior':
        return 'Senior';
      default:
        return type;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'sold':
        return Colors.green;
      case 'cancelled':
        return AppColorStyle.errorColor;
      case 'pending':
        return Colors.orange;
      default:
        return AppColorStyle.textSecondary;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'sold':
        return 'Sold';
      case 'cancelled':
        return 'Cancelled';
      case 'pending':
        return 'Pending';
      default:
        return status;
    }
  }
}
