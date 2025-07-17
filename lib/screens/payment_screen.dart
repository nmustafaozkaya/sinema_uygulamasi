import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sinema_uygulamasi/api_connection/api_connection.dart';
import 'package:sinema_uygulamasi/components/cinemas.dart';
import 'package:sinema_uygulamasi/components/movies.dart';
import 'package:sinema_uygulamasi/components/seat.dart';
import 'package:sinema_uygulamasi/components/showtimes.dart';
import 'package:sinema_uygulamasi/components/taxes.dart';
import 'package:sinema_uygulamasi/components/user.dart';
import 'package:sinema_uygulamasi/components/user_preferences.dart';
import 'package:sinema_uygulamasi/screens/home.dart';
import 'package:sinema_uygulamasi/constant/app_color_style.dart';

class PaymentScreen extends StatefulWidget {
  final Cinema cinema;
  final Movie movie;
  final Showtime showtime;
  final List<Seat> selectedSeats;
  final List<Map<String, dynamic>> selectedTicketDetails;
  final double totalPrice;
  final List<Tax> taxes;
  final double taxAmount;
  final double finalTotal;

  const PaymentScreen({
    super.key,
    required this.cinema,
    required this.movie,
    required this.showtime,
    required this.selectedSeats,
    required this.selectedTicketDetails,
    required this.totalPrice,
    required this.taxes,
    required this.taxAmount,
    required this.finalTotal,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  User? currentUser;
  String? _userToken;
  String _paymentMethod = 'card';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserDataAndToken();
  }

  Future<void> _loadUserDataAndToken() async {
    final fetchedUser = await UserPreferences.readData();
    final fetchedToken = await UserPreferences.getToken();

    if (mounted) {
      setState(() {
        currentUser = fetchedUser;
        _userToken = fetchedToken;
        if (currentUser != null) {
          _nameController.text = currentUser!.name;
          _emailController.text = currentUser!.email;
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _buildTicketsPayload() {
    List<Map<String, dynamic>> ticketsPayload = [];
    int seatIndex = 0;

    for (var detail in widget.selectedTicketDetails) {
      int count = detail['count'] as int;
      String customerType = detail['customer_type'] ?? 'adult';

      for (int i = 0; i < count; i++) {
        if (seatIndex < widget.selectedSeats.length) {
          ticketsPayload.add({
            'seat_id': widget.selectedSeats[seatIndex].id,
            'customer_type': customerType,
          });
          seatIndex++;
        } else {
          break;
        }
      }
    }

    return ticketsPayload;
  }

  Map<String, dynamic> _buildTaxCalculationPayload() {
    List<Map<String, dynamic>> taxList = widget.taxes
        .where((t) => t.status == 'active')
        .map((tax) {
          double rate = double.tryParse(tax.rate) ?? 0.0;
          double amount = TaxService.calculateTaxAmount(tax, widget.totalPrice);
          return {
            "name": tax.name,
            "type": tax.type,
            "rate": rate,
            "amount": double.parse(amount.toStringAsFixed(2)),
            "formatted_name": tax.type == 'percentage'
                ? "${tax.name} (${tax.rate}%)"
                : "${tax.name} (${tax.rate} ₺)",
          };
        })
        .toList();

    return {
      "subtotal": double.parse(widget.totalPrice.toStringAsFixed(2)),
      "taxes": taxList,
      "total_tax_amount": double.parse(widget.taxAmount.toStringAsFixed(2)),
      "total": double.parse(widget.finalTotal.toStringAsFixed(2)),
      "ticket_count": widget.selectedSeats.length,
    };
  }

  Future<void> _submitPayment() async {
    if (!_formKey.currentState!.validate()) return;

    if (_userToken == null || _userToken!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hata: Giriş yapılmamış. Lütfen tekrar giriş yapın.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final requestBody = {
      "showtime_id": widget.showtime.id,
      "tickets": _buildTicketsPayload(),
      "customer_name": _nameController.text,
      "customer_email": _emailController.text,
      "customer_phone": _phoneController.text,
      "payment_method": _paymentMethod,
      "tax_calculation": _buildTaxCalculationPayload(),
      "user_id": currentUser?.id,
    };

    try {
      final response = await http.post(
        Uri.parse(ApiConnection.buyTicket),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_userToken',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ödeme başarıyla tamamlandı!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => HomePage(currentUser: currentUser!),
          ),
          (route) => false,
        );
      } else if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Yetkilendirme hatası. Lütfen tekrar giriş yapın.'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: ${response.statusCode}\n${response.body}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bağlantı hatası: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorStyle.scaffoldBackground,
      appBar: AppBar(
        title: const Text("Ödeme Ekranı"),
        backgroundColor: AppColorStyle.appBarColor,
        foregroundColor: AppColorStyle.textPrimary,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildInfoCard(),
            _buildSummaryCard(),
            _buildCustomerInputs(),
            _buildPaymentOptions(),
            const SizedBox(height: 30),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      color: AppColorStyle.primaryAccent,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Film ve Seans Bilgileri',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColorStyle.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Film: ${widget.movie.title}',
              style: TextStyle(color: AppColorStyle.textSecondary),
            ),
            Text(
              'Sinema: ${widget.cinema.cinemaName}',
              style: TextStyle(color: AppColorStyle.textSecondary),
            ),
            Text(
              'Koltuklar: ${widget.selectedSeats.map((s) => s.displayName).join(', ')}',
              style: TextStyle(color: AppColorStyle.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      color: AppColorStyle.primaryAccent,
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bilet Özeti',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColorStyle.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Bilet Sayısı: ${widget.selectedSeats.length}',
              style: TextStyle(color: AppColorStyle.textSecondary),
            ),
            Text(
              'Ara Toplam: ₺${widget.totalPrice.toStringAsFixed(2)}',
              style: TextStyle(color: AppColorStyle.textSecondary),
            ),
            Text(
              'Vergi ve Ücretler: ₺${widget.taxAmount.toStringAsFixed(2)}',
              style: TextStyle(color: AppColorStyle.textSecondary),
            ),
            const Divider(height: 20, thickness: 1),
            Text(
              'Toplam: ₺${widget.finalTotal.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColorStyle.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerInputs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Müşteri Bilgileri',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColorStyle.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        _buildTextField(
          _nameController,
          'Ad Soyad',
          Icons.person,
          validator: (val) =>
              val == null || val.isEmpty ? 'Ad soyad giriniz' : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          _emailController,
          'E-posta',
          Icons.email,
          keyboardType: TextInputType.emailAddress,
          validator: (val) {
            if (val == null || val.isEmpty) return 'E-posta giriniz';
            if (!val.contains('@')) return 'Geçerli bir e-posta giriniz';
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          _phoneController,
          'Telefon',
          Icons.phone,
          hintText: '05XXXXXXXXX',
          keyboardType: TextInputType.phone,
          validator: (val) {
            if (val == null || val.isEmpty) {
              return 'Telefon numarası giriniz';
            }
            if (!RegExp(r'^05\d{9}$').hasMatch(val)) {
              return 'Geçerli bir telefon numarası giriniz';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    String? hintText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: AppColorStyle.primaryAccent,
        border: const OutlineInputBorder(),
        labelStyle: TextStyle(color: AppColorStyle.textSecondary),
        hintStyle: TextStyle(color: AppColorStyle.textSecondary),
      ),
      style: TextStyle(color: AppColorStyle.textPrimary),
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildPaymentOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          'Ödeme Yöntemi',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColorStyle.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Card(
          color: AppColorStyle.primaryAccent,
          child: Column(
            children: [
              _buildRadioOption('Kredi Kartı', 'card'),
              _buildRadioOption('Nakit', 'cash'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRadioOption(String title, String value) {
    return RadioListTile<String>(
      title: Text(title, style: TextStyle(color: AppColorStyle.textPrimary)),
      value: value,
      groupValue: _paymentMethod,
      onChanged: (val) => setState(() => _paymentMethod = val!),
      activeColor: AppColorStyle.textPrimary,
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColorStyle.appBarColor,
          foregroundColor: AppColorStyle.textPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                'Ödemeyi Tamamla (₺${widget.finalTotal.toStringAsFixed(2)})',
                style: const TextStyle(fontSize: 16),
              ),
      ),
    );
  }
}
