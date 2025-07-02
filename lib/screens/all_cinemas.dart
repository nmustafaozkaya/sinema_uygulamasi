import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sinema_uygulamasi/api_connection/api_connection.dart';

class AllCinemas extends StatefulWidget {
  const AllCinemas({super.key});

  @override
  State<AllCinemas> createState() => _AllCinemasState();
}

class _AllCinemasState extends State<AllCinemas> {
  List<Cinemas> cinemas = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchCinemas();
  }

  Future<void> fetchCinemas() async {
    final url = Uri.parse(ApiConnection.allCinemasapi);
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == true) {
          final List<dynamic> cinemasJson = data['data'];
          setState(() {
            cinemas = cinemasJson
                .map((json) => Cinemas.fromJson(json))
                .toList();
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = data['message'] ?? 'Bilinmeyen hata';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Sunucu hatası: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'İstek yapılırken hata oluştu: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tüm Sinemalar')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage))
          : ListView.builder(
              itemCount: cinemas.length,
              itemBuilder: (context, index) {
                final cinema = cinemas[index];
                return ListTile(
                  leading: Text('${cinema.cinemaId}'),
                  title: Text(cinema.cityName),
                  subtitle: Text(cinema.cinemaAddress),
                );
              },
            ),
    );
  }
}

class Cinemas {
  final int cinemaId;
  final String cityName;
  final String cinemaAddress;

  Cinemas({
    required this.cinemaId,
    required this.cityName,
    required this.cinemaAddress,
  });

  factory Cinemas.fromJson(Map<String, dynamic> json) {
    return Cinemas(
      cinemaId: json['cinema_id'],
      cityName: json['city_name'],
      cinemaAddress: json['cinema_address'],
    );
  }
}
